import 'dart:async';

import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rooktook/src/constants.dart';
import 'package:rooktook/src/model/analysis/analysis_controller.dart';
import 'package:rooktook/src/model/auth/auth_session.dart';
import 'package:rooktook/src/model/common/chess.dart';
import 'package:rooktook/src/model/common/id.dart';
import 'package:rooktook/src/model/engine/evaluation_preferences.dart';
import 'package:rooktook/src/model/engine/evaluation_service.dart';
import 'package:rooktook/src/model/game/game_repository_providers.dart';
import 'package:rooktook/src/model/puzzle/puzzle_angle.dart';
import 'package:rooktook/src/model/puzzle/puzzle_controller.dart';
import 'package:rooktook/src/model/puzzle/puzzle_difficulty.dart';
import 'package:rooktook/src/model/puzzle/puzzle_opening.dart';
import 'package:rooktook/src/model/puzzle/puzzle_preferences.dart';
import 'package:rooktook/src/model/puzzle/puzzle_providers.dart';
import 'package:rooktook/src/model/puzzle/puzzle_service.dart';
import 'package:rooktook/src/model/puzzle/puzzle_theme.dart';
import 'package:rooktook/src/model/settings/board_preferences.dart';
import 'package:rooktook/src/navigation.dart';
import 'package:rooktook/src/network/connectivity.dart';
import 'package:rooktook/src/network/http.dart';
import 'package:rooktook/src/utils/immersive_mode.dart';
import 'package:rooktook/src/utils/l10n_context.dart';
import 'package:rooktook/src/utils/navigation.dart';
import 'package:rooktook/src/utils/share.dart';
import 'package:rooktook/src/view/account/rating_pref_aware.dart';
import 'package:rooktook/src/view/analysis/analysis_screen.dart';
import 'package:rooktook/src/view/game/archived_game_screen.dart';
import 'package:rooktook/src/view/puzzle/puzzle_feedback_widget.dart';
import 'package:rooktook/src/view/puzzle/puzzle_session_widget.dart';
import 'package:rooktook/src/view/settings/board_settings_screen.dart';
import 'package:rooktook/src/view/settings/toggle_sound_button.dart';
import 'package:rooktook/src/widgets/adaptive_action_sheet.dart';
import 'package:rooktook/src/widgets/adaptive_bottom_sheet.dart';
import 'package:rooktook/src/widgets/adaptive_choice_picker.dart';
import 'package:rooktook/src/widgets/board_table.dart';
import 'package:rooktook/src/widgets/bottom_bar.dart';
import 'package:rooktook/src/widgets/bottom_bar_button.dart';
import 'package:rooktook/src/widgets/buttons.dart';
import 'package:rooktook/src/widgets/list.dart';
import 'package:rooktook/src/widgets/platform_scaffold.dart';
import 'package:rooktook/src/widgets/settings.dart';

class PuzzleScreen extends ConsumerStatefulWidget {
  /// Creates a new puzzle screen.
  ///
  /// If [puzzleId] is provided, the screen will load the puzzle with that id. Otherwise, it will load the next puzzle from the queue.
  const PuzzleScreen({required this.angle, this.puzzleId, super.key});

  final PuzzleAngle angle;
  final PuzzleId? puzzleId;

  static Route<dynamic> buildRoute(
    BuildContext context, {
    required PuzzleAngle angle,
    PuzzleId? puzzleId,
  }) {
    return buildScreenRoute(context, screen: PuzzleScreen(angle: angle, puzzleId: puzzleId));
  }

  @override
  ConsumerState<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends ConsumerState<PuzzleScreen> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route is PageRoute) {
      rootNavPageRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    rootNavPageRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPop() {
    super.didPop();
    if (mounted) {
      ref.invalidate(nextPuzzleProvider(widget.angle));
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.puzzleId != null
        ? _LoadPuzzleFromId(angle: widget.angle, id: widget.puzzleId!)
        : _LoadNextPuzzle(angle: widget.angle);
  }
}

class _Title extends ConsumerWidget {
  const _Title({required this.angle});

  final PuzzleAngle angle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (angle) {
      PuzzleTheme(themeKey: final key) =>
      // key == PuzzleThemeKey.mix
      // ?
      const Text('Puzzles'),
      // : Text(key.l10n(context.l10n).name),
      PuzzleOpening(key: final key) => ref
          .watch(puzzleOpeningNameProvider(key))
          .when(
            data: (data) => Text(data),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => Text(key.replaceAll('_', ' ')),
          ),
    };
  }
}

class _LoadNextPuzzle extends ConsumerWidget {
  const _LoadNextPuzzle({required this.angle});

  final PuzzleAngle angle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextPuzzle = ref.watch(nextPuzzleProvider(angle));

    return nextPuzzle.when(
      data: (data) {
        if (data == null) {
          return _PuzzleScaffold(
            angle: angle,
            initialPuzzleContext: null,
            body: const Center(
              child: BoardTable(
                fen: kEmptyFen,
                orientation: Side.white,
                errorMessage: 'No more puzzles. Go online to get more.',
              ),
            ),
          );
        } else {
          return _PuzzleScaffold(
            angle: angle,
            initialPuzzleContext: data,
            body: _Body(initialPuzzleContext: data),
          );
        }
      },
      loading:
          () => _PuzzleScaffold(
            angle: angle,
            initialPuzzleContext: null,
            body: const Center(child: CircularProgressIndicator.adaptive()),
          ),
      error: (e, s) {
        debugPrint('SEVERE: [PuzzleScreen] could not load next puzzle; $e\n$s');
        return _PuzzleScaffold(
          angle: angle,
          initialPuzzleContext: null,
          body: Center(
            child: BoardTable(fen: kEmptyFen, orientation: Side.white, errorMessage: e.toString()),
          ),
        );
      },
    );
  }
}

class _LoadPuzzleFromId extends ConsumerWidget {
  const _LoadPuzzleFromId({required this.angle, required this.id});

  final PuzzleAngle angle;
  final PuzzleId id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzle = ref.watch(puzzleProvider(id));
    final session = ref.watch(authSessionProvider);

    return puzzle.when(
      data: (data) {
        final initialPuzzleContext = PuzzleContext(
          angle: const PuzzleTheme(PuzzleThemeKey.mix),
          puzzle: data,
          userId: session?.user.id,
        );
        return _PuzzleScaffold(
          angle: angle,
          initialPuzzleContext: initialPuzzleContext,
          body: _Body(initialPuzzleContext: initialPuzzleContext),
        );
      },
      loading:
          () => _PuzzleScaffold(
            angle: angle,
            initialPuzzleContext: null,
            body: const Column(
              children: [
                Expanded(
                  child: SafeArea(
                    bottom: false,
                    child: BoardTable.empty(showEngineGaugePlaceholder: true),
                  ),
                ),
                PlatformBottomBar.empty(),
              ],
            ),
          ),
      error: (e, s) {
        debugPrint('SEVERE: [PuzzleScreen] could not load next puzzle; $e\n$s');
        return _PuzzleScaffold(
          angle: angle,
          initialPuzzleContext: null,
          body: Column(
            children: [
              Expanded(
                child: SafeArea(
                  bottom: false,
                  child: BoardTable(
                    fen: kEmptyFen,
                    orientation: Side.white,
                    errorMessage: e.toString(),
                  ),
                ),
              ),
              const SizedBox(height: kBottomBarHeight),
            ],
          ),
        );
      },
    );
  }
}

class _PuzzleScaffold extends StatelessWidget {
  const _PuzzleScaffold({
    required this.angle,
    required this.initialPuzzleContext,
    required this.body,
  });

  final PuzzleAngle angle;
  final PuzzleContext? initialPuzzleContext;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return WakelockWidget(
      child: PlatformScaffold(
        appBarActions: [
          const ToggleSoundButton(),
          if (initialPuzzleContext != null) _PuzzleSettingsButton(initialPuzzleContext!),
        ],
        appBarTitle: _Title(angle: angle),
        body: body,
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.initialPuzzleContext});

  final PuzzleContext initialPuzzleContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrlProvider = puzzleControllerProvider(initialPuzzleContext);
    final puzzleState = ref.watch(ctrlProvider);
    final enginePrefs = ref.watch(engineEvaluationPreferencesProvider);

    final boardPreferences = ref.watch(boardPreferencesProvider);

    final currentEvalBest = ref.watch(engineEvaluationProvider.select((s) => s.eval?.bestMove));
    final evalBestMove = (currentEvalBest ?? puzzleState.node.eval?.bestMove) as NormalMove?;

    return Column(
      children: [
        Expanded(
          child: SafeArea(
            bottom: false,
            child: BoardTable(
              orientation: puzzleState.pov,
              fen: puzzleState.fen,
              lastMove: puzzleState.lastMove as NormalMove?,
              gameData: GameData(
                playerSide:
                    puzzleState.mode == PuzzleMode.load || puzzleState.currentPosition.isGameOver
                        ? PlayerSide.none
                        : puzzleState.mode == PuzzleMode.view
                        ? PlayerSide.both
                        : puzzleState.pov == Side.white
                        ? PlayerSide.white
                        : PlayerSide.black,
                isCheck: boardPreferences.boardHighlights && puzzleState.currentPosition.isCheck,
                sideToMove: puzzleState.currentPosition.turn,
                validMoves: puzzleState.validMoves,
                promotionMove: puzzleState.promotionMove,
                onMove: (move, {isDrop}) {
                  ref.read(ctrlProvider.notifier).onUserMove(move);
                },
                onPromotionSelection: (role) {
                  ref.read(ctrlProvider.notifier).onPromotionSelection(role);
                },
              ),
              shapes:
                  puzzleState.isEngineAvailable(enginePrefs) && evalBestMove != null
                      ? ISet([
                        Arrow(
                          color: const Color(0x66003088),
                          orig: evalBestMove.from,
                          dest: evalBestMove.to,
                        ),
                      ])
                      : puzzleState.hintSquare != null
                      ? ISet([Circle(color: ShapeColor.green.color, orig: puzzleState.hintSquare!)])
                      : null,
              engineGauge:
                  puzzleState.isEngineAvailable(enginePrefs)
                      ? (
                        isLocalEngineAvailable: true,
                        orientation: puzzleState.pov,
                        position: puzzleState.currentPosition,
                        savedEval: puzzleState.node.eval,
                        serverEval: puzzleState.node.serverEval,
                      )
                      : null,
              showEngineGaugePlaceholder: true,
              topTable: Center(
                child: PuzzleFeedbackWidget(
                  puzzle: puzzleState.puzzle,
                  state: puzzleState,
                  onStreak: false,
                ),
              ),
              bottomTable: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // if (puzzleState.glicko != null)
                  //   RatingPrefAware(
                  //     child: Padding(
                  //       padding: const EdgeInsets.only(top: 10.0),
                  //       child: Row(
                  //         children: [
                  //          /* Text(context.l10n.rating),*//*
                  //           const SizedBox(width: 5.0),*/
                  //           TweenAnimationBuilder<double>(
                  //             tween: Tween<double>(
                  //               begin: puzzleState.glicko!.rating,
                  //               end:
                  //                   puzzleState.nextContext?.glicko?.rating ??
                  //                   puzzleState.glicko!.rating,
                  //             ),
                  //             duration: const Duration(milliseconds: 500),
                  //             builder: (context, double rating, _) {
                  //               final hasStarted = rating != puzzleState.glicko!.rating;
                  //               return Opacity(
                  //                 opacity: hasStarted ? 1 : 0, // Hide while on 'begin'
                  //                 child: Text(
                  //                   rating.truncate().toString(),
                  //                   style: const TextStyle(
                  //                     fontSize: 16.0,
                  //                     fontWeight: FontWeight.bold,
                  //                   ),
                  //                 ),
                  //               );
                  //             },
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // PuzzleSessionWidget(
                  //   initialPuzzleContext: initialPuzzleContext,
                  //   ctrlProvider: ctrlProvider,
                  // ),
                ],
              ),
            ),
          ),
        ),
        _BottomBar(
          initialPuzzleContext: initialPuzzleContext,
          puzzleId: puzzleState.puzzle.puzzle.id,
        ),
      ],
    );
  }
}

class _BottomBar extends ConsumerStatefulWidget {
  const _BottomBar({required this.initialPuzzleContext, required this.puzzleId});

  final PuzzleContext initialPuzzleContext;
  final PuzzleId puzzleId;

  static const _repeatTriggerDelays = [
    Duration(milliseconds: 500),
    Duration(milliseconds: 250),
    Duration(milliseconds: 100),
  ];

  @override
  ConsumerState<_BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends ConsumerState<_BottomBar> {
  static const viewSolutionDelay = Duration(seconds: 4);

  Timer? _viewSolutionTimer;
  Completer<void> _viewSolutionCompleter = Completer<void>();

  @override
  void initState() {
    super.initState();

    _viewSolutionTimer = Timer(viewSolutionDelay, () {
      _viewSolutionCompleter.complete();
    });
  }

  @override
  void didUpdateWidget(covariant _BottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.puzzleId != widget.puzzleId) {
      _viewSolutionCompleter = Completer<void>();
      _viewSolutionTimer?.cancel();
      _viewSolutionTimer = Timer(viewSolutionDelay, () {
        _viewSolutionCompleter.complete();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    _viewSolutionTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final ctrlProvider = puzzleControllerProvider(widget.initialPuzzleContext);
    final puzzleState = ref.watch(ctrlProvider);
    final enginePrefs = ref.watch(engineEvaluationPreferencesProvider);

    return Column(
      children: [
        if (puzzleState.mode == PuzzleMode.view)
          Container(
            height: 54,
            width: 140,
            decoration: BoxDecoration(
              color: const Color(0xff54C339),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton.icon(
              iconAlignment: IconAlignment.end, // Changed to center
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff54C339),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center, // Added alignment center
              ),

              onPressed:
                  puzzleState.mode == PuzzleMode.view && puzzleState.nextContext != null
                      ? () => ref.read(ctrlProvider.notifier).onLoadPuzzle(puzzleState.nextContext!)
                      : null,
              label: const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Next', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
            ),
          ),
        PlatformBottomBar(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (puzzleState.mode != PuzzleMode.view)
              FutureBuilder(
                future: _viewSolutionCompleter.future,
                builder: (context, snapshot) {
                  return BottomBarButton(
                    icon: Icons.info,
                    label: context.l10n.getAHint,
                    showLabel: true,
                    highlighted: puzzleState.hintSquare != null,
                    onTap:
                        snapshot.connectionState == ConnectionState.done
                            ? () => ref.read(ctrlProvider.notifier).toggleHint()
                            : null,
                  );
                },
              ),
            if (puzzleState.mode != PuzzleMode.view)
              FutureBuilder(
                future: _viewSolutionCompleter.future,
                builder: (context, snapshot) {
                  return BottomBarButton(
                    icon: Icons.help,
                    label: context.l10n.viewTheSolution,
                    showLabel: true,
                    onTap:
                        snapshot.connectionState == ConnectionState.done
                            ? () => ref.read(ctrlProvider.notifier).viewSolution()
                            : null,
                  );
                },
              ),
            /* if (puzzleState.mode == PuzzleMode.view)
              BottomBarButton(
                label: context.l10n.menu,
                onTap: () {
                  _showPuzzleMenu(context, ref);
                },
                icon: Icons.menu,
              ),*/
            /* if (puzzleState.mode == PuzzleMode.view)
              BottomBarButton(
                onTap: () {
                  ref.read(ctrlProvider.notifier).toggleEngine();
                },
                label: context.l10n.toggleLocalEvaluation,
                icon: CupertinoIcons.gauge,
                highlighted: puzzleState.isEngineAvailable(enginePrefs),
              ),*/
            if (puzzleState.mode == PuzzleMode.view)
              RepeatButton(
                triggerDelays: _BottomBar._repeatTriggerDelays,
                onLongPress: puzzleState.canGoBack ? () => _moveBackward(ref) : null,
                child: BottomBarButton(
                  onTap: puzzleState.canGoBack ? () => _moveBackward(ref) : null,
                  label: 'Previous',
                  icon: CupertinoIcons.chevron_back,
                  showTooltip: false,
                ),
              ),
            if (puzzleState.mode == PuzzleMode.view)
              RepeatButton(
                triggerDelays: _BottomBar._repeatTriggerDelays,
                onLongPress: puzzleState.canGoNext ? () => _moveForward(ref) : null,
                child: BottomBarButton(
                  onTap: puzzleState.canGoNext ? () => _moveForward(ref) : null,
                  label: context.l10n.next,
                  icon: CupertinoIcons.chevron_forward,
                  showTooltip: false,
                  blink: puzzleState.shouldBlinkNextArrow,
                ),
              ),
            // if (puzzleState.mode == PuzzleMode.view)
            //   BottomBarButton(
            //     onTap:
            //         puzzleState.mode == PuzzleMode.view && puzzleState.nextContext != null
            //             ? () =>
            //                 ref.read(ctrlProvider.notifier).onLoadPuzzle(puzzleState.nextContext!)
            //             : null,
            //     highlighted: true,
            //     label: context.l10n.puzzleContinueTraining,
            //     icon: CupertinoIcons.play_arrow_solid,
            //   ),
          ],
        ),
      ],
    );
  }

  Future<void> _showPuzzleMenu(BuildContext context, WidgetRef ref) {
    final puzzleState = ref.watch(puzzleControllerProvider(widget.initialPuzzleContext));
    return showAdaptiveActionSheet(
      context: context,
      actions: [
        BottomSheetAction(
          makeLabel: (context) => Text(context.l10n.mobileSharePuzzle),
          onPressed: () {
            launchShareDialog(
              context,
              text: lichessUri('/training/${puzzleState.puzzle.puzzle.id}').toString(),
            );
          },
        ),
        BottomSheetAction(
          makeLabel: (context) => Text(context.l10n.analysis),
          onPressed: () {
            Navigator.of(context).push(
              AnalysisScreen.buildRoute(
                context,
                AnalysisOptions(
                  orientation: puzzleState.pov,
                  standalone: (
                    pgn:
                        ref
                            .read(puzzleControllerProvider(widget.initialPuzzleContext).notifier)
                            .makePgn(),
                    isComputerAnalysisAllowed: true,
                    variant: Variant.standard,
                  ),
                  initialMoveCursor: 0,
                ),
              ),
            );
          },
        ),
        BottomSheetAction(
          makeLabel:
              (context) => Text(context.l10n.puzzleFromGameLink(puzzleState.puzzle.game.id.value)),
          onPressed: () async {
            final game = await ref.read(
              archivedGameProvider(id: puzzleState.puzzle.game.id).future,
            );
            if (context.mounted) {
              Navigator.of(context).push(
                ArchivedGameScreen.buildRoute(
                  context,
                  gameData: game.data,
                  orientation: puzzleState.pov,
                  initialCursor: puzzleState.puzzle.puzzle.initialPly + 1,
                ),
              );
            }
          },
        ),
      ],
    );
  }

  void _moveForward(WidgetRef ref) {
    ref.read(puzzleControllerProvider(widget.initialPuzzleContext).notifier).userNext();
  }

  void _moveBackward(WidgetRef ref) {
    ref.read(puzzleControllerProvider(widget.initialPuzzleContext).notifier).userPrevious();
  }
}

class _PuzzleSettingsButton extends StatelessWidget {
  const _PuzzleSettingsButton(this.initialPuzzleContext);

  final PuzzleContext initialPuzzleContext;

  @override
  Widget build(BuildContext context) {
    return AppBarIconButton(
      onPressed:
          () => showAdaptiveBottomSheet<void>(
            context: context,
            isDismissible: true,
            isScrollControlled: true,
            showDragHandle: true,

            builder: (_) => _PuzzleSettingsBottomSheet(initialPuzzleContext),
          ),
      semanticsLabel: context.l10n.settingsSettings,
      icon: const Icon(Icons.settings),
    );
  }
}

class _PuzzleSettingsBottomSheet extends ConsumerWidget {
  const _PuzzleSettingsBottomSheet(this.initialPuzzleContext);

  final PuzzleContext initialPuzzleContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(authSessionProvider)?.user.id != null;
    final autoNext = ref.watch(puzzlePreferencesProvider.select((value) => value.autoNext));
    final rated = ref.watch(puzzlePreferencesProvider.select((value) => value.rated));
    final ctrlProvider = puzzleControllerProvider(initialPuzzleContext);
    final puzzleState = ref.watch(ctrlProvider);
    final isDailyPuzzle = puzzleState.puzzle.isDailyPuzzle == true;
    final difficulty = ref.watch(puzzlePreferencesProvider.select((state) => state.difficulty));
    final isOnline = ref.watch(connectivityChangesProvider).valueOrNull?.isOnline ?? false;
    return BottomSheetScrollableContainer(
      children: [
        ListSection(
          materialFilledCard: true,
          children: [
            if (initialPuzzleContext.userId != null &&
                !isDailyPuzzle &&
                puzzleState.mode != PuzzleMode.view &&
                isOnline)
              StatefulBuilder(
                builder: (context, setState) {
                  PuzzleDifficulty selectedDifficulty = difficulty;
                  return SettingsListTile(
                    settingsLabel: Text(context.l10n.puzzleDifficultyLevel),
                    settingsValue: puzzleDifficultyL10n(context, difficulty),
                    onTap:
                        puzzleState.isChangingDifficulty
                            ? null
                            : () {
                              showChoicePicker(
                                context,
                                choices: PuzzleDifficulty.values,
                                selectedItem: difficulty,
                                labelBuilder: (t) => Text(puzzleDifficultyL10n(context, t)),
                                onSelectedItemChanged: (PuzzleDifficulty? d) {
                                  if (d != null) {
                                    setState(() {
                                      selectedDifficulty = d;
                                    });
                                  }
                                },
                              ).then((_) async {
                                if (selectedDifficulty == difficulty) {
                                  return;
                                }
                                final nextContext = await ref
                                    .read(ctrlProvider.notifier)
                                    .changeDifficulty(selectedDifficulty);
                                if (context.mounted && nextContext != null) {
                                  ref.read(ctrlProvider.notifier).onLoadPuzzle(nextContext);
                                }
                              });
                            },
                  );
                },
              ),
            SwitchSettingTile(
              title: Text(context.l10n.puzzleJumpToNextPuzzleImmediately),
              value: autoNext,
              onChanged: (value) {
                ref.read(puzzlePreferencesProvider.notifier).setAutoNext(value);
              },
            ),
            if (signedIn)
              SwitchSettingTile(
                title: Text(context.l10n.rated),
                value: rated,
                onChanged: (value) {
                  ref.read(puzzlePreferencesProvider.notifier).setRated(value);
                },
              ),
            PlatformListTile(
              title: const Text('Board settings'),
              trailing: const Icon(CupertinoIcons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(
                  context,
                ).push(BoardSettingsScreen.buildRoute(context, fullscreenDialog: true));
              },
            ),
          ],
        ),
      ],
    );
  }
}
