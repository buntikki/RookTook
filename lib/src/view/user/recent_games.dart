import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/game/archived_game.dart';
import 'package:lichess_mobile/src/model/user/user.dart';
import 'package:lichess_mobile/src/network/connectivity.dart';
import 'package:lichess_mobile/src/styles/styles.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/view/game/game_list_tile.dart';
import 'package:lichess_mobile/src/view/user/game_history_screen.dart';
import 'package:lichess_mobile/src/widgets/buttons.dart';
import 'package:lichess_mobile/src/widgets/list.dart';
import 'package:lichess_mobile/src/widgets/shimmer.dart';

/// A widget that show a list of recent games.
///
/// The [user] should be provided only if the games are for a specific user. If the
/// games are for the current logged in user, the [user] should be null.
class RecentGamesWidget extends ConsumerWidget {
  const RecentGamesWidget({
    required this.recentGames,
    required this.user,
    required this.nbOfGames,
    this.maxGamesToShow = 10,
    super.key,
  });

  final LightUser? user;
  final AsyncValue<IList<LightArchivedGameWithPov>> recentGames;
  final int nbOfGames;
  final int maxGamesToShow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityChangesProvider);

    return recentGames.when(
      data: (data) {
        if (data.isEmpty) {
          return const SizedBox.shrink();
        }
        final list = data.take(maxGamesToShow);
        return Container(
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(color:Color(0xffF4F4F4), borderRadius: BorderRadius.circular(12)),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.recentGames,
                        style: const TextStyle(color: Colors.black, fontSize: 18),
                      ),
                      Container(
                        child:
                            nbOfGames > list.length
                                ? NoPaddingTextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      GameHistoryScreen.buildRoute(
                                        context,
                                        user: user,
                                        isOnline: connectivity.valueOrNull?.isOnline == true,
                                      ),
                                    );
                                  },
                                  child: Text(context.l10n.more),
                                )
                                : null,
                      ),
                    ],
                  ),
                ),
                for (final item in list) GameListTile(item: item),
                SizedBox(height: 10),
              ],
            ),
          ),

          // ListSection(
          //   backgroundColor: Colors.white,
          //   header: Text(context.l10n.recentGames, style: TextStyle(color: Colors.black)),
          //   hasLeading: true,
          //   headerTrailing:
          //       nbOfGames > list.length
          //           ? NoPaddingTextButton(
          //             onPressed: () {
          //               Navigator.of(context).push(
          //                 GameHistoryScreen.buildRoute(
          //                   context,
          //                   user: user,
          //                   isOnline: connectivity.valueOrNull?.isOnline == true,
          //                 ),
          //               );
          //             },
          //             child: Text(context.l10n.more),
          //           )
          //           : null,
          //   children: [for (final item in list) GameListTile(item: item)],
          // ),
        );
      },
      error: (error, stackTrace) {
        debugPrint('SEVERE: [RecentGames] could not recent games; $error\n$stackTrace');
        return const Padding(
          padding: Styles.bodySectionPadding,
          child: Text('Could not load recent games.'),
        );
      },
      loading:
          () => Shimmer(
            child: ShimmerLoading(
              isLoading: true,
              child: ListSection.loading(itemsNumber: 10, header: true, hasLeading: true),
            ),
          ),
    );
  }
}
