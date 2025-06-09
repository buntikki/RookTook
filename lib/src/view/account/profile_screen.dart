import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rooktook/src/model/account/account_repository.dart';
import 'package:rooktook/src/model/game/game_history.dart';
import 'package:rooktook/src/styles/styles.dart';
import 'package:rooktook/src/utils/l10n_context.dart';
import 'package:rooktook/src/utils/navigation.dart';
import 'package:rooktook/src/view/account/edit_profile_screen.dart';
import 'package:rooktook/src/view/account/game_bookmarks_screen.dart';
import 'package:rooktook/src/view/tournament/pages/tournament_card.dart';
import 'package:rooktook/src/view/tournament/provider/tournament_provider.dart';
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

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  final List<String> tabs = ['1v1 Games', 'Tournaments'];

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(accountProvider);
    final tournament = ref.watch(fetchUserTournamentsProvider);
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
      body: Column(
        spacing: 8,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF2B2D30),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xff464a4f), width: .5),
            ),
            child: TabBar(
              indicatorWeight: 0,
              indicatorPadding: const EdgeInsets.all(4),
              dividerHeight: 0,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              controller: _tabController,
              labelColor: Colors.black,
              labelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: GoogleFonts.bricolageGrotesque().fontFamily,
              ),
              tabs: List.generate(tabs.length, (index) {
                return Tab(text: tabs[index]);
              }),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                account.when(
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
                              ? Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Lottie.asset(
                                        'assets/chess_puzzle.json',
                                        width: 160,
                                        height: 160,
                                      ),
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
                                ),
                              )
                              : ListView(
                                children: [
                                  // UserProfileWidget(user: user),
                                  // const AccountPerfCards(),
                                  if (user.count != null && user.count!.bookmark > 0)
                                    ListSection(
                                      hasLeading: true,
                                      children: [
                                        PlatformListTile(
                                          title: Text(
                                            context.l10n.nbBookmarks(user.count!.bookmark),
                                          ),
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
                tournament.when(
                  data: (tournaments) {
                    final List<Tournament> endedTournaments =
                        tournaments
                            .where(
                              (element) => DateTime.fromMillisecondsSinceEpoch(
                                element.endTime,
                              ).isBefore(DateTime.now()),
                            )
                            .toList()
                            .reversed
                            .toList();
                    return RefreshIndicator.adaptive(
                      onRefresh: () async {
                        ref.invalidate(fetchUserTournamentsProvider);
                      },
                      child:
                          endedTournaments.isEmpty
                              ? const Center(child: Text('No tournaments right now'))
                              : ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: endedTournaments.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final tournament = endedTournaments[index];
                                  return TournamentCard(
                                    tournament: tournament,
                                    isShowJoinedTag: false,
                                    index: index,
                                    isEnded: true,
                                  );
                                },
                              ),
                    );
                  },
                  error: (error, stackTrace) => Center(child: Text('$error')),
                  loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                ),
              ],
            ),
          ),
        ],
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
