import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rooktook/src/model/account/account_repository.dart';
import 'package:rooktook/src/model/common/perf.dart';
import 'package:rooktook/src/model/game/archived_game.dart';
import 'package:rooktook/src/model/user/user.dart';
import 'package:rooktook/src/model/user/user_repository_providers.dart';
import 'package:rooktook/src/network/connectivity.dart';
import 'package:rooktook/src/styles/styles.dart';
import 'package:rooktook/src/utils/l10n_context.dart';
import 'package:rooktook/src/view/common/container_clipper.dart';
import 'package:rooktook/src/view/game/game_list_tile.dart';
import 'package:rooktook/src/view/user/game_history_screen.dart';
import 'package:rooktook/src/widgets/buttons.dart';
import 'package:rooktook/src/widgets/list.dart';
import 'package:rooktook/src/widgets/shimmer.dart';

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
    this.color,
    this.textColor,
    this.tileColor,
    this.titleColor,
    super.key,
  });

  final LightUser? user;
  final AsyncValue<IList<LightArchivedGameWithPov>> recentGames;
  final int nbOfGames;
  final int maxGamesToShow;
  final Color? color;
  final Color? textColor;
  final Color? tileColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityChangesProvider);
    final activity =
        user != null
            ? ref.watch(userActivityProvider(id: user!.id))
            : ref.watch(accountActivityProvider);

    // Safely extract ratings from activity
    List<int?> getRatingsFromActivity() {
      if (activity.valueOrNull == null) return [];

      final nonEmptyActivities =
          activity.valueOrNull!.where((entry) => entry.isNotEmpty && entry.games != null).toList();

      if (nonEmptyActivities.isEmpty) return [];

      final ratings = <int?>[];

      for (final activityEntry in nonEmptyActivities) {
        if (activityEntry.games == null) continue;

        for (final gameEntry in activityEntry.games!.entries) {
          if (gameEntry.value.ratingAfter != null) {
            ratings.add(gameEntry.value.ratingAfter);
          }
        }
      }

      return ratings;
    }

    final ratings = getRatingsFromActivity();

    return recentGames.when(
      data: (data) {
        //final list = data.take(maxGamesToShow);

        final filtered =
            data
                .where((item) => item.game.perf == Perf.rapid || item.game.perf == Perf.blitz)
                .toList();

        final list = filtered.take(maxGamesToShow).toList();
        if (list.isEmpty) {
          return const SizedBox.shrink();
        }
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color ?? const Color(0xffF4F4F4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
                child: Text(
                  'Recent Games',
                  style: TextStyle(
                    color: textColor ?? Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...List.generate(list.length, (i) {
                return GameListTile(
                  item: list[i],
                  tileColor: tileColor,
                  titleColor: titleColor,
                  rating: i < ratings.length ? ratings[i] : null,
                );
              }),
              /*for (int i = 0; i < list.length; i++)
                GameListTile(
                  item: list.elementAt(i),
                  tileColor: tileColor,
                  titleColor: titleColor,
                  rating: i < ratings.length ? ratings[i] : null,
                ),*/
              const SizedBox(height: 10),
            ],
          ),
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
