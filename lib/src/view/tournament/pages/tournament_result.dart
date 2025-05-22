import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:rooktook/src/view/tournament/provider/tournament_provider.dart';

class TournamentResult extends ConsumerStatefulWidget {
  const TournamentResult({super.key, required this.tournamentId});
  final String tournamentId;
  static MaterialPageRoute route(String tournamentId) =>
      MaterialPageRoute(builder: (context) => TournamentResult(tournamentId: tournamentId));

  @override
  ConsumerState<TournamentResult> createState() => _TournamentResultState();
}

class _TournamentResultState extends ConsumerState<TournamentResult> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.invalidate(fetchLeaderboardProvider(widget.tournamentId));
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardPr = ref.watch(fetchLeaderboardProvider(widget.tournamentId));
    return leaderboardPr.when(
      skipLoadingOnRefresh: false,
      data:
          (players) => Scaffold(
            appBar: AppBar(
              surfaceTintColor: Colors.transparent,
              title: const Text(
                'Results',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 28),
              ),
            ),
            body: ListView.separated(
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
                  rank: (index + 1).toString().padLeft(2, '0'),
                );
              },
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
      error: (error, stackTrace) => const Scaffold(body: Text('data')),
      loading:
          () => const Scaffold(
            body: Center(
              child: Column(
                spacing: 16,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CircularProgressIndicator(), Text('Fetching Results')],
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
  });
  final EdgeInsetsGeometry? margin;
  final Color? color1;
  final Color? color2;
  final bool isUserCard;
  final String rank;
  final Player player;

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
                    RandomAvatar(player.id, height: 40),
                    Text(
                      isUserCard ? 'You are here' : player.userId,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isUserCard ? const Color(0xff222222) : Colors.white,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      spacing: 4,
                      children: [
                        SvgPicture.asset('assets/images/svg/gold_coin.svg', height: 16, width: 16),
                        Text(
                          ' ${player.rewardGoldCoins}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isUserCard ? const Color(0xff222222) : const Color(0xffEFEDED),
                          ),
                        ),
                      ],
                    ),
                    const Text('Coins', style: TextStyle(color: Color(0xff7D8082), fontSize: 12)),
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
                        SvgPicture.asset('assets/images/svg/puzzle.svg', height: 18.0),
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
                          style: TextStyle(color: Color(0xff7D8082), fontSize: 12),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 8,
                      children: [
                        SvgPicture.asset(
                          'assets/images/svg/${isUserCard ? 'tournament_clock_light' : 'error'}.svg',
                          height: 16.0,
                        ),
                        Text(
                          '${player.errors}',
                          style: TextStyle(color: Color(0xff7D8082), fontSize: 12),
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
