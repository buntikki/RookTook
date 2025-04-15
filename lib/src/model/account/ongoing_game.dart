import 'package:dartchess/dartchess.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rooktook/src/model/common/chess.dart';
import 'package:rooktook/src/model/common/id.dart';
import 'package:rooktook/src/model/common/perf.dart';
import 'package:rooktook/src/model/common/speed.dart';
import 'package:rooktook/src/model/user/user.dart';

part 'ongoing_game.freezed.dart';

@freezed
class OngoingGame with _$OngoingGame {
  factory OngoingGame({
    required GameId id,
    required GameFullId fullId,
    required Side orientation,
    required String fen,
    required Perf perf,
    required Speed speed,
    required Variant variant,
    LightUser? opponent,
    required bool isMyTurn,
    int? opponentRating,
    int? opponentAiLevel,
    Move? lastMove,
    int? secondsLeft,
  }) = _OngoingGame;
}
