import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MatchResultPopup extends ConsumerStatefulWidget {
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
  final void Function()? onRematch;
  final void Function()? onNewMatch;
  final dynamic seek;

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
    this.onRematch,
    required this.onNewMatch,
    this.seek,
  });

  @override
  ConsumerState<MatchResultPopup> createState() => _MatchResultPopupState();
}

class _MatchResultPopupState extends ConsumerState<MatchResultPopup> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xff2B2D30),
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
                style: const TextStyle(fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: '${widget.title.split(' ')[0]} ',
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  TextSpan(
                    text: widget.title.split(' ')[1],
                    style: const TextStyle(
                      fontSize: 24,
                      color: Color(0xff54C339),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(widget.subtitle, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Image.asset(widget.avatar1, width: 70, height: 70, fit: BoxFit.cover),
                      const SizedBox(height: 8),
                      Text(widget.player1, style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 120, child: Divider()),
                      Text(
                        '${widget.score1} - ${widget.score2}',
                        style: const TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      SizedBox(width: 120, child: Divider()),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Image.asset(widget.avatar2, width: 70, height: 70, fit: BoxFit.cover),
                      const SizedBox(height: 8),
                      Text(widget.player2, style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Rapid Rating', style: TextStyle(color: Colors.grey)),
                  const SizedBox(width: 12),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Color(0xffFFF9E5),
                      // borderRadius: BorderRadius.circular(8.0),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset('assets/images/blitz.png'),
                  ),
                  // const Icon(Icons.bolt, color: Colors.amber, size: 20),
                  const SizedBox(width: 25),
                  Text(
                    '${widget.rating}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.ratingChange}',
                    style: TextStyle(
                      color: widget.ratingChange < 0 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onRematch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff585B5E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                child: const Text(
                  'REMATCH',
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: widget.onNewMatch,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff585B5E),

                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                child: const Text(
                  'NEW MATCH',
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
