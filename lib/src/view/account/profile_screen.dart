import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rooktook/src/model/account/account_repository.dart';
import 'package:rooktook/src/model/game/game_history.dart';
import 'package:rooktook/src/styles/styles.dart';
import 'package:rooktook/src/utils/l10n_context.dart';
import 'package:rooktook/src/utils/navigation.dart';
import 'package:rooktook/src/view/account/edit_profile_screen.dart';
import 'package:rooktook/src/view/account/game_bookmarks_screen.dart';
import 'package:rooktook/src/view/user/perf_cards.dart';
import 'package:rooktook/src/view/user/recent_games.dart';
import 'package:rooktook/src/view/user/user_activity.dart';
import 'package:rooktook/src/view/user/user_profile.dart';
import 'package:rooktook/src/widgets/buttons.dart';
import 'package:rooktook/src/widgets/feedback.dart';
import 'package:rooktook/src/widgets/list.dart';
import 'package:rooktook/src/widgets/platform_scaffold.dart';
import 'package:rooktook/src/widgets/shimmer.dart';
import 'package:rooktook/src/widgets/user_full_name.dart';
import 'package:lottie/lottie.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  static Route<dynamic> buildRoute(BuildContext context) {
    return buildScreenRoute(context, screen: const ProfileScreen(), title: context.l10n.profile);
  }

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(accountProvider);
    return PlatformScaffold(
      appBarTitle: account.when(
        data:
            (user) =>
                user == null ? const SizedBox.shrink() : UserFullNameWidget(user: user.lightUser),
        loading: () => const SizedBox.shrink(),
        error: (error, _) => const SizedBox.shrink(),
      ),
      /*   appBarActions: [
        AppBarIconButton(
          icon: const Icon(Icons.edit),
          semanticsLabel: context.l10n.editProfile,
          onPressed: () => Navigator.of(context).push(EditProfileScreen.buildRoute(context)),
        ),
      ],*/
      body: account.when(
        data: (user) {
          if (user == null) {
            return Center(child: Text(context.l10n.mobileMustBeLoggedIn));
          }
          final recentGames = ref.watch(myRecentGamesProvider);
          final nbOfGames = ref.watch(userNumberOfGamesProvider(null)).valueOrNull ?? 0;
          return RefreshIndicator.adaptive(
            edgeOffset:
                Theme.of(context).platform == TargetPlatform.iOS
                    ? MediaQuery.paddingOf(context).top + 16.0
                    : 0,
            key: _refreshIndicatorKey,
            onRefresh: () async => ref.refresh(accountProvider),
            child:
                recentGames.value!.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Lottie.asset('assets/chess_puzzle.json', width: 160, height: 160),
                          const SizedBox(height: 20),
                          const Text(
                            'No Games Yet',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your recent games will appear here once you start playing.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    )
                    : ListView(
                      children: [
                        // UserProfileWidget(user: user),
                        const AccountPerfCards(),
                        if (user.count != null && user.count!.bookmark > 0)
                          ListSection(
                            hasLeading: true,
                            children: [
                              PlatformListTile(
                                title: Text(context.l10n.nbBookmarks(user.count!.bookmark)),
                                leading: const Icon(Icons.bookmarks_outlined),
                                onTap: () {
                                  Navigator.of(context).push(
                                    GameBookmarksScreen.buildRoute(
                                      context,
                                      nbBookmarks: user.count!.bookmark,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        const UserActivityWidget(),
                        RecentGamesWidget(
                          textColor: Colors.white,
                          color: const Color(0xff2B2D30),
                          titleColor: Colors.white,
                          tileColor: const Color(0xff2B2D30),
                          recentGames: recentGames,
                          nbOfGames: nbOfGames,
                          user: null,
                        ),
                      ],
                    ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) {
          return FullScreenRetryRequest(onRetry: () => ref.invalidate(accountProvider));
        },
      ),
    );
  }
}

class AccountPerfCards extends ConsumerWidget {
  const AccountPerfCards({this.padding});

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProvider);
    return account.when(
      data: (user) {
        if (user != null) {
          return PerfCards(user: user, isMe: true, padding: padding);
        } else {
          return const SizedBox.shrink();
        }
      },
      loading:
          () => Shimmer(
            child: Padding(
              padding: padding ?? Styles.bodySectionPadding,
              child: SizedBox(
                height: 106,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  separatorBuilder: (context, index) => const SizedBox(width: 10),
                  itemBuilder:
                      (context, index) => ShimmerLoading(
                        isLoading: true,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                ),
              ),
            ),
          ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}
