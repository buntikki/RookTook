import 'package:dartchess/dartchess.dart';
import 'package:rooktook/src/model/common/id.dart';

typedef FullEventTestClock =
    ({
      bool running,
      Duration initial,
      Duration increment,
      Duration? emerg,
      Duration white,
      Duration black,
    });

typedef FullEventTestCorrespondenceClock = ({Duration white, Duration black, int daysPerTurn});

String makeFullEvent(
  GameId id,
  String pgn, {
  required String whiteUserName,
  required String blackUserName,
  int socketVersion = 0,
  Side? youAre,
  FullEventTestClock? clock = const (
    running: false,
    initial: Duration(minutes: 3),
    increment: Duration(seconds: 2),
    emerg: Duration(seconds: 30),
    white: Duration(minutes: 3),
    black: Duration(minutes: 3),
  ),
  FullEventTestCorrespondenceClock? correspondenceClock,
}) {
  final youAreStr = youAre != null ? '"youAre": "${youAre.name}",' : '';
  final clockStr =
      clock != null
          ? '''
    "clock": {
      "running": ${clock.running},
      "initial": ${clock.initial.inSeconds},
      "increment": ${clock.increment.inSeconds},
      "white": ${(clock.white.inMilliseconds / 1000).toStringAsFixed(2)},
      "black": ${(clock.black.inMilliseconds / 1000).toStringAsFixed(2)},
      "emerg": 30,
      "moretime": 15
    },
'''
          : '';

  final correspondenceClockStr =
      correspondenceClock != null
          ? '''
    "correspondence": {
      "daysPerTurn": ${correspondenceClock.daysPerTurn},
      "white": ${(correspondenceClock.white.inMilliseconds / 1000).toStringAsFixed(2)},
      "black": ${(correspondenceClock.black.inMilliseconds / 1000).toStringAsFixed(2)}
    },
'''
          : '';

  return '''
{
  "t": "full",
  "d": {
    "game": {
      "id": "$id",
        "variant": {
          "key": "standard",
          "name": "Standard",
          "short": "Std"
        },
        "speed": "${clock != null ? 'blitz' : 'correspondence'}",
        "perf": "${clock != null ? 'blitz' : 'correspondence'}",
        "rated": false,
        "source": "lobby",
        "status": {
          "id": 20,
          "name": "started"
        },
        "createdAt": 1685698678928,
        "pgn": "$pgn"
    },
    "white": {
      "user": {
        "name": "$whiteUserName",
        "patron": true,
        "id": "${whiteUserName.toLowerCase()}"
      },
      "rating": 1806,
      "provisional": true,
      "onGame": true
    },
    "black": {
      "user": {
        "name": "$blackUserName",
        "patron": true,
        "id": "${blackUserName.toLowerCase()}"
      },
      "onGame": true
    },
    $clockStr
    $correspondenceClockStr
    $youAreStr
    "socket": $socketVersion,
    "expiration": {
      "idleMillis": 245,
      "millisToMove": 30000
    },
    "chat": {
      "lines": [
        {
          "u": "Zidrox",
          "t": "Good luck",
          "f": "people.man-singer"
        },
        {
          "u": "lichess",
          "t": "Takeback accepted",
          "f": "activity.lichess"
        }
      ]
    }
  },
  "v": $socketVersion
}
''';
}
