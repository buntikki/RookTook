import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rooktook/src/constants.dart';
import 'package:rooktook/src/model/tv/live_tv_channels.dart';
import 'package:rooktook/src/model/tv/tv_channel.dart';
import 'package:rooktook/src/styles/styles.dart';
import 'package:rooktook/src/utils/focus_detector.dart';
import 'package:rooktook/src/utils/navigation.dart';
import 'package:rooktook/src/view/watch/tv_screen.dart';
import 'package:rooktook/src/widgets/board_preview.dart';
import 'package:rooktook/src/widgets/platform_scaffold.dart';
import 'package:rooktook/src/widgets/user_full_name.dart';

class LiveTvChannelsScreen extends ConsumerWidget {
  const LiveTvChannelsScreen({super.key});

  static Route<dynamic> buildRoute(BuildContext context) {
    return buildScreenRoute(context, title: 'Lichess TV', screen: const LiveTvChannelsScreen());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FocusDetector(
      onFocusRegained: () {
        ref.read(liveTvChannelsProvider.notifier).startWatching();
      },
      onFocusLost: () {
        if (context.mounted) {
          ref.read(liveTvChannelsProvider.notifier).stopWatching();
        }
      },
      child: const PlatformScaffold(appBarTitle: Text('Lichess TV'), body: _Body()),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(liveTvChannelsProvider);
    return gamesAsync.when(
      data: (games) {
        final list = [
          for (final channel in TvChannel.values)
            if (games[channel] != null) games[channel]!,
        ];
        return ListView.builder(
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = list[index];
            return SmallBoardPreview(
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  TvScreen.buildRoute(
                    context,
                    game.channel,
                    gameId: game.id,
                    orientation: game.orientation,
                  ),
                );
              },
              orientation: game.orientation,
              fen: game.fen ?? kEmptyFen,
              lastMove: game.lastMove,
              description: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(game.channel.label, style: Styles.boardPreviewTitle),
                  Icon(game.channel.icon, color: ColorScheme.of(context).primary, size: 30),
                  UserFullNameWidget.player(
                    user: game.player.asPlayer.user,
                    aiLevel: game.player.asPlayer.aiLevel,
                    rating: game.player.rating,
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text(error.toString())),
    );
  }
}
