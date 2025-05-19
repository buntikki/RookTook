import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:rooktook/src/view/common/container_clipper.dart';
import 'package:rooktook/src/view/puzzle/storm_screen.dart';
import 'package:rooktook/src/view/tournament/pages/tournament_result.dart';
import 'package:rooktook/src/view/tournament/provider/tournament_provider.dart';

class TournamentDetailScreen extends ConsumerStatefulWidget {
  final Tournament tournament;

  const TournamentDetailScreen({super.key, required this.tournament});

  @override
  ConsumerState<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends ConsumerState<TournamentDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final tournament = widget.tournament;
    final Duration durationLeft = DateTime.fromMillisecondsSinceEpoch(
      tournament.startTime,
    ).difference(DateTime.now());
    return Scaffold(
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TournamentResult()),
              );
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
              onPressed: () async {
                // showModalBottomSheet(
                //   context: context,
                //   backgroundColor: const Color(0xFF1A1F23),
                //   shape: const RoundedRectangleBorder(
                //     borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                //   ),
                //   isScrollControlled: true,
                //   builder: (context) {
                //     return const InviteCodeSheet();
                //   },
                // );
                final data = await ref
                    .read(tournamentProvider.notifier)
                    .joinTournament(id: tournament.id);
                if (data == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Error joining tournamnet',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tournamnet joined successfully'),
                      backgroundColor: Color(0xFF54C339),
                    ),
                  );
                }
              },
              child: Row(
                spacing: 4,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'JOIN NOW',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                  if (tournament.access == 'invite') Icon(Icons.lock_rounded, color: Colors.white),
                ],
              ),
            ),
            if (durationLeft.inMinutes < 1)
              Center(
                child: TournamentTimerWidget(
                  startTime: tournament.startTime,
                  durationLeft: durationLeft,
                ),
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
                    icon: 'assets/images/svg/tournament_rules.svg',
                    title: 'Reward System',
                    onTap: () => _showHowToPlaySheet(context),
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  _MenuItem(
                    icon: 'assets/images/svg/tournament_rules.svg',
                    title: 'Tournament Rules',
                    onTap: () => _showHowToPlaySheet(context),
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  _MenuItem(
                    icon: 'assets/images/svg/participants_list.svg',
                    title: 'Participants',
                    onTap: () => _showHowToPlaySheet(context),
                  ),
                  const Divider(color: Colors.white24, height: 1),

                  // _MenuItem(icon: Icons.notifications_none, title: 'Notification'),
                  // const Divider(color: Colors.white24),
                  _MenuItem(
                    icon: 'assets/images/svg/how_to_play.svg',
                    title: 'How to Play',
                    onTap: () => _showHowToPlaySheet(context),
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  _MenuItem(
                    icon: 'assets/images/document.svg',
                    title: 'FAQs',
                    onTap: () => _showHowToPlaySheet(context),
                  ),
                ],
              ),
            ),
          ],
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

class InviteCodeSheet extends StatelessWidget {
  const InviteCodeSheet({super.key});

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
          TextField(
            decoration: InputDecoration(
              border: border,
              enabledBorder: border,
              errorBorder: border,
              focusedBorder: border,
              focusedErrorBorder: border,
            ),
            inputFormatters: [AlphanumericInputFormatter()],
          ),
          MaterialButton(
            minWidth: double.infinity,
            color: const Color(0xFF54C339),
            onPressed: () {},
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Text(
              'PROCEED',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ],
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
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    // if (durationLeft.inMinutes < 1) {
    Timer.periodic(const Duration(seconds: 1), (timeStamp) {
      setState(() {
        timeLeft = widget.durationLeft.inSeconds - timeStamp.tick;
      });
    });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Text('Starting in 00:${timeLeft.toString().padLeft(2, '0')} sec');
  }
}

void _showHowToPlaySheet(BuildContext context) {
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
            (_, controller) => Padding(
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
                  const Text(
                    'How To Play',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      controller: controller,
                      children: const [
                        Text(
                          'Lorem Ipsum is simply dummy text of the printing and typesetting industry. '
                          "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, "
                          'when an unknown printer took a galley of type and scrambled it to make a type specimen book.',
                          style: TextStyle(color: Colors.white70),
                        ),
                        SizedBox(height: 16),
                        RuleItem(text: '1 to 1 player will play here'),
                        RuleItem(text: 'You have to wait for another player'),
                        RuleItem(text: 'Remember rule number 1 and 2'),
                      ],
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
