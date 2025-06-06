import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rooktook/src/constants.dart';
import 'package:rooktook/src/model/account/account_repository.dart';
import 'package:rooktook/src/model/account/ongoing_game.dart';
import 'package:rooktook/src/model/auth/auth_controller.dart';
import 'package:rooktook/src/model/auth/auth_session.dart';
import 'package:rooktook/src/model/challenge/challenges.dart';
import 'package:rooktook/src/model/common/perf.dart';
import 'package:rooktook/src/model/common/time_increment.dart';
import 'package:rooktook/src/model/correspondence/correspondence_game_storage.dart';
import 'package:rooktook/src/model/correspondence/offline_correspondence_game.dart';
import 'package:rooktook/src/model/game/archived_game.dart';
import 'package:rooktook/src/model/game/game_history.dart';
import 'package:rooktook/src/model/lobby/game_seek.dart';
import 'package:rooktook/src/model/puzzle/puzzle.dart';
import 'package:rooktook/src/model/puzzle/puzzle_angle.dart';
import 'package:rooktook/src/model/puzzle/puzzle_controller.dart';
import 'package:rooktook/src/model/puzzle/puzzle_providers.dart';
import 'package:rooktook/src/model/puzzle/puzzle_service.dart';
import 'package:rooktook/src/model/puzzle/puzzle_theme.dart';
import 'package:rooktook/src/model/settings/home_preferences.dart';
import 'package:rooktook/src/model/user/user.dart';
import 'package:rooktook/src/model/user/user_repository_providers.dart';
import 'package:rooktook/src/navigation.dart';
import 'package:rooktook/src/network/connectivity.dart';
import 'package:rooktook/src/styles/lichess_icons.dart';
import 'package:rooktook/src/styles/styles.dart';
import 'package:rooktook/src/utils/l10n.dart';
import 'package:rooktook/src/utils/l10n_context.dart';
import 'package:rooktook/src/utils/screen.dart';
import 'package:rooktook/src/view/account/new_profile_screen.dart';
import 'package:rooktook/src/view/account/profile_screen.dart';
import 'package:rooktook/src/view/common/container_clipper.dart';
import 'package:rooktook/src/view/correspondence/offline_correspondence_game_screen.dart';
import 'package:rooktook/src/view/game/game_screen.dart';
import 'package:rooktook/src/view/game/offline_correspondence_games_screen.dart';
import 'package:rooktook/src/view/home/games_carousel.dart';
import 'package:rooktook/src/view/over_the_board/over_the_board_screen.dart';
import 'package:rooktook/src/view/play/create_game_options.dart';
import 'package:rooktook/src/view/play/ongoing_games_screen.dart';
import 'package:rooktook/src/view/play/play_screen.dart';
import 'package:rooktook/src/view/play/quick_game_button.dart';
import 'package:rooktook/src/view/puzzle/puzzle_screen.dart';
import 'package:rooktook/src/view/puzzle/puzzle_tab_screen.dart';
import 'package:rooktook/src/view/tournament/pages/tournament_screen.dart';
import 'package:rooktook/src/view/user/challenge_requests_screen.dart';
import 'package:rooktook/src/view/user/player_screen.dart';
import 'package:rooktook/src/view/user/recent_games.dart';
import 'package:rooktook/src/view/wallet/presentation/wallet_page.dart';
import 'package:rooktook/src/view/wallet/provider/wallet_provider.dart';
import 'package:rooktook/src/widgets/buttons.dart';
import 'package:rooktook/src/widgets/feedback.dart';
import 'package:rooktook/src/widgets/match_result_popup.dart';
import 'package:rooktook/src/widgets/user_full_name.dart';
import 'package:random_avatar/random_avatar.dart';

final editModeProvider = StateProvider<bool>((ref) => false);

class HomeTabScreen extends ConsumerStatefulWidget {
  const HomeTabScreen({super.key});

  @override
  ConsumerState<HomeTabScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeTabScreen> with RouteAware {
  final _androidRefreshKey = GlobalKey<RefreshIndicatorState>();

  bool wasOnline = true;
  bool hasRefreshed = false;

  @override
  void initState() {
    super.initState();

    // Listen for changes in session or account and refresh perf stats
    Future.microtask(() {
      final session = ref.read(authSessionProvider);
      if (session != null) {
        ref.invalidate(userPerfStatsProvider(id: session.user.id, perf: Perf.rapid));
        ref.invalidate(userPerfStatsProvider(id: session.user.id, perf: Perf.blitz));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(connectivityChangesProvider, (_, connectivity) {
      // Refresh the data only once if it was offline and is now online
      if (!connectivity.isRefreshing && connectivity.hasValue) {
        final isNowOnline = connectivity.value!.isOnline;

        if (!hasRefreshed && !wasOnline && isNowOnline) {
          hasRefreshed = true;
          _refreshData(isOnline: isNowOnline);
        }

        wasOnline = isNowOnline;
      }
    });

    final connectivity = ref.watch(connectivityChangesProvider);
    // final isEditing = ref.watch(editModeProvider);
    final userSession = ref.watch(authSessionProvider);
    final String avatarSeed = userSession?.user.name ?? 'default';
    return connectivity.when(
      skipLoadingOnReload: true,
      data: (status) {
        final session = ref.watch(authSessionProvider);
        final account = ref.watch(accountProvider);

        const puzzlePerfsSet = {Perf.blitz, Perf.rapid, Perf.puzzle};

        const userPerfs = puzzlePerfsSet;

        const perf = userPerfs;
        // print(userPerfs);
        final rapid =
            session == null
                ? null
                : ref.watch(
                  userPerfStatsProvider(
                    id: session!.user.id,
                    perf: perf.where((e) => e.title == 'Rapid').first,
                  ),
                );
        final puzzle = account.value?.perfs[Perf.puzzle];
        final blitz =
            session == null
                ? null
                : ref.watch(
                  userPerfStatsProvider(
                    id: session!.user.id,
                    perf: perf.where((e) => e.title == 'Blitz').first,
                  ),
                );

        final ongoingGames = ref.watch(ongoingGamesProvider);
        final offlineCorresGames = ref.watch(offlineOngoingCorrespondenceGamesProvider);
        final recentGames = ref.watch(myRecentGamesProvider);
        final nbOfGames = ref.watch(userNumberOfGamesProvider(null)).valueOrNull ?? 0;
        final isTablet = isTabletOrLarger(context);
        // Show the welcome screen if not logged in and there are no recent games and no stored games
        // (i.e. first installation, or the user has never played a game)
        final shouldShowWelcomeScreen =
            session == null &&
            recentGames.maybeWhen(data: (data) => data.isEmpty, orElse: () => false);
        // final puzzlePr = ref.watch(nextPuzzleProvider(const PuzzleTheme(PuzzleThemeKey.mix)));

        // final ctrlProvider = puzzleControllerProvider(puzzlePr.value!);
        // final puzzleState = ref.watch(ctrlProvider);
        final puzzleRank = puzzle?.rating ?? 1500;
        // final puzzleRank = 1750;
        final widgets =
            shouldShowWelcomeScreen
                ? _welcomeScreenWidgets(
                  puzzleRank: puzzleRank,
                  session: session,
                  status: status,
                  isTablet: isTablet,
                  rapidRank:
                      session != null
                          ? rapid!.value != null
                              ? rapid.value!.rating.toInt()
                              : 0
                          : 0,
                  blitzRank:
                      session != null
                          ? blitz!.value != null
                              ? blitz.value!.rating.toInt()
                              : 0
                          : 0,
                  recentGames: recentGames,
                  nbOfGames: nbOfGames,
                )
                : isTablet
                ? _tabletWidgets(
                  session: session,
                  status: status,
                  ongoingGames: ongoingGames,
                  offlineCorresGames: offlineCorresGames,
                  recentGames: recentGames,
                  nbOfGames: nbOfGames,
                )
                : _welcomeScreenWidgets(
                  puzzleRank: puzzleRank,
                  rapidRank:
                      session != null
                          ? rapid!.value != null
                              ? rapid.value!.rating.toInt()
                              : 0
                          : 0,
                  blitzRank:
                      session != null
                          ? blitz!.value != null
                              ? blitz.value!.rating.toInt()
                              : 0
                          : 0,
                  session: session,
                  status: status,
                  isTablet: isTablet,
                  recentGames: recentGames,
                  nbOfGames: nbOfGames,
                );
        // _handsetWidgets(
        //   session: session,
        //   status: status,
        //   ongoingGames: ongoingGames,
        //   offlineCorresGames: offlineCorresGames,
        //   recentGames: recentGames,
        //   nbOfGames: nbOfGames,
        // );

        // if (Theme.of(context).platform == TargetPlatform.iOS) {
        //   return Scaffold(
        //     body: Stack(
        //       alignment: Alignment.bottomCenter,
        //       children: [
        //         CustomScrollView(
        //           controller: homeScrollController,
        //           slivers: [
        //             SliverAppBar(
        //               actions: [
        //                 IconButton(
        //                   onPressed: () {
        //                     ref.read(editModeProvider.notifier).state = !isEditing;
        //                   },
        //                   icon: Icon(isEditing ? Icons.save_outlined : Icons.app_registration),
        //                   tooltip: isEditing ? 'Save' : 'Edit',
        //                 ),

        //                 const _PlayerScreenButton(),
        //               ],
        //             ),
        //             // CupertinoSliverNavigationBar(
        //             //   padding: const EdgeInsetsDirectional.only(start: 16.0, end: 8.0),

        //             //   leading: CupertinoButton(
        //             //     alignment: Alignment.centerLeft,
        //             //     padding: EdgeInsets.zero,
        //             //     onPressed: () {
        //             //       ref.read(editModeProvider.notifier).state = !isEditing;
        //             //     },
        //             //     child: Text(isEditing ? 'Done' : 'Edit'),
        //             //   ),
        //             //   trailing: const Row(
        //             //     mainAxisSize: MainAxisSize.min,
        //             //     children: [_ChallengeScreenButton(), _PlayerScreenButton()],
        //             //   ),
        //             // ),
        //             CupertinoSliverRefreshControl(
        //               onRefresh: () => _refreshData(isOnline: status.isOnline),
        //             ),
        //             const SliverToBoxAdapter(child: ConnectivityBanner()),
        //             SliverSafeArea(
        //               top: false,
        //               sliver: SliverList(
        //                 delegate: SliverChildListDelegate([
        //                   Padding(
        //                     padding: const EdgeInsets.all(12.0),
        //                     child: Text(
        //                       'A Platform for\nnext level chess',
        //                       textAlign: TextAlign.start,
        //                       style: Theme.of(context).textTheme.headlineMedium!.merge(
        //                         const TextStyle(fontWeight: FontWeight.w600),
        //                       ),
        //                     ),
        //                   ),
        //                   ...widgets,
        //                 ]),
        //               ),
        //             ),
        //           ],
        //         ),
        //         if (getScreenType(context) == ScreenType.handset)
        //           Positioned(
        //             bottom: MediaQuery.paddingOf(context).bottom + 16.0,
        //             right: 8.0,
        //             child: FloatingActionButton.extended(
        //               onPressed: () {
        //                 Navigator.of(context).push(PlayScreen.buildRoute(context));
        //               },
        //               icon: const Icon(Icons.add),
        //               label: Text(context.l10n.play),
        //             ),
        //           ),
        //       ],
        //     ),
        //   );
        // } else {
        return Scaffold(
          appBar: AppBar(
            title: const Text(''),
            automaticallyImplyLeading: false,
            actions: [
              // IconButton(
              //   onPressed: () {
              //     ref.read(editModeProvider.notifier).state = !isEditing;
              //   },
              //   icon: Icon(isEditing ? Icons.save_outlined : Icons.app_registration),
              //   tooltip: isEditing ? 'Save' : 'Edit',
              // ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WalletPage()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xff2B2D30),
                    border: Border.all(color: const Color(0xff464A4F)),
                  ),
                  child: SvgPicture.asset('assets/images/svg/wallet.svg', height: 20),
                ),
              ),
              // const _PlayerScreenButton(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    // Navigate to profile screen
                    Navigator.of(context).push(NewProfileScreen.buildRoute(context));
                  },
                  borderRadius: BorderRadius.circular(
                    18,
                  ), // Half of width/height to make it circular
                  child: Center(
                    child: RandomAvatar(avatarSeed, height: 36, width: 36),
                    // Image.asset(
                    //   'assets/images/avatar.png', // Replace with your asset or use network image
                    //   fit: BoxFit.cover,
                    //   height: 36,
                    //   width: 36,
                    //   errorBuilder: (context, error, stackTrace) {
                    //     return const Icon(Icons.person, color: Colors.black54, size: 24);
                    //   },
                    // ),
                  ),
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            key: _androidRefreshKey,
            onRefresh: () => _refreshData(isOnline: status.isOnline),
            child: Column(
              children: [
                const ConnectivityBanner(),
                Expanded(
                  child: ListView(
                    controller: homeScrollController,
                    children: [
                      // Padding(
                      //   padding: const EdgeInsets.all(12.0),
                      //   child: Text(
                      //     'A Platform for\nNext Level Chess',
                      //     textAlign: TextAlign.start,
                      //     style: Theme.of(context).textTheme.headlineMedium!.merge(
                      //       const TextStyle(fontWeight: FontWeight.w600),
                      //     ),
                      //   ),
                      // ),
                      ...widgets,
                    ],
                  ),
                ),
              ],
            ),
          ),
          /*  floatingActionButton:
              isTablet
                  ? null
                  : FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.of(context).push(PlayScreen.buildRoute(context));
                    },
                    icon: const Icon(Icons.add),
                    label: Text(context.l10n.play),
                  ),*/
        );

        // }
      },
      error: (_, __) => const CenterLoadingIndicator(),
      loading: () => const CenterLoadingIndicator(),
    );
  }

  List<Widget> _handsetWidgets({
    required AuthSessionState? session,
    required ConnectivityStatus status,
    required AsyncValue<IList<OngoingGame>> ongoingGames,
    required AsyncValue<IList<(DateTime, OfflineCorrespondenceGame)>> offlineCorresGames,
    required AsyncValue<IList<LightArchivedGameWithPov>> recentGames,
    required int nbOfGames,
  }) {
    final homePrefs = ref.watch(homePreferencesProvider);
    final hasOngoingGames =
        (status.isOnline &&
            ongoingGames.maybeWhen(data: (data) => data.isNotEmpty, orElse: () => false)) ||
        (!status.isOnline &&
            offlineCorresGames.maybeWhen(data: (data) => data.isNotEmpty, orElse: () => false));
    final list = [
      // _EditableWidget(
      //   widget: HomeEditableWidget.hello,
      //   shouldShow: true,
      //   index: homePrefs.enabledWidgets.indexOf(HomeEditableWidget.hello),
      //   child: const _HelloWidget(),
      // ),
      _EditableWidget(
        widget: HomeEditableWidget.perfCards,
        shouldShow: session != null && status.isOnline,
        index: homePrefs.enabledWidgets.indexOf(HomeEditableWidget.perfCards),
        child: AccountPerfCards(
          padding: Styles.horizontalBodyPadding.add(Styles.sectionBottomPadding),
        ),
      ),
      // _EditableWidget(
      //   widget: HomeEditableWidget.quickPairing,
      //   shouldShow: status.isOnline,
      //   index: homePrefs.enabledWidgets.indexOf(HomeEditableWidget.quickPairing),
      //   child: const Padding(padding: Styles.bodySectionPadding, child: QuickGameMatrix()),
      // ),
      _EditableWidget(
        widget: HomeEditableWidget.ongoingGames,
        shouldShow: hasOngoingGames,
        index: homePrefs.enabledWidgets.indexOf(HomeEditableWidget.ongoingGames),
        child:
            status.isOnline
                ? _OngoingGamesCarousel(ongoingGames, maxGamesToShow: 20)
                : _OfflineCorrespondenceCarousel(offlineCorresGames, maxGamesToShow: 20),
      ),
      _EditableWidget(
        widget: HomeEditableWidget.recentGames,
        index: homePrefs.enabledWidgets.indexOf(HomeEditableWidget.recentGames),
        shouldShow: true,
        child: RecentGamesWidget(
          recentGames: recentGames,
          nbOfGames: nbOfGames,
          user: session?.user,
        ),
      ),
    ].sortedBy((_EditableWidget widget) {
      final i = homePrefs.enabledWidgets.indexOf(widget.widget);
      return i != -1 ? i : HomeEditableWidget.values.length;
    });
    return [
      ...list,
      if (Theme.of(context).platform == TargetPlatform.iOS)
        const SizedBox(height: 70.0)
      else
        const SizedBox(height: 54.0),
    ];
  }

  List<Widget> _welcomeScreenWidgets({
    required AuthSessionState? session,
    required ConnectivityStatus status,
    required bool isTablet,
    required AsyncValue<IList<LightArchivedGameWithPov>> recentGames,
    required int nbOfGames,
    required int rapidRank,
    required int blitzRank,
    required int puzzleRank,
  }) {
    // fetch the account user to be sure we have the latest data (flair, etc.)
    final accountUser = ref
        .watch(accountProvider)
        .maybeWhen(data: (data) => data?.lightUser, orElse: () => null);

    final user = accountUser ?? session?.user;
    final welcomeWidgets = [
      /*Padding(
        padding: Styles.horizontalBodyPadding,
        child: LichessMessage(
          style:
              Theme.of(context).platform == TargetPlatform.iOS
                  ? const TextStyle(fontSize: 18)
                  : TextTheme.of(context).bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),*/
      const SizedBox(height: 8.0),
      Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton.icon(
          label: const Text(
            'QUICK PLAY',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14.0),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff54C339),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () async {
            showModalBottomSheet(
              context: context,
              backgroundColor: const Color(0xff2B2D30),
              isScrollControlled: true,
              showDragHandle: true,
              useSafeArea: true,
              builder: (BuildContext context) => const GameTypeBottomSheet(),
            );
          },
        ),
      ),
      const SizedBox(height: 24),
      const HomeTournamentContainer(),
      const SizedBox(height: 8),
      InkWell(
        onTap: () {
          Navigator.of(
            context,
            rootNavigator: true,
          ).push(MaterialPageRoute(builder: (context) => const PuzzleTabScreen()));
        },
        child: ChessPuzzleScreen(puzzleRank: puzzleRank),
      ),
      Center(child: SvgPicture.asset('assets/images/svg/footer.svg')),
      // RecentGamesWidget(
      //   recentGames: recentGames,
      //   nbOfGames: nbOfGames,
      //   user: session?.user,
      //   maxGamesToShow: 5,
      // ),
      // if (session == null) ...[
      //   const Center(child: _SignInWidget()),
      //   const SizedBox(height: 16.0),
      //   Container(
      //     padding: const EdgeInsets.symmetric(horizontal: 16),
      //     child: GoogleSignInButton(
      //       onSignInError: (e) {
      //         print(e);
      //       },
      //       onSignInSuccess: (credentials) {
      //         print(credentials);
      //       },
      //     ),
      //   ),
      //   const SizedBox(height: 16.0),
      //   Container(
      //     padding: const EdgeInsets.symmetric(horizontal: 16),
      //     child: AppleSignInButton(
      //       onSignInError: (e) {
      //         print(e);
      //       },
      //       onSignInSuccess: (credentials) {
      //         print(credentials);
      //       },
      //     ),
      //   ),
      // ],
      /*if (Theme.of(context).platform != TargetPlatform.iOS &&
          (session == null || session.user.isPatron != true)) ...[
        Center(
          child: SecondaryButton(
            semanticsLabel: context.l10n.patronDonate,
            onPressed: () {
              launchUrl(Uri.parse('https://lichess.org/patron'));
            },
            child: Text(context.l10n.patronDonate),
          ),
        ),
        const SizedBox(height: 16.0),
      ],
      Center(
        child: SecondaryButton(
          semanticsLabel: context.l10n.aboutX('Lichess...'),
          onPressed: () {
            launchUrl(Uri.parse('https://lichess.org/about'));
          },
          child: Text(context.l10n.aboutX('Lichess...')),
        ),
      ),*/
    ];

    return [
      if (isTablet)
        Row(
          children: [
            const Flexible(child: _TabletCreateAGameSection()),
            Flexible(child: Column(children: welcomeWidgets)),
          ],
        )
      else ...[
        ChessRatingCards(rapidRank: '$rapidRank', blitzRank: '$blitzRank'),
        // if (status.isOnline)
        //   const _EditableWidget(
        //     widget: HomeEditableWidget.quickPairing,
        //     shouldShow: true,
        //     child: Padding(padding: Styles.bodySectionPadding, child: QuickGameMatrix()),
        //   ),
        ...welcomeWidgets,
      ],
    ];
  }

  List<Widget> _tabletWidgets({
    required AuthSessionState? session,
    required ConnectivityStatus status,
    required AsyncValue<IList<OngoingGame>> ongoingGames,
    required AsyncValue<IList<(DateTime, OfflineCorrespondenceGame)>> offlineCorresGames,
    required AsyncValue<IList<LightArchivedGameWithPov>> recentGames,
    required int nbOfGames,
  }) {
    // fetch the account user to be sure we have the latest data (flair, etc.)
    final accountUser = ref
        .watch(accountProvider)
        .maybeWhen(data: (data) => data?.lightUser, orElse: () => null);

    final user = accountUser ?? session?.user;
    return [
      const _EditableWidget(
        widget: HomeEditableWidget.hello,
        shouldShow: true,
        child: _HelloWidget(),
      ),
      if (status.isOnline)
        _EditableWidget(
          widget: HomeEditableWidget.perfCards,
          shouldShow: session != null,
          child: const AccountPerfCards(padding: Styles.bodySectionPadding),
        ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              children: [
                const SizedBox(height: 8.0),
                const _TabletCreateAGameSection(),
                if (status.isOnline)
                  _OngoingGamesPreview(ongoingGames, maxGamesToShow: 5)
                else
                  _OfflineCorrespondencePreview(offlineCorresGames, maxGamesToShow: 5),
              ],
            ),
          ),
          // Flexible(
          //   child: Column(
          //     mainAxisSize: MainAxisSize.max,
          //     mainAxisAlignment: MainAxisAlignment.start,
          //     children: [
          //       const SizedBox(height: 8.0),
          //       RecentGamesWidget(
          //         recentGames: recentGames,
          //         nbOfGames: nbOfGames,
          //         user: session?.user,
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    ];
  }

  Future<void> _refreshData({required bool isOnline}) {
    return Future.wait([
      ref.refresh(myRecentGamesProvider.future),
      if (isOnline) ref.refresh(accountProvider.future),
      if (isOnline) ref.refresh(ongoingGamesProvider.future),
    ]);
  }
}

class HomeTournamentContainer extends ConsumerWidget {
  const HomeTournamentContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        handleTournamentBannerNavigation(ref);
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Image.asset('assets/images/home_tournament.png', fit: BoxFit.cover),
      ),
    );
  }
}

class ChessPuzzleScreen extends StatelessWidget {
  const ChessPuzzleScreen({super.key, required this.puzzleRank});
  final int puzzleRank;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xff2B2D30),
              border: Border.all(color: const Color(0xff464A4F), width: .5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Left side - Chess board
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset('assets/images/puzzle_board.png'),
                  ),
                ),

                // Right side - Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Solve Puzzles',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      // const Text(
                      //   'Continue Your Journey!',
                      //   style: TextStyle(fontSize: 12, color: Color(0xFF7E8899)),
                      // ),
                      const SizedBox(height: 8),
                      Row(
                        spacing: 8,
                        children: [
                          SvgPicture.asset('assets/images/svg/puzzle_rating.svg', height: 24),
                          Text('$puzzleRank', style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Arrow Icon in top right corner
          Positioned(
            top: 25,
            right: 25,
            child: Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10),
              ),
              child: const Icon(Icons.north_east, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class GameTypeBottomSheet extends ConsumerWidget {
  const GameTypeBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    return Container(
      decoration: const BoxDecoration(
        color: const Color(0xff2B2D30),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Close button and title
          const Center(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    'Select Game Type',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // Positioned(
                  //   right: 0,
                  //   child: GestureDetector(
                  //     onTap: () => Navigator.pop(context),
                  //     child: Container(
                  //       decoration: BoxDecoration(color: Colors.grey[800], shape: BoxShape.circle),
                  //       padding: const EdgeInsets.all(8),
                  //       child: const Icon(Icons.close, color: Colors.white, size: 20),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          const Divider(color: Colors.grey, height: 1),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GameTypeCard(
                    icon: Image.asset('assets/images/blitz.png', height: 33, width: 33),
                    title: 'Play',
                    subtitle: 'Blitz',
                    type: '3+2',
                    subtitleColor: const Color(0xFF8BC34A), // Light green
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context, rootNavigator: true).push(
                        GameScreen.buildRoute(
                          context,
                          seek: GameSeek.fastPairing(const TimeIncrement(180, 2), session),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: GameTypeCard(
                    icon: Image.asset('assets/images/blitz.png', height: 33, width: 33),
                    title: 'Play',
                    subtitle: 'Blitz',
                    type: '5+0',
                    subtitleColor: const Color(0xFF8BC34A), // Light green
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context, rootNavigator: true).push(
                        GameScreen.buildRoute(
                          context,
                          seek: GameSeek.fastPairing(const TimeIncrement(300, 0), session),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Game options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Wrap(
              runSpacing: 10,
              spacing: 25,
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Blitz option
                /*GameTypeCard(
                  icon: Image.asset('assets/images/blitz.png', height: 33, width: 33),
                  title: 'Play',
                  subtitle: 'Blitz',
                  type: '1+5',
                  subtitleColor: const Color(0xFF8BC34A), // Light green
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context, rootNavigator: true).push(
                      GameScreen.buildRoute(
                        context,
                        seek: GameSeek.fastPairing(const TimeIncrement(60, 5), session),
                      ),
                    );
                  },
                ),*/

                // Rapid option
                GameTypeCard(
                  icon: Image.asset('assets/images/rapid_game.png', height: 33, width: 33),
                  title: 'Play',
                  subtitle: 'Rapid',
                  type: '10+0',
                  subtitleColor: const Color(0xFF8BC34A), // Light green
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context, rootNavigator: true).push(
                      GameScreen.buildRoute(
                        context,
                        seek: GameSeek.fastPairing(const TimeIncrement(600, 0), session),
                      ),
                    );
                  },
                ),
                GameTypeCard(
                  icon: Image.asset('assets/images/pass&play.png', height: 33, width: 33),
                  title: 'Pass &',
                  subtitle: 'Play',
                  type: '',
                  subtitleColor: const Color(0xFF8BC34A), // Light green
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).push(OverTheBoardScreen.buildRoute(context));
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class ChessRatingCards extends StatelessWidget {
  final String blitzRank;
  final String rapidRank;

  const ChessRatingCards({super.key, required this.blitzRank, required this.rapidRank});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: _buildRatingCard(
              icon: Image.asset('assets/images/blitz.png'),
              iconColor: const Color(0xffFFF9E5),
              title: 'Blitz',
              rating: blitzRank,
            ),
          ),
          Expanded(
            child: _buildRatingCard(
              icon: Image.asset('assets/images/rapid_game.png'),

              iconColor: const Color(0xffE5FFF1),
              title: 'Rapid',
              rating: rapidRank,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard({
    required Widget icon,
    required Color iconColor,
    required String title,
    required String rating,
  }) {
    return ClipPath(
      clipper: ContainerClipper(notch: Platform.isAndroid ? 50 : 60),
      child: Container(
        // width: 140,
        // height: 135,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.0)),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: FittedBox(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: iconColor,
                        // borderRadius: BorderRadius.circular(8.0),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: icon,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          textScaler: TextScaler.noScaling,
                        ),
                        Text(
                          rating,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textScaler: TextScaler.noScaling,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Expanded(flex: 1, child: SizedBox()),
          ],
        ),
      ),
    );
  }
}

class GameTypeCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final String type;
  final Color subtitleColor;
  final VoidCallback onTap;

  const GameTypeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.subtitleColor,
    required this.onTap,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          ClipPath(
            clipper: ContainerClipper(),
            child: Container(
              height: 111,
              padding: const EdgeInsets.only(left: 16, top: 16, right: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  icon,
                  // Text(icon, style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: '$title ', style: const TextStyle(color: Colors.black)),
                            TextSpan(text: subtitle, style: TextStyle(color: subtitleColor)),
                          ],
                        ),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        textScaler: TextScaler.noScaling,
                      ),
                      const Spacer(),
                      Text(
                        type,
                        style: const TextStyle(
                          color: Color(0xff959494),
                          fontWeight: FontWeight.bold,
                        ),
                        textScaler: TextScaler.noScaling,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 12,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: const Icon(Icons.arrow_outward, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignInWidget extends ConsumerWidget {
  const _SignInWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.watch(authControllerProvider);

    return SecondaryButton(
      semanticsLabel: context.l10n.signIn,
      onPressed:
          authController.isLoading
              ? null
              : () => ref.read(authControllerProvider.notifier).signIn(),
      child: Text(context.l10n.signIn),
    );
  }
}

/// A widget that can be enabled or disabled by the user.
///
/// This widget is used to show or hide certain sections of the home screen.
///
/// The [homePreferencesProvider] provides a list of enabled widgets.
///
/// * The [widget] parameter is the widget that can be enabled or disabled.
///
/// * The [shouldShow] parameter is useful when the widget should be shown only
///   when certain conditions are met. For example, we only want to show the quick
///   pairing matrix when the user is online.
///   This parameter is only active when the user is not in edit mode, as we
///   always want to display the widget in edit mode.
class _EditableWidget extends ConsumerWidget {
  const _EditableWidget({
    required this.child,
    required this.widget,
    required this.shouldShow,
    this.index,
  });

  final Widget child;
  final HomeEditableWidget widget;
  final bool shouldShow;
  final int? index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabledWidgets = ref.watch(homePreferencesProvider).enabledWidgets;
    final isEditing = ref.watch(editModeProvider);
    final isEnabled = enabledWidgets.contains(widget);

    if (!shouldShow) {
      return const SizedBox.shrink();
    }

    return isEditing
        ? Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (index != null)
                    IconButton(
                      icon: Icon(Icons.arrow_upward, color: ColorScheme.of(context).outline),
                      onPressed:
                          isEnabled
                              ? () {
                                ref.read(homePreferencesProvider.notifier).moveUp(widget);
                              }
                              : null,
                    ),
                  Checkbox.adaptive(
                    value: isEnabled,
                    onChanged:
                        widget.alwaysEnabled
                            ? null
                            : (_) {
                              ref.read(homePreferencesProvider.notifier).toggleWidget(widget);
                            },
                  ),
                  if (index != null)
                    IconButton(
                      icon: Icon(Icons.arrow_downward, color: ColorScheme.of(context).outline),
                      onPressed:
                          isEnabled
                              ? () {
                                ref.read(homePreferencesProvider.notifier).moveDown(widget);
                              }
                              : null,
                    ),
                ],
              ),
            ),
            Expanded(child: IgnorePointer(ignoring: isEditing, child: child)),
          ],
        )
        : widget.alwaysEnabled || isEnabled
        ? child
        : const SizedBox.shrink();
  }
}

class _HelloWidget extends ConsumerWidget {
  const _HelloWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final style =
        Theme.of(context).platform == TargetPlatform.iOS
            ? const TextStyle(fontSize: 20)
            : TextTheme.of(context).bodyLarge;

    final iconSize = Theme.of(context).platform == TargetPlatform.iOS ? 26.0 : 24.0;

    // fetch the account user to be sure we have the latest data (flair, etc.)
    final accountUser = ref
        .watch(accountProvider)
        .maybeWhen(data: (data) => data?.lightUser, orElse: () => null);

    final user = accountUser ?? session?.user;

    return Padding(
      padding: Styles.horizontalBodyPadding
          .add(Styles.sectionBottomPadding)
          .add(const EdgeInsets.only(top: 8.0)),
      child: GestureDetector(
        onTap: () {
          ref.invalidate(accountActivityProvider);
          Navigator.of(context).push(ProfileScreen.buildRoute(context));
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wb_sunny, size: iconSize, color: context.lichessColors.brag),
            const SizedBox(width: 5.0),
            if (user != null)
              l10nWithWidget(
                context.l10n.mobileGreeting,
                UserFullNameWidget(user: user, style: style),
                textStyle: style,
              )
            else
              Text(context.l10n.mobileGreetingWithoutName, style: style),
          ],
        ),
      ),
    );
  }
}

class _TabletCreateAGameSection extends StatelessWidget {
  const _TabletCreateAGameSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // _EditableWidget(
        //   widget: HomeEditableWidget.quickPairing,
        //   shouldShow: true,
        //   child: Padding(padding: Styles.bodySectionPadding, child: QuickGameMatrix()),
        // ),
        Padding(padding: Styles.bodySectionPadding, child: QuickGameButton()),
        CreateGameOptions(),
      ],
    );
  }
}

class _OngoingGamesCarousel extends ConsumerWidget {
  const _OngoingGamesCarousel(this.games, {required this.maxGamesToShow});

  final AsyncValue<IList<OngoingGame>> games;

  final int maxGamesToShow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return games.maybeWhen(
      data: (data) {
        if (data.isEmpty) {
          return const SizedBox.shrink();
        }
        return GamesCarousel<OngoingGame>(
          list: data,
          onTap: (index) {
            final game = data[index];
            Navigator.of(context, rootNavigator: true).push(
              GameScreen.buildRoute(
                context,
                initialGameId: game.fullId,
                loadingFen: game.fen,
                loadingOrientation: game.orientation,
                loadingLastMove: game.lastMove,
              ),
            );
          },
          builder: (game) => OngoingGameCarouselItem(game: game),
          moreScreenRouteBuilder: OngoingGamesScreen.buildRoute,
          maxGamesToShow: maxGamesToShow,
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _OfflineCorrespondenceCarousel extends ConsumerWidget {
  const _OfflineCorrespondenceCarousel(this.offlineCorresGames, {required this.maxGamesToShow});

  final int maxGamesToShow;

  final AsyncValue<IList<(DateTime, OfflineCorrespondenceGame)>> offlineCorresGames;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return offlineCorresGames.maybeWhen(
      data: (data) {
        if (data.isEmpty) {
          return const SizedBox.shrink();
        }
        return GamesCarousel(
          list: data,
          onTap: (index) {
            final el = data[index];
            Navigator.of(context, rootNavigator: true).push(
              OfflineCorrespondenceGameScreen.buildRoute(context, initialGame: (el.$1, el.$2)),
            );
          },
          builder:
              (el) => OngoingGameCarouselItem(
                game: OngoingGame(
                  id: el.$2.id,
                  fullId: el.$2.fullId,
                  orientation: el.$2.orientation,
                  fen: el.$2.lastPosition.fen,
                  perf: el.$2.perf,
                  speed: el.$2.speed,
                  variant: el.$2.variant,
                  opponent: el.$2.opponent!.user,
                  isMyTurn: el.$2.isMyTurn,
                  opponentRating: el.$2.opponent!.rating,
                  opponentAiLevel: el.$2.opponent!.aiLevel,
                  lastMove: el.$2.lastMove,
                  secondsLeft: el.$2.myTimeLeft(el.$1)?.inSeconds,
                ),
              ),
          moreScreenRouteBuilder: OfflineCorrespondenceGamesScreen.buildRoute,
          maxGamesToShow: maxGamesToShow,
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _OngoingGamesPreview extends ConsumerWidget {
  const _OngoingGamesPreview(this.games, {required this.maxGamesToShow});

  final AsyncValue<IList<OngoingGame>> games;
  final int maxGamesToShow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return games.maybeWhen(
      data: (data) {
        return PreviewGameList(
          list: data,
          maxGamesToShow: maxGamesToShow,
          builder: (el) => OngoingGamePreview(game: el),
          moreScreenRouteBuilder: OngoingGamesScreen.buildRoute,
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _OfflineCorrespondencePreview extends ConsumerWidget {
  const _OfflineCorrespondencePreview(this.offlineCorresGames, {required this.maxGamesToShow});

  final int maxGamesToShow;

  final AsyncValue<IList<(DateTime, OfflineCorrespondenceGame)>> offlineCorresGames;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return offlineCorresGames.maybeWhen(
      data: (data) {
        return PreviewGameList(
          list: data,
          maxGamesToShow: maxGamesToShow,
          builder: (el) => OfflineCorrespondenceGamePreview(game: el.$2, lastModified: el.$1),
          moreScreenRouteBuilder: OfflineCorrespondenceGamesScreen.buildRoute,
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class PreviewGameList<T> extends StatelessWidget {
  const PreviewGameList({
    required this.list,
    required this.builder,
    required this.moreScreenRouteBuilder,
    required this.maxGamesToShow,
  });
  final IList<T> list;
  final Widget Function(T data) builder;
  final Route<dynamic> Function(BuildContext) moreScreenRouteBuilder;
  final int maxGamesToShow;

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: Styles.horizontalBodyPadding.add(const EdgeInsets.only(top: 16.0)),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  context.l10n.nbGamesInPlay(list.length),
                  style: Styles.sectionTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (list.length > maxGamesToShow) ...[
                const SizedBox(width: 6.0),
                NoPaddingTextButton(
                  onPressed: () {
                    Navigator.of(context).push(moreScreenRouteBuilder(context));
                  },
                  child: Text(context.l10n.more),
                ),
              ],
            ],
          ),
        ),
        for (final data in list.take(maxGamesToShow)) builder(data),
      ],
    );
  }
}

class _PlayerScreenButton extends ConsumerWidget {
  const _PlayerScreenButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityChangesProvider);

    return connectivity.maybeWhen(
      data:
          (connectivity) => AppBarIconButton(
            icon: const Icon(Icons.group_outlined),
            semanticsLabel: context.l10n.players,
            onPressed:
                !connectivity.isOnline
                    ? null
                    : () {
                      Navigator.of(context).push(PlayerScreen.buildRoute(context));
                    },
          ),
      orElse:
          () => AppBarIconButton(
            icon: const Icon(Icons.group_outlined),
            semanticsLabel: context.l10n.players,
            onPressed: null,
          ),
    );
  }
}

class _ChallengeScreenButton extends ConsumerWidget {
  const _ChallengeScreenButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);

    if (session == null) {
      return const SizedBox.shrink();
    }

    final connectivity = ref.watch(connectivityChangesProvider);
    final challenges = ref.watch(challengesProvider);
    final count = challenges.valueOrNull?.inward.length;

    return connectivity.maybeWhen(
      data:
          (connectivity) => AppBarNotificationIconButton(
            icon: const Icon(LichessIcons.crossed_swords, size: 18.0),
            semanticsLabel: context.l10n.preferencesNotifyChallenge,
            onPressed:
                !connectivity.isOnline
                    ? null
                    : () {
                      ref.invalidate(challengesProvider);
                      Navigator.of(context).push(ChallengeRequestsScreen.buildRoute(context));
                    },
            count: count ?? 0,
          ),
      orElse:
          () => AppBarIconButton(
            icon: const Icon(LichessIcons.crossed_swords, size: 18.0),
            semanticsLabel: context.l10n.preferencesNotifyChallenge,
            onPressed: null,
          ),
    );
  }
}
