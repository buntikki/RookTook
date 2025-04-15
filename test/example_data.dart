import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:rooktook/src/model/common/chess.dart';
import 'package:rooktook/src/model/common/id.dart';
import 'package:rooktook/src/model/common/perf.dart';
import 'package:rooktook/src/model/common/speed.dart';
import 'package:rooktook/src/model/game/archived_game.dart';
import 'package:rooktook/src/model/game/game.dart';
import 'package:rooktook/src/model/game/game_status.dart';
import 'package:rooktook/src/model/game/material_diff.dart';
import 'package:rooktook/src/model/game/player.dart';
import 'package:rooktook/src/model/user/user.dart';

List<ArchivedGame> generateArchivedGames({int count = 100, String? username}) {
  return List.generate(count, (index) {
    final id = GameId('game${index.toString().padLeft(4, '0')}');
    final whitePlayer = Player(
      user:
          username != null && index.isEven
              ? LightUser(id: UserId.fromUserName(username), name: username)
              : username != null
              ? const LightUser(id: UserId('whiteId'), name: 'White')
              : null,
      rating: username != null ? 1500 : null,
    );
    final blackPlayer = Player(
      user:
          username != null && index.isOdd
              ? LightUser(id: UserId.fromUserName(username), name: username)
              : username != null
              ? const LightUser(id: UserId('blackId'), name: 'Black')
              : null,
      rating: username != null ? 1500 : null,
    );
    return ArchivedGame(
      id: id,
      meta: GameMeta(
        createdAt: DateTime(2021, 1, 1),
        rated: true,
        perf: Perf.correspondence,
        speed: Speed.correspondence,
        variant: Variant.standard,
      ),
      source: GameSource.lobby,
      data: LightArchivedGame(
        id: id,
        variant: Variant.standard,
        lastMoveAt: DateTime(2021, 1, 1),
        createdAt: DateTime(2021, 1, 1),
        perf: Perf.blitz,
        speed: Speed.blitz,
        rated: true,
        status: GameStatus.started,
        white: whitePlayer,
        black: blackPlayer,
        clock: (initial: const Duration(minutes: 2), increment: const Duration(seconds: 3)),
      ),
      steps: _makeSteps('e4 Nc6 Bc4 e6 a3 g6 Nf3 Bg7 c3 Nge7 d3 O-O Be3 Na5 Ba2 b6 Qd2'),
      status: GameStatus.started,
      white: whitePlayer,
      black: blackPlayer,
      youAre:
          username != null
              ? index.isEven
                  ? Side.white
                  : Side.black
              : null,
    );
  });
}

IList<GameStep> _makeSteps(String pgn) {
  Position position = Chess.initial;
  final steps = <GameStep>[GameStep(position: position)];
  for (final san in pgn.split(' ')) {
    final move = position.parseSan(san)!;
    position = position.play(move);
    steps.add(
      GameStep(
        position: position,
        sanMove: SanMove(san, move),
        diff: MaterialDiff.fromBoard(position.board),
      ),
    );
  }
  return steps.toIList();
}
