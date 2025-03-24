import 'package:flutter/material.dart';

class MatchResultPopup extends StatelessWidget {
  final String title;
  final String subtitle;
  final String player1;
  final String player2;
  final int score1;
  final int score2;
  final int rating;
  final int ratingChange;
  final String avatar1;
  final String avatar2;

  const MatchResultPopup({
    super.key,
    required this.title,
    required this.subtitle,
    required this.player1,
    required this.player2,
    required this.score1,
    required this.score2,
    required this.rating,
    required this.ratingChange,
    required this.avatar1,
    required this.avatar2,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: title.split(' ')[0] + ' ',
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  TextSpan(
                    text: title.split(' ')[1],
                    style: const TextStyle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    CircleAvatar(radius: 32, backgroundImage: AssetImage(avatar1)),
                    const SizedBox(height: 8),
                    Text(player1, style: const TextStyle(color: Colors.white)),
                  ],
                ),
                Text('$score1 - $score2', style: const TextStyle(color: Colors.white, fontSize: 24)),
                Column(
                  children: [
                    CircleAvatar(radius: 32, backgroundImage: AssetImage(avatar2)),
                    const SizedBox(height: 8),
                    Text(player2, style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Rapid Rating', style: TextStyle(color: Colors.grey)),
                  const SizedBox(width: 10),
                  const Icon(Icons.bolt, color: Colors.amber, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    '$rating',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$ratingChange',
                    style: TextStyle(
                      color: ratingChange < 0 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A3A3A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text('REMATCH', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A3A3A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text('NEW MATCH', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
