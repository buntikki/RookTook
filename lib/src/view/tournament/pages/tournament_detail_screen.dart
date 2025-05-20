import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:rooktook/src/model/auth/session_storage.dart';
import 'package:rooktook/src/view/common/container_clipper.dart';
import 'package:rooktook/src/view/puzzle/storm_screen.dart';
import 'package:rooktook/src/view/settings/faq_screen.dart';
import 'package:rooktook/src/view/tournament/pages/participants_screen.dart';
import 'package:rooktook/src/view/tournament/pages/tournament_result.dart';
import 'package:rooktook/src/view/tournament/provider/tournament_provider.dart';
import 'package:share_plus/share_plus.dart';

class TournamentDetailScreen extends ConsumerStatefulWidget {
  final Tournament tournament;

  const TournamentDetailScreen({super.key, required this.tournament});

  @override
  ConsumerState<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends ConsumerState<TournamentDetailScreen> {
  String userId = '';
  Tournament? _tournament;
  @override
  void initState() {
    super.initState();
    fetchSession();
  }

  Future<void> fetchSession() async {
    const SessionStorage session = SessionStorage();
    final data = await session.read();
    setState(() {
      userId = data!.user.name;
    });
  }

  Future<void> handleJoinTournament({required String id, String? inviteCode}) async {
    final data = await ref
        .read(tournamentProvider.notifier)
        .joinTournament(id: id, inviteCode: inviteCode);
    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error joining tournamnet', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      setState(() {
        _tournament = data;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tournamnet joined successfully', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF54C339),
        ),
      );
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
          'You need enough Silver Coins (if it’s a paid entry) and user should not be enrolled in another tournament at the same time.',
    },
    {
      'question': 'Can I join more than one tournament at the same time?',
      'answer':
          'No, you can only join one tournament in a time slot. You must wait for your current tournament to finish before joining another.',
    },
    {
      'question': 'What is the tournament format?',
      'answer':
          'Everyone gets the same puzzles. You have fixed time to solve as many as possible. Each correct answer gives a score.',
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
          'You won’t be able to participate, and your entry fee (if any) will not be refunded.',
    },
    {
      'question': 'How are winners decided?',
      'answer': 'Based on total score: Points earned per correct puzzle.',
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
      'answer': 'In case of a tie, the player who has better combo streak wins.',
    },
    {
      'question': 'How do I know a tournament is fair?',
      'answer':
          'Every participant gets the same puzzles, and cheating is strictly monitored. Suspicious behavior may result in disqualification.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final tournament = _tournament ?? widget.tournament;
    final Duration durationLeft = DateTime.fromMillisecondsSinceEpoch(
      tournament.startTime,
    ).difference(DateTime.now());
    final bool isTournamentStarted = durationLeft.inMinutes < 0;
    final bool isTournamentEnded =
        DateTime.fromMillisecondsSinceEpoch(
          tournament.endTime,
        ).difference(DateTime.now()).inMinutes <
        0;
    final bool isUserJoined = tournament.players.any((element) => element.userId == userId);
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
            IconButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => const TournamentResult()),
                // );
                SharePlus.instance.share(ShareParams(text: 'Check out the RookTook App!'));
              },
              icon: const Icon(Icons.share, color: Colors.white),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16).copyWith(bottom: 24), // Optional bottom padding
          child: Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // if (tournament.bannerImage != null)
              //   ClipRRect(
              //     borderRadius: BorderRadius.circular(12),
              //     child: Image.asset(tournament.bannerImage!, height: 200, fit: BoxFit.cover),
              //   ),
              const SizedBox(height: 8),
              Text(
                tournament.name,
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
                    icon: 'assets/images/svg/gold_coin.svg',
                    label: 'Reward',
                    value: '${tournament.rewardGoldCoins} C',
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
                  spacing: 24,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 4,
                        children: [
                          SvgPicture.asset('assets/images/svg/tournament_clock.svg', height: 18.0),
                          Text(
                            DateFormat(
                              'hh:mm a, MMM dd',
                            ).format(DateTime.fromMillisecondsSinceEpoch(tournament.startTime)),
                            style: const TextStyle(color: Color(0xff7D8082)),
                          ),
                        ],
                      ),
                    ),
                    // Vertical divider
                    Container(width: 1, height: 16, color: const Color(0xff464A4F)),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 4,
                        children: [
                          SvgPicture.asset('assets/images/svg/participants.svg', height: 18.0),
                          Text(
                            '${tournament.maxParticipants - tournament.players.length}/${tournament.maxParticipants} Seats Left',
                            style: const TextStyle(color: Color(0xff7D8082)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF54C339),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed:
                    isUserJoined
                        ? isTournamentStarted
                            ? () {
                              if (isTournamentEnded) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                      'Event has ended',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).push(StormScreen.buildRoute(context));
                              }
                            }
                            : null
                        : () async {
                          if (tournament.access.toLowerCase() == 'invite') {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: const Color(0xFF1A1F23),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              isScrollControlled: true,
                              builder: (_) {
                                return InviteCodeSheet(
                                  onPressed: (code) {
                                    print(code);
                                    handleJoinTournament(id: tournament.id, inviteCode: code);
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
                      isUserJoined
                          ? isTournamentStarted
                              ? 'PLAY NOW'
                              : 'JOINED'
                          : 'JOIN NOW',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                    if (tournament.access == 'invite' && !isUserJoined)
                      const Icon(Icons.lock_rounded, color: Colors.white),
                  ],
                ),
              ),
              if (!isTournamentStarted)
                if (durationLeft.inMinutes < 1)
                  Center(
                    child: TournamentTimerWidget(
                      startTime: tournament.startTime,
                      durationLeft: durationLeft,
                    ),
                  )
                else
                  Text(
                    'Event starts at ${DateFormat('hh:mm a on MMM dd').format(DateTime.fromMillisecondsSinceEpoch(tournament.startTime))}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xff7D8082)),
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
                      title: 'Reward System',
                      onTap:
                          () => showModalBottomSheet(
                            useSafeArea: true,
                            enableDrag: true,
                            context: context,
                            backgroundColor: const Color(0xFF1A1F23),
                            isScrollControlled: true,
                            builder: (context) {
                              return RewardSystemSheet(
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
                          () => _showHowToPlaySheet(
                            context,
                            tournament.customRules,
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
                              builder: (context) => ParticipantsScreen(players: tournament.players),
                            ),
                          ),
                    ),
                    const Divider(color: Colors.white24, height: 1),

                    // _MenuItem(icon: Icons.notifications_none, title: 'Notification'),
                    // const Divider(color: Colors.white24),
                    _MenuItem(
                      icon: 'assets/images/svg/how_to_play.svg',
                      title: 'How to Play',
                      onTap:
                          () => _showHowToPlaySheet(context, tournament.howToPlay, 'How To Play'),
                    ),
                    const Divider(color: Colors.white24, height: 1),
                    _MenuItem(
                      icon: 'assets/images/document.svg',
                      title: 'FAQs',
                      onTap:
                          () => Navigator.of(context).push(FAQScreen.buildRoute(context, faqList)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _coinCard({required String icon, required String label, required String value}) {
    return Expanded(
      child: CustomPaint(
        painter: BorderPainter(),
        child: ClipPath(
          clipper: ContainerClipper(),
          child: Container(
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: const BoxDecoration(color: Color(0xFF2B2D30)),
            child: Row(
              spacing: 12,
              children: [
                SvgPicture.asset(icon, height: 32.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(color: Color(0xff7D8082), fontSize: 12)),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RewardSystemSheet extends StatelessWidget {
  const RewardSystemSheet({super.key, required this.rewards});
  final List<String> rewards;

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
              'Reward System',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            ListView.separated(
              itemCount: rewards.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xff464A4F)),
                  ),
                  child: Row(
                    spacing: 16,
                    children: [
                      if (index < 3)
                        SvgPicture.asset(
                          'assets/images/svg/${index == 0
                              ? 'gold'
                              : index == 1
                              ? 'silver'
                              : 'bronze'}_medal.svg',
                          height: 36,
                          width: 36,
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
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
                      // SvgPicture.asset('assets/images/svg/gold_coin.svg', height: 32),
                      Text(
                        '${rewards[index]} C',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
  const TournamentTimerWidget({super.key, required this.startTime, required this.durationLeft});

  final int startTime;
  final Duration durationLeft;
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

  void scheduleTimerForTargetTime() {
    final now = DateTime.now();
    final targetTime = DateTime.fromMillisecondsSinceEpoch(widget.startTime);
    final timeUntilEvent = targetTime.difference(now);

    // Schedule 1 min before start
    final delayUntilStart = timeUntilEvent - const Duration(minutes: 1);

    if (delayUntilStart.isNegative) {
      // Already within 1 min → start now
      startTimer();
    } else {
      scheduledTimer = Timer(delayUntilStart, () {
        print('🎯 Target time reached: ${DateTime.now()}');
        startTimer();
      });
    }
  }

  void startTimer() {
    eventTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
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
    return Text('Starting in 00:${timeLeft.toString().padLeft(2, '0')} sec');
  }
}

void _showHowToPlaySheet(BuildContext context, String data, String title) {
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
              child: Column(
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
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      child: Html(
                        data: data,
                        style: {'body': Style(color: Colors.white, fontSize: FontSize(16))},
                      ),
                      // Text(
                      //   'Lorem Ipsum is simply dummy text of the printing and typesetting industry. '
                      //   "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, "
                      //   'when an unknown printer took a galley of type and scrambled it to make a type specimen book.',
                      //   style: TextStyle(color: Colors.white70),
                      // ),
                      // SizedBox(height: 16),
                      // RuleItem(text: '1 to 1 player will play here'),
                      // RuleItem(text: 'You have to wait for another player'),
                      // RuleItem(text: 'Remember rule number 1 and 2'),
                    ),
                  ),
                ],
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
