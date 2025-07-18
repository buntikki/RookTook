import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:rooktook/src/view/tournament/pages/tournament_detail_screen.dart';
import 'package:rooktook/src/view/tournament/provider/tournament_provider.dart';

class TournamentCard extends StatelessWidget {
  const TournamentCard({
    super.key,
    required this.tournament,
    required this.index,
    this.backgroundColor,
    this.isShowJoinedTag = true,
    this.isEnded = false,
  });

  final Tournament tournament;
  final int index;
  final Color? backgroundColor;
  final bool isShowJoinedTag;
  final bool isEnded;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<TournamentDetailScreen>(
            builder: (_) => TournamentDetailScreen(tournament: tournament),
          ),
        );
      },
      child: ClipRRect(
        child: Stack(
          children: [
            Container(
              clipBehavior: Clip.hardEdge,
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
                                tournament.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Row(
                                children: [
                                  if (tournament.entrySilverCoins > 0)
                                    SvgPicture.asset(
                                      'assets/images/svg/silver_coin.svg',
                                      height: 18.0,
                                    ),
                                  if (tournament.entrySilverCoins > 0) const SizedBox(width: 4),
                                  if (tournament.entrySilverCoins > 0)
                                    Text(
                                      '${tournament.entrySilverCoins}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  Text(
                                    tournament.entrySilverCoins > 0
                                        ? ' Coin (Entry Fee)'
                                        : 'Free To Join',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xff7D8082),
                                      fontWeight: FontWeight.w400,
                                    ),
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
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
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
                                  SvgPicture.asset(
                                    'assets/images/svg/${tournament.rewardCoinType}_coin.svg',
                                    height: 14.0,
                                  ),
                                  Text(
                                    '${tournament.rewardCoins}',
                                    style: TextStyle(
                                      color:
                                          tournament.rewardCoinType == 'silver'
                                              ? Colors.white
                                              : const Color(0xffD4AA40),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textScaler: TextScaler.noScaling,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              spacing: 4,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/svg/tournament_clock.svg',
                                  height: 18.0,
                                ),
                                Text(
                                  DateFormat('hh:mm a, MMM dd').format(
                                    DateTime.fromMillisecondsSinceEpoch(tournament.startTime),
                                  ),
                                  textScaler: TextScaler.noScaling,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 4,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/svg/participants.svg',
                                  height: 18.0,
                                ),
                                Text(
                                  isEnded
                                      ? ' ${tournament.players.length} Participants'
                                      : '${tournament.players.length}/${tournament.maxParticipants} Joined',
                                  textScaler: TextScaler.noScaling,
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
            if (tournament.haveParticipated && isShowJoinedTag)
              Positioned(
                right: -24,
                top: 8,
                child: Transform.rotate(
                  angle: pi / 4,
                  child: Container(
                    // width: 400,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    color: Colors.green,
                    alignment: Alignment.center,
                    child: const Text(
                      'Joined',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
