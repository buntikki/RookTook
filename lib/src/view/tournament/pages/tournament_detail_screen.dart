import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:rooktook/src/model/notifications/notification_service.dart';
import 'package:rooktook/src/utils/branch_repository.dart';
import 'package:rooktook/src/view/common/container_clipper.dart';
import 'package:rooktook/src/view/puzzle/storm_screen.dart';
import 'package:rooktook/src/view/settings/faq_screen.dart';
import 'package:rooktook/src/view/tournament/pages/participants_screen.dart';
import 'package:rooktook/src/view/tournament/pages/tournament_result.dart';
import 'package:rooktook/src/view/tournament/provider/tournament_provider.dart';
import 'package:rooktook/src/view/wallet/provider/wallet_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class TournamentDetailScreen extends ConsumerStatefulWidget {
  final Tournament tournament;

  const TournamentDetailScreen({super.key, required this.tournament});

  @override
  ConsumerState<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends ConsumerState<TournamentDetailScreen> {
  Tournament? _tournament;
  @override
  void initState() {
    super.initState();

    // ref.read(tournamentProvider.notifier).fetchTournamentResult(id: widget.tournament.id);
  }

  Future<void> handleJoinTournament({required String id, String? inviteCode}) async {
    await ref.read(walletProvider.notifier).getUserLedger();
    final walletState = ref.read(walletProvider);
    if (walletState.walletInfo.silverCoins >= widget.tournament.entrySilverCoins) {
      final data = await ref.read(tournamentProvider.notifier).fetchSingleTournament(id);

      if (data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error joining tournament', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        setState(() {
          _tournament = data;
        });
        final tournaStartTime = DateTime.fromMillisecondsSinceEpoch(
          data.startTime,
        ).subtract(const Duration(seconds: 10));
        if ((await NTP.now()).isAfter(tournaStartTime)) {
          if (data.minParticipants <= data.players.length) {
            tournamentSuccessFn(id, inviteCode);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tournament Terminated', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.pop(context);
          }
        } else {
          tournamentSuccessFn(id, inviteCode);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough coins in the wallet', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> tournamentSuccessFn(String id, String? inviteCode) async {
    final data = await ref
        .read(tournamentProvider.notifier)
        .joinTournament(id: id, inviteCode: inviteCode);
    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error joining tournament', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      setState(() {
        _tournament = data;
      });
      final baseId = int.tryParse(data.id) ?? 0;
      final service = ref.read(notificationServiceProvider);
      BranchRepository.trackCustomEvent(
        data.entrySilverCoins > 0 ? 'paid_tournament_register' : 'free_tournament_register',
        data: {'tournamentId': data.id},
        ref: ref,
      );
      if (DateTime.fromMillisecondsSinceEpoch(
        data.startTime,
      ).subtract(const Duration(minutes: 1)).isAfter(DateTime.now())) {
        await service.scheduleNotification(
          id: baseId + 1,
          title: data.name,
          body: '${data.name} starts in 1 minute!',
          scheduledTime: DateTime.fromMillisecondsSinceEpoch(
            data.startTime,
          ).subtract(const Duration(minutes: 1)),
        );
      }
      if (DateTime.fromMillisecondsSinceEpoch(
        data.startTime,
      ).subtract(const Duration(minutes: 2)).isAfter(DateTime.now())) {
        await service.scheduleNotification(
          id: baseId + 2,
          title: data.name,
          body: '${data.name} starts in 2 minutes!',
          scheduledTime: DateTime.fromMillisecondsSinceEpoch(
            data.startTime,
          ).subtract(const Duration(minutes: 2)),
        );
      }
      if (DateTime.fromMillisecondsSinceEpoch(
        data.startTime,
      ).subtract(const Duration(minutes: 5)).isAfter(DateTime.now())) {
        await service.scheduleNotification(
          id: baseId + 5,
          title: data.name,
          body: '${data.name} starts in 5 minutes!',
          scheduledTime: DateTime.fromMillisecondsSinceEpoch(
            data.startTime,
          ).subtract(const Duration(minutes: 5)),
        );
      }
      await service.scheduleNotification(
        id: baseId + 10,
        title: data.name,
        body: '${data.name} has ended. Check your results.!',
        scheduledTime: DateTime.fromMillisecondsSinceEpoch(data.endTime),
      );
      if (DateTime.fromMillisecondsSinceEpoch(data.startTime).isAfter(DateTime.now())) {
        await service.scheduleNotification(
          id: baseId,
          title: data.name,
          body: '${data.name} started!',
          scheduledTime: DateTime.fromMillisecondsSinceEpoch(data.startTime),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tournament joined successfully', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF54C339),
        ),
      );
      final time =
          DateTime.fromMillisecondsSinceEpoch(data.startTime).difference(await NTP.now()).inSeconds;
      if (time > 30) {
        showHowToPlaySheet(context, data.howToPlay, 'How To Play');
      }
    }
  }

  final List<Map<String, String>> faqList = [
    {
      'question': 'What is a RookTook Tournament?',
      'answer':
          'A tournament is a timed puzzle battle where multiple players solve the same set of puzzles. Your goal is to score as many points as possible before time runs out.',
    },
    {
      'question': 'How do I join a tournament?',
      'answer':
          'Go to the Tournaments tab, select a tournament, and tap “Join”. Some tournaments may require silver coins or an invite code.',
    },
    {
      'question': 'What do I need to join a tournament?',
      'answer':
          'Paid tournaments require silver coins to join, while free ones can be entered with a simple tap on “Join now.”',
    },
    {
      'question': 'Can I join more than one tournament at the same time?',
      'answer':
          'No, you can only join one tournament in a time slot. You must wait for your current tournament to finish before joining another.',
    },
    {
      'question': 'What is the tournament format?',
      'answer':
          'Everyone starts at the same time with the same puzzles and a fixed time to solve as many as possible. Correct answers earn points, streaks give bonuses, and one mistake breaks the streak.',
    },
    {
      'question': 'What happens after I join?',
      'answer':
          "You'll get a countdown and reminder before the tournament starts. Once the time comes, you’ll be automatically taken to the puzzle screen.",
    },
    {
      'question': 'Can I leave or cancel after joining?',
      'answer': 'No. Once you join, your Silver Coins are deducted and your spot is reserved.',
    },
    {
      'question': 'What if I miss the tournament start time?',
      'answer':
          'You can still play the tournament if it is live but with the disadvantage of the time lost. Once the tournament ends, it ends. You can not participate in it.',
    },
    {
      'question': 'How are winners decided?',
      'answer':
          'Participants are ranked based on the points earned from solving puzzles. You can view the reward distribution by rank on the tournament card.',
    },
    {
      'question': 'What do winners get?',
      'answer':
          'Top-ranked players win Gold Coins, which can be used to redeem real-world gifts in the RookTook Store.',
    },
    {
      'question': 'Can I view the leaderboard after playing?',
      'answer':
          'Yes, go to the tournament detail screen and tap "Leaderboard" to see your rank and compare with others.',
    },
    {
      'question': 'What if two players have the same score?',
      'answer':
          'In case of a tie, the player who has less number of errors and better combo streak wins.',
    },
    {
      'question': 'How do I know a tournament is fair?',
      'answer':
          'Every participant gets the same puzzles, and cheating is strictly monitored by our Anti-cheating agent. Suspicious behavior may result in disqualification.',
    },
  ];

  final rules =
      '<h3><strong>1. Tournament Format</strong></h3><ul><li>Each player gets the <strong>same puzzle set</strong>.</li><li>The tournament runs for a <strong>fixed time duration</strong> (e.g. 3 minutes).</li><li>Your objective is to <strong>solve as many puzzles as possible</strong> in the given time.</li></ul><h3><strong>2. Scoring System</strong></h3><ul><li><strong>Correct Answer</strong>: +1 point.</li><li><strong>Wrong Answer</strong>: No points deducted, but your <strong>streak breaks</strong>.</li></ul><h3><strong>3. Participation Rules</strong></h3><ul><li>You can only join <strong>one tournament per time slot</strong>.</li><li>You must join the tournament <strong>before it starts</strong>.</li><li>Once joined, you <strong>cannot cancel</strong> and <strong>entry fees are non-refundable</strong>.</li><li>You must have sufficient <strong>Silver Coins</strong> to join if the tournament requires it.</li></ul><h3><strong>4. Eligibility</strong></h3><ul><li>Some tournaments may require a <strong>minimum puzzle rating</strong>.</li><li>You must meet all entry criteria shown on the tournament detail page.</li></ul><h3><strong>5. Winner Selection</strong></h3><ul><li>Players are ranked by <strong>highest score</strong>.</li><li>In case of a tie, the <strong>puzzle combo</strong> gets a higher rank.</li><li>The winners will receive <strong>Gold Coins</strong> as per the defined reward split.</li></ul><h3><strong>6. Prizes</strong></h3><ul><li>All rewards are in <strong>Gold Coins</strong>.</li><li>Gold Coins can be used to <strong>redeem gifts</strong> from the RookTook Store.</li><li>Gold Coins <strong>cannot be exchanged for real money</strong>.</li></ul><h3><strong>7. Fair Play &amp; Penalties</strong></h3><ul><li>Cheating, automation, or unfair gameplay will result in <strong>immediate disqualification</strong>.</li><li>Suspicious behavior is logged and reviewed by our moderation team.</li><li>Multiple offenses may result in <strong>account suspension</strong>.</li></ul><h3><strong>8. Missed Tournament</strong></h3><ul><li>If you miss the start time after joining, you <strong>forfeit your entry</strong>.</li><li>No refunds for missed or incomplete participation.</li></ul><p><br></p>';

  Future<void> shareBranchTournamentLink({required String tournamentId}) async {
    // Step 1: Create BranchUniversalObject
    final BranchUniversalObject buo = BranchUniversalObject(
      canonicalIdentifier: 'tournament/$tournamentId',
      title: 'Check out the Tournament!',
      contentMetadata: BranchContentMetaData()..addCustomMetadata('id', tournamentId),
    );

    // Step 2: Add link properties
    final BranchLinkProperties lp = BranchLinkProperties(
      channel: 'app',
      feature: 'tournament',
      campaign: 'tournament-$tournamentId',
      stage: 'all-user',
      // alias: 'tournament/$tournamentId',
    );

    // lp.addControlParam('\$fallback_url', 'https://onelink.to/u9ktwp');
    lp.addControlParam('\$deeplink_path', 'tournament/$tournamentId');

    // Step 3: Get short link
    final BranchResponse response = await FlutterBranchSdk.getShortUrl(
      buo: buo,
      linkProperties: lp,
    );

    if (response.success) {
      final String link = response.result as String;
      print(link);

      // Step 4: Share the link
      SharePlus.instance.share(ShareParams(text: 'Check out the Tournament!\n$link'));
    } else {
      print(response.errorCode);
      print('Error generating Branch link: ${response.errorMessage}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tournament = _tournament ?? widget.tournament;
    final bool isUserJoined = tournament.haveParticipated;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        ref.invalidate(fetchTournamentsProvider);
        ref.invalidate(fetchUserTournamentsProvider);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF13191D),
        appBar: AppBar(
          backgroundColor: const Color(0xFF13191D),
          surfaceTintColor: const Color(0xFF13191D),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            howToPlayButton(context, tournament.howToPlay),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () {
                  shareBranchTournamentLink(tournamentId: tournament.id);
                },
                icon: const Icon(Icons.share, color: Colors.white),
              ),
            ),
          ],
        ),
        body: RefreshIndicator.adaptive(
          onRefresh: () async {
            final data = await ref
                .read(tournamentProvider.notifier)
                .fetchSingleTournament(tournament.id);
            setState(() {
              _tournament = data;
            });
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16).copyWith(bottom: 24), // Optional bottom padding
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  tournament.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  spacing: 12,
                  children: [
                    _coinCard(
                      icon: 'assets/images/svg/${tournament.rewardCoinType}_coin.svg',
                      label: 'Reward',
                      value: '${tournament.rewardCoins} C',
                    ),
                    _coinCard(
                      icon: 'assets/images/svg/silver_coin.svg',
                      label: 'Entry Fee',
                      value: '${tournament.entrySilverCoins} C',
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xff464a4f), width: .5),
                    color: const Color(0xFF2B2D30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    spacing: 8,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 4,
                            children: [
                              SvgPicture.asset(
                                'assets/images/svg/tournament_clock.svg',
                                height: 18.0,
                              ),
                              Text(
                                DateFormat(
                                  'hh:mm a, MMM dd',
                                ).format(DateTime.fromMillisecondsSinceEpoch(tournament.startTime)),
                                style: const TextStyle(color: Color(0xff7D8082), fontSize: 14),
                                textScaler: TextScaler.noScaling,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Vertical divider
                      Container(width: 1, height: 16, color: const Color(0xff464A4F)),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 4,
                            children: [
                              SvgPicture.asset('assets/images/svg/participants.svg', height: 18.0),
                              Text(
                                DateTime.now().isAfter(
                                      DateTime.fromMillisecondsSinceEpoch(tournament.endTime),
                                    )
                                    ? '${tournament.players.length} Participants'
                                    : '${tournament.players.length}/${tournament.maxParticipants} Joined',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Color(0xff7D8082)),
                                textScaler: TextScaler.noScaling,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Consumer(
                  builder: (context, ref, child) {
                    final status = ref.watch(
                      tournamentStatusProvider((tournament.startTime, tournament.endTime)),
                    );
                    final bool isTournamentStarted = status.isStarted;
                    final bool isTournamentEnded = status.isEnded;
                    // print(
                    //   DateTime.fromMillisecondsSinceEpoch(
                    //     tournament.endTime,
                    //   ).difference(DateTime.now()),
                    // );
                    // print(Duration(seconds: 10));
                    return Column(
                      spacing: 8,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF54C339),
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed:
                              isUserJoined
                                  ? isTournamentStarted
                                      ? () async {
                                        if (isTournamentEnded) {
                                          Navigator.push(
                                            context,
                                            TournamentResult.route(
                                              tournamentId: tournament.id,
                                              isShowLoading:
                                                  (await NTP.now())
                                                      .difference(
                                                        DateTime.fromMillisecondsSinceEpoch(
                                                          tournament.endTime,
                                                        ),
                                                      )
                                                      .inMinutes <
                                                  1,
                                            ),
                                          );
                                        } else {
                                          await ref
                                              .read(tournamentProvider.notifier)
                                              .fetchSingleTournament(tournament.id)
                                              .then(
                                                (data) => setState(() {
                                                  _tournament = data;
                                                }),
                                              );

                                          if (tournament.minParticipants <=
                                              tournament.players.length) {
                                            Navigator.push(
                                              context,
                                              StormScreen.buildRoute(
                                                context,
                                                tournament.id,
                                                // Duration(seconds: 10),
                                                Duration(
                                                  seconds:
                                                      DateTime.fromMillisecondsSinceEpoch(
                                                        tournament.endTime,
                                                      ).difference(await NTP.now()).inSeconds,
                                                ),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Tournament Terminated',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            Navigator.pop(context);
                                          }
                                        }
                                      }
                                      : null
                                  : () {
                                    if (tournament.access.toLowerCase() == 'invite') {
                                      showModalBottomSheet(
                                        context: context,
                                        backgroundColor: const Color(0xFF1A1F23),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        isScrollControlled: true,
                                        builder: (_) {
                                          return InviteCodeSheet(
                                            onPressed: (code) {
                                              handleJoinTournament(
                                                id: tournament.id,
                                                inviteCode: code,
                                              );
                                              Navigator.pop(context);
                                            },
                                            scaffoldContext: context,
                                          );
                                        },
                                      );
                                    } else {
                                      handleJoinTournament(id: tournament.id);
                                    }
                                  },
                          child: Row(
                            spacing: 4,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isTournamentEnded
                                    ? 'View Results'
                                    : isUserJoined
                                    ? isTournamentStarted
                                        ? 'PLAY NOW'
                                        : 'JOINED'
                                    : 'JOIN NOW',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (tournament.access == 'invite' && !isUserJoined)
                                const Icon(Icons.lock_rounded, color: Colors.white),
                            ],
                          ),
                        ),
                        if (!isTournamentEnded)
                          Center(
                            child:
                                isTournamentStarted
                                    ? TournamentEndTimerWidget(startTime: tournament.endTime)
                                    : TournamentTimerWidget(startTime: tournament.startTime),
                          ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xff2B2D30),
                  ),
                  child: Column(
                    children: [
                      _MenuItem(
                        icon: 'assets/images/svg/reward_logo.svg',
                        title: 'Reward Distribution',
                        onTap:
                            () => showModalBottomSheet(
                              useSafeArea: true,
                              enableDrag: true,
                              context: context,
                              backgroundColor: const Color(0xFF1A1F23),
                              isScrollControlled: true,
                              builder: (context) {
                                return RewardDistributionSheet(
                                  coinType: tournament.rewardCoinType,
                                  rewards: tournament.rewardPool.split(',').toList(),
                                );
                              },
                            ),
                      ),
                      const Divider(color: Colors.white24, height: 1),
                      _MenuItem(
                        icon: 'assets/images/svg/tournament_rules.svg',
                        title: 'Tournament Rules',
                        onTap:
                            () => showHowToPlaySheet(
                              context,
                              tournament.customRules.isEmpty ? rules : tournament.customRules,
                              'Tournament Rules',
                            ),
                      ),
                      const Divider(color: Colors.white24, height: 1),
                      _MenuItem(
                        icon: 'assets/images/svg/participants_list.svg',
                        title: 'Participants',
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ParticipantsScreen(players: tournament.players),
                              ),
                            ),
                      ),
                      const Divider(color: Colors.white24, height: 1),

                      // _MenuItem(icon: Icons.notifications_none, title: 'Notification'),
                      // const Divider(color: Colors.white24),
                      // _MenuItem(
                      //   icon: 'assets/images/svg/how_to_play.svg',
                      //   title: 'How to Play',
                      //   onTap:
                      //       () => _showHowToPlaySheet(
                      //         context,
                      //         tournament.howToPlay.isEmpty ? howToPlay : tournament.howToPlay,
                      //         'How To Play',
                      //       ),
                      // ),
                      // const Divider(color: Colors.white24, height: 1),
                      _MenuItem(
                        icon: 'assets/images/document.svg',
                        title: 'FAQs',
                        onTap:
                            () =>
                                Navigator.of(context).push(FAQScreen.buildRoute(context, faqList)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _coinCard({required String icon, required String label, required String value}) {
    return Expanded(
      child: Container(
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF2B2D30),
          border: Border.all(color: const Color(0xff464a4f), width: .5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 12,
          children: [
            SvgPicture.asset(icon, height: 28.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Color(0xff7D8082), fontSize: 12),
                  textScaler: TextScaler.noScaling,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textScaler: TextScaler.noScaling,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HowToPlayVideoSheet extends StatefulWidget {
  const HowToPlayVideoSheet({
    super.key,
    required this.data,
    required this.title,
    required this.scrollController,
  });
  final String data;
  final String title;
  final ScrollController scrollController;

  @override
  State<HowToPlayVideoSheet> createState() => _HowToPlayVideoSheetState();
}

class _HowToPlayVideoSheetState extends State<HowToPlayVideoSheet> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    const videoUrl = 'https://youtu.be/16cb7Q0ks30';
    final videoId = YoutubePlayer.convertUrlToId(videoUrl)!;

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    );
  }

  bool _isHindi = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 4,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.grey[600],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: YoutubePlayerBuilder(
            player: YoutubePlayer(
              controller: _controller,
              progressIndicatorColor: Colors.red,
              showVideoProgressIndicator: true,
              progressColors: const ProgressBarColors(
                playedColor: Colors.red,
                handleColor: Colors.red,
              ),
              bottomActions: const [
                SizedBox(width: 10),
                CurrentPosition(),
                SizedBox(width: 10),
                ProgressBar(isExpanded: true),
                SizedBox(width: 10),
                RemainingDuration(),
                // FullScreenButton(),
              ],
              onEnded: (metaData) {
                Navigator.pop(context);
              },
            ),
            builder: (context, player) => player,
          ),
        ),
        TextButton(
          onPressed: () {
            final videoUrl =
                _isHindi ? 'https://youtu.be/16cb7Q0ks30' : 'https://youtu.be/ZDgyHzyTJtA';
            final videoId = YoutubePlayer.convertUrlToId(videoUrl)!;

            _controller.load(videoId);
            _isHindi = !_isHindi;
            setState(() {});
          },
          child: Text(
            _isHindi ? 'Watch in English' : 'Watch in Hindi',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            child: Html(
              data: widget.data,
              style: {'body': Style(color: Colors.white, fontSize: FontSize(16))},
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class RewardDistributionSheet extends StatelessWidget {
  const RewardDistributionSheet({super.key, required this.rewards, required this.coinType});
  final List<String> rewards;
  final String coinType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          spacing: 24,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Reward Distribution',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            ListView.separated(
              itemCount: rewards.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (BuildContext context, int index) {
                Color? color;
                if (index == 0) {
                  color = const Color(0xff463F24);
                }
                if (index == 1) {
                  color = const Color(0xff2E4755);
                }
                if (index == 2) {
                  color = const Color(0xff413C60);
                }
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xff464A4F)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // if (index < 3)
                      //   SvgPicture.asset(
                      //     'assets/images/svg/${index == 0
                      //         ? 'gold'
                      //         : index == 1
                      //         ? 'silver'
                      //         : 'bronze'}_medal.svg',
                      //     height: 36,
                      //     width: 36,
                      //   )
                      // else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xff464A4F)),
                        ),
                        child: Text(
                          '#${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Color(0xffEFEDED),
                          ),
                        ),
                      ),
                      Row(
                        spacing: 8,
                        children: [
                          Text(
                            rewards[index],
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          SvgPicture.asset('assets/images/svg/${coinType}_coin.svg', height: 24),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class InviteCodeSheet extends StatefulWidget {
  const InviteCodeSheet({super.key, required this.onPressed, required this.scaffoldContext});
  final void Function(String code) onPressed;
  final BuildContext scaffoldContext;

  @override
  State<InviteCodeSheet> createState() => _InviteCodeSheetState();
}

class _InviteCodeSheetState extends State<InviteCodeSheet> {
  final codeController = TextEditingController();

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey),
    );
    return Padding(
      padding: const EdgeInsets.all(
        16.0,
      ).copyWith(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _formkey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text('Invite Code', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            TextFormField(
              controller: codeController,
              decoration: InputDecoration(
                border: border,
                enabledBorder: border,
                errorBorder: border,
                focusedBorder: border,
                focusedErrorBorder: border,
                hintText: 'Enter invite code',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Code can't be empty";
                }
                return null;
              },
              inputFormatters: [AlphanumericInputFormatter()],
            ),
            MaterialButton(
              minWidth: double.infinity,
              color: const Color(0xFF54C339),
              onPressed: () {
                if (_formkey.currentState!.validate()) {
                  widget.onPressed(codeController.text.trim());
                }
              },
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Text(
                'PROCEED',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AlphanumericInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Regular expression to allow only alphanumeric characters (no emoji, special chars)
    final regExp = RegExp(r'^[a-zA-Z0-9]*$');

    // Check if input matches the allowed pattern and does not exceed length 6
    if (regExp.hasMatch(newValue.text) && newValue.text.length <= 6) {
      return newValue;
    }
    // Revert to the old value if invalid
    return oldValue;
  }
}

class TournamentTimerWidget extends StatefulWidget {
  const TournamentTimerWidget({super.key, required this.startTime});

  final int startTime;
  @override
  State<TournamentTimerWidget> createState() => _TournamentTimerWidgetState();
}

class _TournamentTimerWidgetState extends State<TournamentTimerWidget> {
  int timeLeft = 00;
  Timer? scheduledTimer;
  Timer? eventTimer;
  @override
  void initState() {
    super.initState();
    scheduleTimerForTargetTime();
  }

  Future<void> scheduleTimerForTargetTime() async {
    final startTime = DateTime.fromMillisecondsSinceEpoch(widget.startTime);
    final timeUntilEvent = await getLeftDuration(startTime);

    // Schedule 1 min before start
    final delayUntilStart = timeUntilEvent - const Duration(minutes: 1);

    if (delayUntilStart.isNegative) {
      // Already within 1 min → start now
      startTimer();
    } else {
      scheduledTimer = Timer(delayUntilStart, () {
        startTimer();
      });
    }
  }

  Future<Duration> getLeftDuration(DateTime startTime) async {
    return startTime.difference(await NTP.now());
  }

  void startTimer() {
    eventTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final now = await NTP.now();
      final targetTime = DateTime.fromMillisecondsSinceEpoch(widget.startTime);
      final remaining = targetTime.difference(now).inSeconds;

      if (remaining <= 0) {
        timer.cancel();
        setState(() => timeLeft = 0);
      } else {
        setState(() => timeLeft = remaining);
      }
    });
  }

  @override
  void dispose() {
    scheduledTimer?.cancel();
    eventTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (eventTimer?.isActive ?? false) {
      return Text(
        'Starting in 00:${timeLeft.toString().padLeft(2, '0')}',
        style: const TextStyle(color: Color(0xFF54C339)),
      );
    } else {
      return Text(
        'Event starts at ${DateFormat('hh:mm a on MMM dd').format(DateTime.fromMillisecondsSinceEpoch(widget.startTime))}',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xff7D8082)),
      );
    }
  }
}

class TournamentEndTimerWidget extends StatefulWidget {
  const TournamentEndTimerWidget({super.key, required this.startTime});

  final int startTime;
  @override
  State<TournamentEndTimerWidget> createState() => _TournamentEndTimerWidgetState();
}

class _TournamentEndTimerWidgetState extends State<TournamentEndTimerWidget> {
  int timeLeft = 00;
  Timer? scheduledTimer;
  Timer? eventTimer;
  @override
  void initState() {
    super.initState();
    scheduleTimerForTargetTime();
  }

  Future<void> scheduleTimerForTargetTime() async {
    final startTime = DateTime.fromMillisecondsSinceEpoch(widget.startTime);
    final timeUntilEvent = await getLeftDuration(startTime);

    // Schedule 1 min before start
    final delayUntilStart = timeUntilEvent - const Duration(minutes: 1);

    if (delayUntilStart.isNegative) {
      // Already within 1 min → start now
      startTimer();
    } else {
      scheduledTimer = Timer(delayUntilStart, () {
        startTimer();
      });
    }
  }

  Future<Duration> getLeftDuration(DateTime startTime) async {
    return startTime.difference(await NTP.now());
  }

  void startTimer() {
    eventTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final now = await NTP.now();
      final targetTime = DateTime.fromMillisecondsSinceEpoch(widget.startTime);
      final remaining = targetTime.difference(now).inSeconds;

      if (remaining <= 0) {
        timer.cancel();
        setState(() => timeLeft = 0);
      } else {
        setState(() => timeLeft = remaining);
      }
    });
  }

  @override
  void dispose() {
    scheduledTimer?.cancel();
    eventTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (eventTimer?.isActive ?? false) {
      return Text(
        'Ending in 00:${timeLeft.toString().padLeft(2, '0')}',
        style: const TextStyle(color: Colors.red),
      );
    } else {
      return Text(
        'Event ends at ${DateFormat('hh:mm a on MMM dd').format(DateTime.fromMillisecondsSinceEpoch(widget.startTime))}',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xff7D8082)),
      );
    }
  }
}

void showHowToPlaySheet(BuildContext context, String data, String title) {
  const howToPlay =
      '<p><strong>Game rules</strong></p><p>Each puzzle grants one point. The goal is to get as many points as you can before the time runs out.</p><p>You always play the same colour during a storm run.</p><p><strong>Combo bar</strong></p><p>Each correct move fills the combo bar. When the bar is full, you get a time bonus, and you increase the value of the next bonus.</p><p>When you play a wrong move, the combo bar is depleted.</p>';

  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1A1F23),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder:
            (_, controller) => Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: HowToPlayVideoSheet(
                data: data.isEmpty ? howToPlay : data,
                title: title,
                scrollController: controller,
              ),
            ),
      );
    },
  );
}

class RuleItem extends StatelessWidget {
  final String text;
  const RuleItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String icon;
  final String title;
  void Function()? onTap;

  _MenuItem({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      leading: SvgPicture.asset(icon),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.normal),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xff7D8082), size: 16),
      onTap: onTap,
    );
  }
}

TextButton howToPlayButton(BuildContext context, String howToPlay) {
  return TextButton(
    onPressed: () {
      showHowToPlaySheet(context, howToPlay, 'How To Play');
    },
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        // color: const Color(0xff2B2D30),
        border: Border.all(color: const Color(0xFF54C339)),
        // border: Border.all(color: const Color(0xff464A4F)),
      ),
      child: const Text('How to play?', style: TextStyle(color: Colors.white)),
    ),
  );
}
