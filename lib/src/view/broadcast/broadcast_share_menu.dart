import 'package:flutter/widgets.dart';
import 'package:rooktook/src/model/broadcast/broadcast.dart';
import 'package:rooktook/src/network/http.dart';
import 'package:rooktook/src/utils/share.dart';
import 'package:rooktook/src/widgets/adaptive_action_sheet.dart';

Future<void> showBroadcastShareMenu(
  BuildContext context,
  Broadcast broadcast,
) async => showAdaptiveActionSheet<void>(
  context: context,
  actions: [
    BottomSheetAction(
      makeLabel: (context) => Text(broadcast.title),
      onPressed: () async {
        launchShareDialog(
          context,
          uri: lichessUri('/broadcast/${broadcast.tour.slug}/${broadcast.tour.id}'),
        );
      },
    ),
    BottomSheetAction(
      makeLabel: (context) => Text(broadcast.round.name),
      onPressed: () async {
        launchShareDialog(
          context,
          uri: lichessUri(
            '/broadcast/${broadcast.tour.slug}/${broadcast.round.slug}/${broadcast.round.id}',
          ),
        );
      },
    ),
    BottomSheetAction(
      makeLabel: (context) => Text('${broadcast.round.name} PGN'),
      onPressed: () async {
        launchShareDialog(
          context,
          uri: lichessUri(
            '/broadcast/${broadcast.tour.slug}/${broadcast.round.slug}/${broadcast.round.id}.pgn',
          ),
        );
      },
    ),
  ],
);
