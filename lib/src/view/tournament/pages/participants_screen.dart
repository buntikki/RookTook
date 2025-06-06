import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:rooktook/src/view/tournament/provider/tournament_provider.dart';

class ParticipantsScreen extends StatelessWidget {
  const ParticipantsScreen({super.key, required this.players});
  final List<Player> players;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Particpants')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: players.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (BuildContext context, int index) {
          final Player player = players[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12).copyWith(left: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xff464A4F)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 8,
                  children: [
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
                    RandomAvatar(player.userId, height: 36, width: 36),
                    Text(
                      player.userId,
                      style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xffEFEDED)),
                    ),
                  ],
                ),
                // Text(
                //   (player.score ?? 0).toString(),
                //   style: const TextStyle(
                //     fontWeight: FontWeight.w700,
                //     fontSize: 14,
                //     color: Color(0xffEFEDED),
                //   ),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}
