import 'dart:async';

import 'package:async/async.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rooktook/src/model/common/chess.dart';
import 'package:rooktook/src/model/common/node.dart';
import 'package:rooktook/src/model/common/service/move_feedback.dart';
import 'package:rooktook/src/model/common/service/sound_service.dart';
import 'package:rooktook/src/model/common/uci.dart';
import 'package:rooktook/src/model/engine/evaluation_mixin.dart';
import 'package:rooktook/src/model/engine/evaluation_preferences.dart';
import 'package:rooktook/src/model/engine/evaluation_service.dart';
import 'package:rooktook/src/model/puzzle/puzzle.dart';
import 'package:rooktook/src/model/puzzle/puzzle_angle.dart';
import 'package:rooktook/src/model/puzzle/puzzle_difficulty.dart';
import 'package:rooktook/src/model/puzzle/puzzle_preferences.dart';
import 'package:rooktook/src/model/puzzle/puzzle_repository.dart';
import 'package:rooktook/src/model/puzzle/puzzle_service.dart';
import 'package:rooktook/src/model/puzzle/puzzle_session.dart';
import 'package:rooktook/src/model/puzzle/puzzle_streak.dart';
import 'package:rooktook/src/model/puzzle/puzzle_theme.dart';
import 'package:rooktook/src/model/puzzle/streak_storage.dart';
import 'package:rooktook/src/network/connectivity.dart';
import 'package:rooktook/src/network/http.dart';
import 'package:rooktook/src/network/socket.dart';
import 'package:result_extensions/result_extensions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'puzzle_controller.freezed.dart';
part 'puzzle_controller.g.dart';

@riverpod
class PuzzleController extends _$PuzzleController with EngineEvaluationMixin {
  static final Uri socketUri = Uri(path: '/analysis/socket/v5');

  late Branch _gameTree;
  Timer? _firstMoveTimer;
  Timer? _viewSolutionTimer;

  // on streak, we pre-load the next puzzle to avoid a delay when the user
  // completes the current one
  FutureResult<PuzzleContext?>? _nextPuzzleFuture;

  @override
  @protected
  EngineEvaluationPrefState get evaluationPrefs => ref.read(engineEvaluationPreferencesProvider);

  @override
  @protected
  EngineEvaluationPreferences get evaluationPreferencesNotifier =>
      ref.read(engineEvaluationPreferencesProvider.notifier);

  @override
  @protected
  EvaluationService evaluationServiceFactory() => ref.read(evaluationServiceProvider);

  @override
  @protected
  PuzzleState get evaluationState => state;

  @override
  @protected
  late SocketClient socketClient;

  @override
  @protected
  Branch get positionTree => _gameTree;

  Future<PuzzleService> get _service =>
      ref.read(puzzleServiceFactoryProvider)(queueLength: kPuzzleLocalQueueLength);

  @override
  PuzzleState build(PuzzleContext initialContext, {PuzzleStreak? initialStreak}) {
    socketClient = ref.watch(socketPoolProvider).open(PuzzleController.socketUri);

    isOnline(ref.read(defaultClientProvider)).then((online) {
      if (!online) {
        socketClient.close();
      }
    });

    initEngineEvaluation();

    ref.onDispose(() {
      _firstMoveTimer?.cancel();
      _viewSolutionTimer?.cancel();
      disposeEngineEvaluation();
    });

    // we might not have the user rating yet so let's update it now
    // then it will be updated on each puzzle completion
    if (initialContext.userId != null) {
      _updateUserRating();
    }

    return _loadNewContext(initialContext, initialStreak);
  }

  PuzzleRepository _repository(LichessClient client) => PuzzleRepository(client);

  Future<void> _updateUserRating() async {
    try {
      final data = await ref.withClient((client) => _repository(client).selectBatch(nb: 0));
      final glicko = data.glicko;
      if (glicko != null) {
        state = state.copyWith(glicko: glicko);
      }
    } catch (_) {}
  }

  PuzzleState _loadNewContext(PuzzleContext context, PuzzleStreak? streak) {
    final root = Root.fromPgnMoves(context.puzzle.game.pgn);
    _gameTree = root.nodeAt(root.mainlinePath.penultimate) as Branch;

    // play first move after 1 second
    _firstMoveTimer = Timer(const Duration(seconds: 1), () {
      _setPath(state.initialPath, firstMove: true);
    });

    final initialPath = UciPath.fromId(_gameTree.children.first.id);

    // preload next streak puzzle
    if (streak != null) {
      _nextPuzzleFuture = _fetchNextStreakPuzzle(streak);
    }

    return PuzzleState(
      puzzle: context.puzzle,
      glicko: context.glicko,
      mode: PuzzleMode.load,
      initialPosition: _gameTree.position,
      initialPath: initialPath,
      currentPath: UciPath.empty,
      node: _gameTree.view,
      pov: _gameTree.nodeAt(initialPath).position.ply.isEven ? Side.white : Side.black,
      hintShown: false,
      resultSent: false,
      isChangingDifficulty: false,
      shouldBlinkNextArrow: false,
      streak: streak,
      nextPuzzleStreakFetchError: false,
      nextPuzzleStreakFetchIsRetrying: false,
    );
  }

  Future<void> onUserMove(NormalMove move) async {
    if (isPromotionPawnMove(state.currentPosition, move)) {
      state = state.copyWith(promotionMove: move);
      return;
    }

    _addMove(move);

    if (state.mode == PuzzleMode.play) {
      state = state.copyWith(hintSquare: null);
      final nodeList = _gameTree.branchesOn(state.currentPath).toList();
      final movesToTest = nodeList.sublist(state.initialPath.size).map((e) => e.sanMove);

      final isGoodMove = state.puzzle.testSolution(movesToTest);

      if (isGoodMove) {
        state = state.copyWith(feedback: PuzzleFeedback.good);

        final isCheckmate = movesToTest.last.san.endsWith('#');
        final nextUci = state.puzzle.puzzle.solution.getOrNull(movesToTest.length);
        // checkmate is always a win
        if (isCheckmate) {
          _completePuzzle();
        }
        // another puzzle move: let's continue
        else if (nextUci != null) {
          await Future<void>.delayed(const Duration(milliseconds: 500));
          _addMove(Move.parse(nextUci)!);
        }
        // no more puzzle move: it's a win
        else {
          _completePuzzle();
        }
      } else {
        state = state.copyWith(feedback: PuzzleFeedback.bad);
        _onFailOrWin(PuzzleResult.lose);
        if (initialStreak == null) {
          await Future<void>.delayed(const Duration(milliseconds: 500));
          _setPath(state.currentPath.penultimate);
        }
      }
    }
  }

  void onPromotionSelection(Role? role) {
    if (role == null) {
      state = state.copyWith(promotionMove: null);
      return;
    }
    final promotionMove = state.promotionMove;
    if (promotionMove != null) {
      final move = promotionMove.withPromotion(role);
      onUserMove(move);
    }
  }

  void userNext() {
    _viewSolutionTimer?.cancel();
    _goToNextNode(replaying: true);
  }

  void userPrevious() {
    _viewSolutionTimer?.cancel();
    _goToPreviousNode(replaying: true);
  }

  void viewSolution() {
    if (state.mode == PuzzleMode.view) return;

    _mergeSolution();

    state = state.copyWith(node: _gameTree.branchAt(state.currentPath).view);

    _onFailOrWin(PuzzleResult.lose);

    state = state.copyWith(mode: PuzzleMode.view);

    _viewSolutionTimer = Timer(const Duration(milliseconds: 800), () {
      _goToNextNode();

      if (state.canGoNext) {
        state = state.copyWith(shouldBlinkNextArrow: true);
      }
    });
  }

  void toggleHint() {
    if (state.hintSquare == null) {
      state = state.copyWith(hintShown: true, hintSquare: state._nextSolutionMove.from);
    } else {
      state = state.copyWith(hintSquare: null);
    }
  }

  void skipMove() {
    if (state.streak != null) {
      state = state.copyWith.streak!(hasSkipped: true);
      onUserMove(state._nextSolutionMove);
    }
  }

  Future<PuzzleContext?> changeDifficulty(PuzzleDifficulty difficulty) async {
    state = state.copyWith(isChangingDifficulty: true);

    await ref.read(puzzlePreferencesProvider.notifier).setDifficulty(difficulty);

    final nextPuzzle = (await _service).resetBatch(
      userId: initialContext.userId,
      angle: initialContext.angle,
    );

    state = state.copyWith(isChangingDifficulty: false);

    return nextPuzzle;
  }

  void onLoadPuzzle(PuzzleContext nextContext, {PuzzleStreak? nextStreak}) {
    ref.read(evaluationServiceProvider).disposeEngine();

    state = _loadNewContext(nextContext, nextStreak ?? state.streak);
    _saveCurrentStreakLocally();
  }

  void _saveCurrentStreakLocally() {
    if (state.streak != null) {
      ref.read(streakStorageProvider(initialContext.userId)).saveActiveStreak(state.streak!);
    }
  }

  void _sendStreakResult() {
    ref.read(streakStorageProvider(initialContext.userId)).clearActiveStreak();

    if (initialContext.userId != null) {
      final streak = state.streak?.index;
      if (streak != null && streak > 0) {
        ref.withClient((client) => _repository(client).postStreakRun(streak));
      }
    }
  }

  FutureResult<PuzzleContext?> retryFetchNextStreakPuzzle(PuzzleStreak streak) async {
    state = state.copyWith(nextPuzzleStreakFetchIsRetrying: true);

    final result = await _fetchNextStreakPuzzle(streak);

    state = state.copyWith(nextPuzzleStreakFetchIsRetrying: false);

    result.match(
      onSuccess: (nextContext) {
        if (nextContext != null) {
          state = state.copyWith(streak: streak.copyWith(index: streak.index + 1));
        } else {
          // no more puzzle
          state = state.copyWith(streak: streak.copyWith(index: streak.index + 1, finished: true));
        }
      },
    );

    return result;
  }

  FutureResult<PuzzleContext?> _fetchNextStreakPuzzle(PuzzleStreak streak) {
    return streak.nextId != null
        ? Result.capture(
          ref.withClient(
            (client) => _repository(client)
                .fetch(streak.nextId!)
                .then(
                  (puzzle) => PuzzleContext(
                    angle: const PuzzleTheme(PuzzleThemeKey.mix),
                    puzzle: puzzle,
                    userId: initialContext.userId,
                  ),
                ),
          ),
        )
        : Future.value(Result.value(null));
  }

  void _goToNextNode({bool replaying = false}) {
    if (state.node.children.isEmpty) return;
    _setPath(state.currentPath + state.node.children.first.id, replaying: replaying);
  }

  void _goToPreviousNode({bool replaying = false}) {
    _setPath(state.currentPath.penultimate, replaying: replaying);
  }

  Future<void> _completePuzzle() async {
    state = state.copyWith(mode: PuzzleMode.view);
    await _onFailOrWin(state.result ?? PuzzleResult.win);
  }

  Future<void> _onFailOrWin(PuzzleResult result) async {
    if (state.resultSent) return;

    state = state.copyWith(result: result, resultSent: true);

    final soundService = ref.read(soundServiceProvider);

    if (state.streak == null) {
      final next = await (await _service).solve(
        userId: initialContext.userId,
        angle: initialContext.angle,
        puzzle: state.puzzle,
        solution: PuzzleSolution(
          id: state.puzzle.puzzle.id,
          win: state.result == PuzzleResult.win,
          rated:
              initialContext.userId != null &&
              !state.hintShown &&
              ref.read(puzzlePreferencesProvider).rated,
        ),
      );

      state = state.copyWith(nextContext: next);

      ref
          .read(puzzleSessionProvider(initialContext.userId, initialContext.angle).notifier)
          .addAttempt(state.puzzle.puzzle.id, win: result == PuzzleResult.win);

      final rounds = next?.rounds;
      if (rounds != null) {
        ref
            .read(puzzleSessionProvider(initialContext.userId, initialContext.angle).notifier)
            .setRatingDiffs(rounds);
      }

      if (next != null &&
          result == PuzzleResult.win &&
          ref.read(puzzlePreferencesProvider).autoNext) {
        onLoadPuzzle(next);
      }
    } else {
      // one fail and streak is over
      if (result == PuzzleResult.lose) {
        soundService.play(Sound.error);
        await Future<void>.delayed(const Duration(milliseconds: 500));
        _setPath(state.currentPath.penultimate);
        _mergeSolution();
        state = state.copyWith(
          mode: PuzzleMode.view,
          node: _gameTree.branchAt(state.currentPath).view,
          streak: state.streak!.copyWith(finished: true),
        );
        _sendStreakResult();
      } else {
        if (_nextPuzzleFuture == null) {
          assert(false, 'next puzzle future cannot be null with streak');
        } else {
          final result = await _nextPuzzleFuture!;
          result.match(
            onSuccess: (nextContext) async {
              if (nextContext != null) {
                await Future<void>.delayed(const Duration(milliseconds: 250));
                soundService.play(Sound.confirmation);
                onLoadPuzzle(
                  nextContext,
                  nextStreak: state.streak!.copyWith(index: state.streak!.index + 1),
                );
              } else {
                // no more puzzle
                state = state.copyWith.streak!(finished: true);
              }
            },
            onError: (error, _) {
              state = state.copyWith(nextPuzzleStreakFetchError: true);
            },
          );
        }
      }
    }
  }

  void _setPath(UciPath path, {bool replaying = false, bool firstMove = false}) {
    final pathChange = state.currentPath != path;
    final newNode = _gameTree.branchAt(path).view;
    final sanMove = newNode.sanMove;
    if (!replaying) {
      final isForward = path.size > state.currentPath.size;
      if (isForward) {
        final isCheck = sanMove.isCheck;
        if (sanMove.isCapture) {
          ref.read(moveFeedbackServiceProvider).captureFeedback(check: isCheck);
        } else {
          ref.read(moveFeedbackServiceProvider).moveFeedback(check: isCheck);
        }
      }
    } else {
      // when replaying moves fast we don't want haptic feedback
      final soundService = ref.read(soundServiceProvider);
      if (sanMove.isCapture) {
        soundService.play(Sound.capture);
      } else {
        soundService.play(Sound.move);
      }
    }
    state = state.copyWith(
      mode: firstMove ? PuzzleMode.play : state.mode,
      currentPath: path,
      node: newNode,
      lastMove: sanMove.move,
      promotionMove: null,
      shouldBlinkNextArrow: false,
    );

    if (pathChange) requestEval();
  }

  String makePgn() {
    final initPosition = _gameTree.nodeAt(state.initialPath).position;
    var currentPosition = initPosition;
    final pgnMoves = state.puzzle.puzzle.solution.fold<List<String>>([], (List<String> acc, move) {
      final moveObj = Move.parse(move);
      if (moveObj != null) {
        final String san;
        (currentPosition, san) = currentPosition.makeSan(moveObj);
        return acc..add(san);
      }
      return acc;
    });
    final pgn =
        '[FEN "${initPosition.fen}"][Site "${lichessUri('/training/${state.puzzle.puzzle.id}')}"]${pgnMoves.join(' ')}';
    return pgn;
  }

  void _addMove(Move move) {
    final (newPath, _) = _gameTree.addMoveAt(
      state.currentPath,
      move,
      prepend: state.mode == PuzzleMode.play,
    );
    if (newPath != null) {
      _setPath(newPath);
    }
  }

  void _mergeSolution() {
    final initialNode = _gameTree.nodeAt(state.initialPath);
    final (_, newNodes) = state.puzzle.puzzle.solution.foldIndexed(
      (initialNode.position, IList<Branch>(const [])),
      (index, previous, uci) {
        final move = Move.parse(uci);
        final (pos, nodes) = previous;
        final (newPos, newSan) = pos.makeSan(move!);
        return (newPos, nodes.add(Branch(position: newPos, sanMove: SanMove(newSan, move))));
      },
    );
    _gameTree.addNodesAt(state.initialPath, newNodes, prepend: true);
  }
}

enum PuzzleMode { load, play, view }

enum PuzzleResult { win, lose }

enum PuzzleFeedback { good, bad }

@freezed
class PuzzleState with _$PuzzleState implements EvaluationMixinState {
  const PuzzleState._();

  const factory PuzzleState({
    required Puzzle puzzle,
    required PuzzleGlicko? glicko,
    required PuzzleMode mode,
    required Position initialPosition,
    required UciPath initialPath,
    required UciPath currentPath,
    required Side pov,
    required ViewBranch node,
    Move? lastMove,
    NormalMove? promotionMove,
    PuzzleResult? result,
    PuzzleFeedback? feedback,
    required bool hintShown,
    Square? hintSquare,
    required bool resultSent,
    required bool isChangingDifficulty,
    required bool shouldBlinkNextArrow,
    PuzzleContext? nextContext,
    PuzzleStreak? streak,
    // if the automatic attempt to fetch the next puzzle in the streak fails
    // we will make the user retry
    required bool nextPuzzleStreakFetchError,
    required bool nextPuzzleStreakFetchIsRetrying,
  }) = _PuzzleState;

  @override
  bool isEngineAvailable(EngineEvaluationPrefState prefs) =>
      mode == PuzzleMode.view && prefs.isEnabled;

  @override
  EvaluationContext get evaluationContext =>
      EvaluationContext(variant: Variant.standard, initialPosition: initialPosition);

  @override
  Position get currentPosition => node.position;

  String get fen => node.position.fen;

  bool get canGoNext => mode == PuzzleMode.view && node.children.isNotEmpty;

  bool get canGoBack => mode == PuzzleMode.view && currentPath.size > initialPath.size;

  NormalMove get _nextSolutionMove =>
      NormalMove.fromUci(puzzle.puzzle.solution[currentPath.size - initialPath.size]);

  IMap<Square, ISet<Square>> get validMoves => makeLegalMoves(currentPosition);
}
