import 'package:flutter/material.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  static Route<dynamic> buildRoute(BuildContext context) {
    return buildScreenRoute(context, screen: const UserProfileScreen(), title: context.l10n.profile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F151A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Image.asset(
              'assets/images/user_profile_avatar.png', // Replace with your asset or use network image
              fit: BoxFit.cover,
              height: 120,
              width: 120,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.person, color: Colors.green, size: 120);
              },
            ),
            const SizedBox(height: 10),
            const Text(
              'Magnus Carlsen 🇺🇸',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              '@magnuscarlsen',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _StatCard(label: 'Game Won', count: 500, color: Colors.green, labelIcon: 'W'),
                  _StatCard(label: 'Game Loss', count: 300, color: Colors.red, labelIcon: 'L'),
                  _StatCard(label: 'Game Draw', count: 100, color: Colors.blue, labelIcon: 'D'),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: [
                  _MenuItem(icon: Icons.person_outline, title: 'My Profile'),
                  _MenuItem(icon: Icons.leaderboard, title: 'Leaderboard'),
                  _MenuItem(icon: Icons.notifications_none, title: 'Notification'),
                  _MenuItem(icon: Icons.star_border, title: 'Rate this App'),
                ],
              ),
            ),
            const Divider(color: Colors.white24),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Logout', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final String labelIcon;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.labelIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A36),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 12,
            child: Text(labelIcon, style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 5),
          Text(
            '$count',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const _MenuItem({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
      onTap: () {},
    );
  }
}
