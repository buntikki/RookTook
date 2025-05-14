
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rooktook/src/model/tournament/Tournament.dart';
import 'package:rooktook/src/view/tournament/tournament_detail_screen.dart';

class TournamentCard extends StatelessWidget {
  const TournamentCard({
    super.key,
    required this.tournament,
    required this.index,
    this.backgroundColor,
  });

  final Map<String, dynamic> tournament;
  final int index;
  final Color? backgroundColor;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<TournamentDetailScreen>(
            builder:
                (_) => TournamentDetailScreen(
                  tournament: Tournament(
                    title: 'Tournament $index',
                    entryFee: 100 + index,
                    reward: 250 + index,
                    date: 'Apr 1$index, 2025',
                    seatsLeft: '1$index/20 Seats Left',
                    bannerImage: 'assets/images/chess_tournament_banner.png',
                  ),
                ),
          ),
        );
      },
      child: Container(
        // margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFF2B2D30),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xff464a4f), width: .5),
        ),
        child: Column(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                spacing: 12,
                children: [
                  Image.asset('assets/images/puzzle_board.png', width: 80, height: 80),
                  Expanded(
                    child: Column(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${tournament['title']} $index',
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            SvgPicture.asset('assets/images/svg/silver_coin.svg', height: 18.0),
                            const SizedBox(width: 4),
                            Text(
                              "${tournament['entryFee']} ",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.0,
                              ),
                            ),
                            const Text(
                              'Coin (Entry Fee)',
                              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 0, thickness: .5),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Row(
                    spacing: 12,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xff33373c),
                          border: Border.all(color: const Color(0xff464a4f), width: .5),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          spacing: 4,
                          children: [
                            SvgPicture.asset('assets/images/svg/gold_coin.svg', height: 14.0),
                            Text(
                              "${tournament['userCoins']}",
                              style: const TextStyle(
                                color: Color(0xffD4AA40),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        spacing: 4,
                        children: [
                          SvgPicture.asset('assets/images/svg/tournament_clock.svg', height: 18.0),
                          Text(
                            tournament['date'] as String,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        spacing: 4,
                        children: [
                          SvgPicture.asset('assets/images/svg/participants.svg', height: 18.0),
                          Text(
                            tournament['seats'] as String,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
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
      ),
    );
  }
}
