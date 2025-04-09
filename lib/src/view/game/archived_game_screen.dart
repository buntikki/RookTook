import 'package:dartchess/dartchess.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lichess_mobile/src/model/account/account_service.dart';
import 'package:lichess_mobile/src/model/analysis/analysis_controller.dart';
import 'package:lichess_mobile/src/model/auth/auth_session.dart';
import 'package:lichess_mobile/src/model/common/id.dart';
import 'package:lichess_mobile/src/model/game/archived_game.dart';
import 'package:lichess_mobile/src/model/game/game.dart';
import 'package:lichess_mobile/src/model/game/game_filter.dart';
import 'package:lichess_mobile/src/model/game/game_repository_providers.dart';
import 'package:lichess_mobile/src/network/http.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';
import 'package:lichess_mobile/src/view/analysis/analysis_screen.dart';
import 'package:lichess_mobile/src/view/game/archived_game_screen_providers.dart';
import 'package:lichess_mobile/src/view/game/game_common_widgets.dart';
import 'package:lichess_mobile/src/view/game/game_player.dart';
import 'package:lichess_mobile/src/view/game/game_result_dialog.dart';
import 'package:lichess_mobile/src/view/settings/toggle_sound_button.dart';
import 'package:lichess_mobile/src/widgets/adaptive_action_sheet.dart';
import 'package:lichess_mobile/src/widgets/board_table.dart';
import 'package:lichess_mobile/src/widgets/bottom_bar.dart';
import 'package:lichess_mobile/src/widgets/bottom_bar_button.dart';
import 'package:lichess_mobile/src/widgets/buttons.dart';
import 'package:lichess_mobile/src/widgets/clock.dart';
import 'package:lichess_mobile/src/widgets/platform_context_menu_button.dart';
import 'package:lichess_mobile/src/widgets/platform_scaffold.dart';

/// Screen for viewing an archived game.
class ArchivedGameScreen extends ConsumerWidget {
  const ArchivedGameScreen({
    this.gameId,
    this.gameData,
    required this.orientation,
    this.initialCursor,
    this.gameListContext,
    super.key,
  }) : assert(gameId != null || gameData != null);

  final LightArchivedGame? gameData;
  final GameId? gameId;

  final Side orientation;
  final int? initialCursor;

  /// The context of the game list that opened this screen, if available.
  final (UserId?, GameFilterState)? gameListContext;

  static Route<dynamic> buildRoute(
    BuildContext context, {
    GameId? gameId,
    LightArchivedGame? gameData,
    Side orientation = Side.white,
    int? initialCursor,
    (UserId?, GameFilterState)? gameListContext,
  }) {
    return buildScreenRoute(
      context,
      screen: ArchivedGameScreen(
        gameId: gameId,
        gameData: gameData,
        orientation: orientation,
        initialCursor: initialCursor,
        gameListContext: gameListContext,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (gameData != null) {
      return _Body(
        gameData: gameData,
        orientation: orientation,
        initialCursor: initialCursor,
        gameListContext: gameListContext,
      );
    } else {
      return _LoadGame(
        gameId: gameId!,
        orientation: orientation,
        initialCursor: initialCursor,
        gameListContext: gameListContext,
      );
    }
  }
}

class _LoadGame extends ConsumerWidget {
  const _LoadGame({
    required this.gameId,
    required this.orientation,
    required this.initialCursor,
    required this.gameListContext,
  });

  final GameId gameId;
  final Side orientation;
  final int? initialCursor;

  /// The context of the game list that opened this screen, if available.
  final (UserId?, GameFilterState)? gameListContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(archivedGameProvider(id: gameId));

    return game.when(
      data: (game) {
        return _Body(
          gameData: game.data,
          orientation: orientation,
          initialCursor: initialCursor,
          gameListContext: gameListContext,
        );
      },
      loading:
          () => _Body(
            gameData: null,
            orientation: orientation,
            initialCursor: initialCursor,
            gameListContext: gameListContext,
          ),
      error: (error, stackTrace) {
        debugPrint('SEVERE: [ArchivedGameScreen] could not load game; $error\n$stackTrace');
        switch (error) {
          case ServerException _ when error.statusCode == 404:
            return _Body(
              gameData: null,
              orientation: orientation,
              initialCursor: initialCursor,
              gameListContext: gameListContext,
              error: 'Game not found.',
            );
          default:
            return _Body(
              gameData: null,
              orientation: orientation,
              initialCursor: initialCursor,
              gameListContext: gameListContext,
              error: error,
            );
        }
      },
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body({
    required this.gameData,
    required this.orientation,
    this.initialCursor,
    this.error,
    required this.gameListContext,
  });

  final LightArchivedGame? gameData;
  final Object? error;
  final Side orientation;
  final int? initialCursor;

  /// The context of the game list that opened this screen, if available.
  final (UserId?, GameFilterState)? gameListContext;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  late bool _bookmarked;

  @override
  void initState() {
    _bookmarked = widget.gameData?.bookmarked ?? false;
    super.initState();
  }

  Future<void> _toggleBookmark() async {
    final toggledBookmark = !_bookmarked;
    final gameData = widget.gameData;
    if (gameData == null) return;
    await ref.read(accountServiceProvider).setGameBookmark(gameData.id, bookmark: toggledBookmark);
    if (mounted) {
      setState(() {
        _bookmarked = toggledBookmark;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(isLoggedInProvider);

    return PlatformScaffold(
      appBarTitle:
          widget.gameData != null
              ? _GameTitle(gameData: widget.gameData!)
              : const SizedBox.shrink(),
      appBarActions: [
        if (widget.gameData == null && widget.error == null) const PlatformAppBarLoadingIndicator(),
        if (widget.gameData != null)
          PlatformContextMenuButton(
            icon: const Icon(Icons.more_horiz),
            semanticsLabel: context.l10n.menu,
            actions: [
              const ToggleSoundContextMenuAction(),
              if (isLoggedIn)
                GameBookmarkContextMenuAction(
                  id: widget.gameData!.id,
                  bookmarked: _bookmarked,
                  onToggleBookmark: _toggleBookmark,
                  gameListContext: widget.gameListContext,
                ),
              ...(switch (ref.watch(gameCursorProvider(widget.gameData!.id))) {
                AsyncData(:final value) => makeFinishedGameShareMenuItemButtons(
                  context,
                  ref,
                  gameId: widget.gameData!.id,
                  orientation: value.$1.youAre ?? Side.white,
                ),
                _ => [],
              }),
            ],
          ),
      ],
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: _BoardBody(
                archivedGameData: widget.gameData,
                orientation: widget.orientation,
                initialCursor: widget.initialCursor,
                error: widget.error,
              ),
            ),
            _BottomBar(archivedGameData: widget.gameData, orientation: widget.orientation),
          ],
        ),
      ),
    );
  }
}

class _GameTitle extends ConsumerWidget {
  const _GameTitle({required this.gameData});

  final LightArchivedGame gameData;

  static final _dateFormat = DateFormat.yMMMd();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (gameData.source == GameSource.import)
          Icon(Icons.cloud_upload, color: DefaultTextStyle.of(context).style.color)
        else
          if (gameData.perf.title=='Bullet') Image.asset('assets/images/bullet_game.png', height: 20, width: 20,) else Image.asset('assets/images/rapid_game.png', height: 20, width: 20,),
          //Icon(gameData.perf.icon, color: DefaultTextStyle.of(context).style.color),
        const SizedBox(width: 4.0),
        if (gameData.source == GameSource.import)
          Text('Import • ${_dateFormat.format(gameData.createdAt)}')
        else
          Text('${gameData.clockDisplay} • ${_dateFormat.format(gameData.lastMoveAt)}'),
      ],
    );
  }
}

class _BoardBody extends ConsumerWidget {
  const _BoardBody({
    required this.archivedGameData,
    required this.orientation,
    this.error,
    this.initialCursor,
  });

  final LightArchivedGame? archivedGameData;
  final Side orientation;
  final int? initialCursor;
  final Object? error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameData = archivedGameData;

    if (gameData == null) {
      return BoardTable.empty(showMoveListPlaceholder: true, errorMessage: error?.toString());
    }

    if (initialCursor != null) {
      ref.listen(gameCursorProvider(gameData.id), (prev, cursor) {
        if (prev?.isLoading == true && cursor.hasValue) {
          ref.read(gameCursorProvider(gameData.id).notifier).cursorAt(initialCursor!);
        }
      });
    }

    final isBoardTurned = ref.watch(isBoardTurnedProvider);
    final gameCursor = ref.watch(gameCursorProvider(gameData.id));
    final loadingBoard = BoardTable(
      orientation: (isBoardTurned ? orientation.opposite : orientation),
      fen: initialCursor == null ? gameData.lastFen ?? kEmptyBoardFEN : kEmptyBoardFEN,
      showMoveListPlaceholder: true,
    );

    return gameCursor.when(
      data: (data) {
        final (game, cursor) = data;
        final whiteClock = game.archivedWhiteClockAt(cursor);
        final blackClock = game.archivedBlackClockAt(cursor);
        final black = GamePlayer(
          key: const ValueKey('black-player'),
          game: game,
          side: Side.black,
          clock: blackClock != null ? Clock(timeLeft: blackClock) : null,
          materialDiff: game.materialDiffAt(cursor, Side.black),
        );
        final white = GamePlayer(
          key: const ValueKey('white-player'),
          game: game,
          side: Side.white,
          clock: whiteClock != null ? Clock(timeLeft: whiteClock) : null,
          materialDiff: game.materialDiffAt(cursor, Side.white),
        );

        final topPlayerIsBlack =
            orientation == Side.white && !isBoardTurned ||
            orientation == Side.black && isBoardTurned;
        final topPlayer = topPlayerIsBlack ? black : white;
        final bottomPlayer = topPlayerIsBlack ? white : black;

        final position = game.positionAt(cursor);

        return BoardTable(
          orientation: (isBoardTurned ? orientation.opposite : orientation),
          fen: position.fen,
          lastMove: game.moveAt(cursor) as NormalMove?,
          topTable: topPlayer,
          bottomTable: bottomPlayer,
          moves: game.steps.skip(1).map((e) => e.sanMove!.san).toList(growable: false),
          currentMoveIndex: cursor,
          onSelectMove: (moveIndex) {
            ref.read(gameCursorProvider(gameData.id).notifier).cursorAt(moveIndex);
          },
        );
      },
      loading: () => loadingBoard,
      error: (error, stackTrace) {
        debugPrint('SEVERE: [ArchivedGameScreen] could not load game; $error\n$stackTrace');
        return loadingBoard;
      },
    );
  }
}

class _BottomBar extends ConsumerWidget {
  const _BottomBar({required this.archivedGameData, required this.orientation});

  final Side orientation;
  final LightArchivedGame? archivedGameData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameData = archivedGameData;

    if (gameData == null) {
      return const PlatformBottomBar(children: []);
    }

    final canGoForward = ref.watch(canGoForwardProvider(gameData.id));
    final canGoBackward = ref.watch(canGoBackwardProvider(gameData.id));
    final gameCursor = ref.watch(gameCursorProvider(gameData.id));

    Future<void> showGameMenu() {
      return showAdaptiveActionSheet(
        context: context,
        actions: [
          BottomSheetAction(
            makeLabel: (context) => Text(context.l10n.flipBoard),
            onPressed: () {
              ref.read(isBoardTurnedProvider.notifier).toggle();
            },
          ),
        ],
      );
    }

    return PlatformBottomBar(
      children: [
        BottomBarButton(label: context.l10n.menu, onTap: showGameMenu, icon: Icons.menu),
        if (gameCursor.hasValue)
          BottomBarButton(
            label: context.l10n.mobileShowResult,
            icon: Icons.info_outline,
            onTap: () {
              showAdaptiveDialog<void>(
                context: context,
                builder: (context) => ArchivedGameResultDialog(game: gameCursor.requireValue.$1),
                barrierDismissible: true,
              );
            },
          ),
        BottomBarButton(
          label: context.l10n.gameAnalysis,
          onTap:
              gameCursor.hasValue
                  ? () {
                    final cursor = gameCursor.requireValue.$2;
                    Navigator.of(context).push(
                      AnalysisScreen.buildRoute(
                        context,
                        AnalysisOptions(
                          orientation: orientation,
                          gameId: gameData.id,
                          initialMoveCursor: cursor,
                        ),
                      ),
                    );
                  }
                  : null,
          icon: Icons.biotech,
        ),
        RepeatButton(
          onLongPress: canGoBackward ? () => _cursorBackward(ref) : null,
          child: BottomBarButton(
            key: const ValueKey('cursor-back'),
            // TODO add translation
            label: 'Backward',
            showTooltip: false,
            onTap: canGoBackward ? () => _cursorBackward(ref) : null,
            icon: CupertinoIcons.chevron_back,
          ),
        ),
        RepeatButton(
          onLongPress: canGoForward ? () => _cursorForward(ref) : null,
          child: BottomBarButton(
            key: const ValueKey('cursor-forward'),
            // TODO add translation
            label: 'Forward',
            showTooltip: false,
            onTap: canGoForward ? () => _cursorForward(ref) : null,
            icon: CupertinoIcons.chevron_forward,
          ),
        ),
      ],
    );
  }

  void _cursorForward(WidgetRef ref) {
    if (archivedGameData == null) return;
    ref.read(gameCursorProvider(archivedGameData!.id).notifier).cursorForward();
  }

  void _cursorBackward(WidgetRef ref) {
    if (archivedGameData == null) return;
    ref.read(gameCursorProvider(archivedGameData!.id).notifier).cursorBackward();
  }
}
