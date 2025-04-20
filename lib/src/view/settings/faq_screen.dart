import 'package:flutter/material.dart';
import 'package:rooktook/src/utils/l10n_context.dart';
import 'package:rooktook/src/utils/navigation.dart';


const faqs = [
  {
    'question': 'What is RookTook?',
    'answer': 'RookTook is an online chess platform where you can play timed games, solve puzzles, and track your progress.'
  },
  {
    'question': 'How do I play a game on RookTook?',
    'answer': 'Tap the “Play” button on the home screen and choose a game type (e.g. Blitz, Rapid, Pass & Play).'
  },
  {
    'question': 'What do the time formats like 3+2 or 5+0 mean?',
    'answer': 'These are time controls. 3+2 means 3 minutes total + 2 seconds added after every move. 5+0 means 5 minutes with no extra time.'
  },
  {
    'question': 'What’s the difference between Blitz and Rapid?',
    'answer': 'Blitz is a fast-paced game (3–5 minutes). Rapid is slightly longer (10+ minutes), giving more time to think.'
  },
  {
    'question': 'What is “Pass & Play”?',
    'answer': 'This mode lets two players take turns on the same device — perfect for playing with a friend offline.'
  },
  {
    'question': 'How does the rating system work?',
    'answer': 'You gain or lose rating points based on whether you win, lose, or draw. The more you win, the higher your rating.'
  },
  {
    'question': 'How do I report a bug or issue?',
    'answer': 'Tap the “Send Feedback” button in Settings or email us at support@rooktook.com.'
  },
  {
    'question': 'I’m new to chess. Where should I start?',
    'answer': 'Start with Rapid games (10+0) and explore the Puzzle section to practice tactics.'
  },
  {
    'question': 'What happens if I run out of time?',
    'answer': 'You lose the game unless your opponent doesn’t have enough material to checkmate — in that case, it’s a draw.'
  },
  {
    'question': 'Can I pause a game?',
    'answer': 'Online games cannot be paused. Try Pass & Play mode for flexible timing.'
  },

];

class FAQScreen extends StatelessWidget {

  static Route<dynamic> buildRoute(BuildContext context) {
    return buildScreenRoute(
      context,
      screen: const FAQScreen(),
      title: 'FAQs',
    );
  }

  const FAQScreen({super.key});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1116),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text.rich(
          TextSpan(
            text: 'Frequently Asked ',
            children: [
              TextSpan(
                text: 'Questions?',
                style: TextStyle(color: Color(0xFF00FF57)), // Green
              ),
            ],
          ),
        ),
        elevation: 0,
        leading: const BackButton(),
      ),
      body: ListView.separated(
        itemCount: faqs.length,
        separatorBuilder: (_, __) => const Divider(color: Colors.transparent, height: 8),
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              unselectedWidgetColor: Colors.white,
              textTheme: const TextTheme(
                titleMedium: TextStyle(color: Colors.white),
              ),
            ),
            child: ExpansionTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.transparent),
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              collapsedBackgroundColor: const Color(0xFF1C1F26),
              backgroundColor: const Color(0xFF1C1F26),
              title: Text(faq['question']!, style: const TextStyle(color: Colors.white)),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    faq['answer']!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
