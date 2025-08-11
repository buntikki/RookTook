import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:rooktook/src/model/auth/auth_session.dart';
import 'package:rooktook/src/styles/lichess_icons.dart';
import 'package:rooktook/src/view/tournament/pages/tournament_detail_screen.dart';
import 'package:rooktook/src/view/tournament/provider/tournament_provider.dart';

class TournamentResult extends ConsumerStatefulWidget {
  const TournamentResult({super.key, required this.tournamentId, required this.isShowLoading});
  final String tournamentId;
  final bool isShowLoading;
  static MaterialPageRoute route({required String tournamentId, required bool isShowLoading}) =>
      MaterialPageRoute(
        builder:
            (context) => TournamentResult(tournamentId: tournamentId, isShowLoading: isShowLoading),
      );

  @override
  ConsumerState<TournamentResult> createState() => _TournamentResultState();
}

class _TournamentResultState extends ConsumerState<TournamentResult> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.isShowLoading) {
      ref.invalidate(fetchLeaderboardProviderWithLoading(widget.tournamentId));
    } else {
      ref.invalidate(fetchLeaderboardProvider(widget.tournamentId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardPr = ref.watch(
      widget.isShowLoading
          ? fetchLeaderboardProviderWithLoading(widget.tournamentId)
          : fetchLeaderboardProvider(widget.tournamentId),
    );
    final session = ref.watch(authSessionProvider);
    return leaderboardPr.when(
      skipLoadingOnRefresh: false,
      data: (data) {
        final players = data.players;
        final coinType = data.rewardCoinType;
        final tournament = data.tournament;
        final isEnded = DateTime.now().isAfter(
          DateTime.fromMillisecondsSinceEpoch(tournament.endTime),
        );
        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            // // Navigator.pop(context);
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(
            //     builder: (_) => TournamentDetailScreen(tournament: tournament, isPlayed: true),
            //   ),
            // );
            // ref.invalidate(fetchTournamentsProvider);
            // ref.invalidate(fetchUserTournamentsProvider);
          },
          child: Scaffold(
            appBar: AppBar(
              surfaceTintColor: Colors.transparent,
              title: Text(
                isEnded ? 'Results' : 'Leaderboard',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 28),
              ),
            ),
            body: Column(
              children: [
                if (!isEnded)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B2D30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    child: Text(
                      'The tournament is live. Final results will be out at ${DateFormat('hh:mm a, MMM dd').format(DateTime.fromMillisecondsSinceEpoch(tournament.endTime))}',
                      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B2D30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        spacing: 8,
                        children: [
                          Icon(
                            LichessIcons.storm,
                            size: 18.0,
                            color: Color(0xFF54C339),
                            // : ColorScheme.of(context).primary,
                          ),
                          Text('Score', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),

                      Row(
                        spacing: 8,
                        children: [
                          SvgPicture.asset('assets/images/svg/fire.svg', height: 18.0),
                          const Text(
                            'Moves Combo',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        spacing: 8,
                        children: [
                          SvgPicture.asset('assets/images/svg/error.svg', height: 16.0),
                          const Text('Errors', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator.adaptive(
                    onRefresh: () async {
                      ref.invalidate(fetchLeaderboardProvider(widget.tournamentId));
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: players.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (BuildContext context, int index) {
                        Color? color1;
                        Color? color2;
                        if (index == 0) {
                          color1 = const Color(0xff2B291F);
                          color2 = const Color(0xff463F24);
                        }
                        if (index == 1) {
                          color1 = const Color(0xff202C33);
                          color2 = const Color(0xff2E4755);
                        }
                        if (index == 2) {
                          color1 = const Color(0xff312F3D);
                          color2 = const Color(0xff413C60);
                        }
                        final player = players[index];
                        return TournamentResultCard(
                          player: player,
                          color1: color1,
                          color2: color2,
                          coinType: coinType,
                          activeLeaderboardCoins:
                              !isEnded && index < tournament.rewardPool.split(',').length
                                  ? tournament.rewardPool.split(',')[index]
                                  : null,
                          isUserCard: session!.user.name == player.userId,
                          rank: (index + 1).toString().padLeft(2, '0'),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            // bottomSheet: BottomSheet(
            //   shape: const BeveledRectangleBorder(),
            //   backgroundColor: Colors.transparent,
            //   onClosing: () {},
            //   builder:
            //       (context) => IntrinsicHeight(
            //         child: TournamentResultCard(
            //           rank: '',
            //           margin: const EdgeInsets.all(16).copyWith(top: 0),
            //           isUserCard: true,
            //         ),
            //       ),
            // ),
          ),
        );
      },
      error: (error, stackTrace) => Scaffold(body: Center(child: Text('$error'))),
      loading:
          () => Scaffold(
            body: Center(
              child: Column(
                spacing: 16,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset('assets/result_loading.json', height: 200),
                  const Text('Fetching Results'),
                ],
              ),
            ),
          ),
    );
  }
}

class TournamentResultCard extends StatelessWidget {
  const TournamentResultCard({
    super.key,
    this.margin,
    this.isUserCard = false,
    this.color1,
    this.color2,
    required this.rank,
    required this.player,
    required this.coinType,
    this.activeLeaderboardCoins,
  });
  final EdgeInsetsGeometry? margin;
  final Color? color1;
  final Color? color2;
  final bool isUserCard;
  final String rank;
  final String coinType;
  final Player player;
  final String? activeLeaderboardCoins;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: isUserCard ? Colors.white : color1 ?? const Color(0xFF2B2D30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xff464a4f), width: .5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 12,
                  children: [
                    RandomAvatar(player.userId, height: 40),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isUserCard ? 'You are here' : player.userId,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isUserCard ? const Color(0xff222222) : Colors.white,
                          ),
                        ),
                        if (isUserCard)
                          Text(
                            player.userId,
                            maxLines: 2,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      spacing: 4,
                      children: [
                        SvgPicture.asset(
                          'assets/images/svg/${coinType}_coin.svg',
                          height: 16,
                          width: 16,
                        ),
                        Text(
                          ' ${activeLeaderboardCoins ?? player.rewardCoins}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isUserCard ? const Color(0xff222222) : const Color(0xffEFEDED),
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Coins Won',
                      style: TextStyle(color: Color(0xff7D8082), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(
                height: 0,
                thickness: .5,
                color: isUserCard ? const Color(0xffD9D9D9) : const Color(0xff464A4F),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Row(
                  spacing: 12,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            isUserCard
                                ? const Color(0xffBD980C)
                                : color2 ?? const Color(0xff33373c),
                        border: Border.all(
                          color: isUserCard ? const Color(0xffBD980C) : const Color(0xff464a4f),
                          width: .5,
                        ),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        '#$rank',
                        style: const TextStyle(
                          color: Color(0xffEFEDED),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Row(
                      spacing: 8,
                      children: [
                        const Icon(
                          LichessIcons.storm,
                          size: 18.0,
                          color: Color(0xFF54C339),
                          // : ColorScheme.of(context).primary,
                        ),
                        Text(
                          '${player.score}',
                          style: const TextStyle(color: Color(0xff7D8082), fontSize: 12),
                        ),
                      ],
                    ),

                    Row(
                      spacing: 8,
                      children: [
                        SvgPicture.asset(
                          'assets/images/svg/${isUserCard ? 'fire_light' : 'fire'}.svg',
                          height: 18.0,
                        ),
                        Text(
                          '${player.combo}',
                          style: const TextStyle(color: Color(0xff7D8082), fontSize: 12),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 8,
                      children: [
                        SvgPicture.asset('assets/images/svg/error.svg', height: 16.0),
                        Text(
                          '${player.errors}',
                          style: const TextStyle(color: Color(0xff7D8082), fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
