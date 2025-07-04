import 'dart:developer';

import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:rooktook/src/db/database.dart';
import 'package:rooktook/src/model/account/account_repository.dart';
import 'package:rooktook/src/model/auth/auth_controller.dart';
import 'package:rooktook/src/model/auth/auth_session.dart';
import 'package:rooktook/src/model/common/perf.dart';
import 'package:rooktook/src/model/game/archived_game.dart';
import 'package:rooktook/src/model/game/game_history.dart';
import 'package:rooktook/src/navigation.dart';
import 'package:rooktook/src/utils/l10n_context.dart';
import 'package:rooktook/src/utils/navigation.dart';
import 'package:rooktook/src/view/account/profile_screen.dart';
import 'package:rooktook/src/view/auth/presentation/pages/login_screen.dart';
import 'package:rooktook/src/view/common/container_clipper.dart';
import 'package:rooktook/src/view/user/player_screen.dart';
import 'package:rooktook/src/view/user/refer_and_earn_screen.dart';
import 'package:rooktook/src/widgets/adaptive_action_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class NewProfileScreen extends ConsumerWidget {
  const NewProfileScreen({super.key});

  static Route<dynamic> buildRoute(BuildContext context) {
    return buildScreenRoute(context, screen: const NewProfileScreen(), title: context.l10n.profile);
  }

  void _refreshData(WidgetRef ref) {
    ref.invalidate(getDbSizeInBytesProvider);
  }

  getTotalGamer(LightArchivedGameWithPov item) {
    final (game: game, pov: youAre) = item;
    final me = youAre == Side.white ? game.white : game.black;
    final opponent = youAre == Side.white ? game.black : game.white;
    return youAre;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userSession = ref.watch(authSessionProvider);
    ref.listen(currentBottomTabProvider, (prev, current) {
      if (prev != BottomTab.settings && current == BottomTab.settings) {
        _refreshData(ref);
      }
    });
    final recentGames = ref.watch(myRecentGamesProvider);

    final filteredGames =
        recentGames.value!
            .where((element) => element.game.perf == Perf.rapid || element.game.perf == Perf.blitz)
            .toList();

    final draw = filteredGames.where((element) => element.game.winner == null).length;

    final win =
        filteredGames.where((element) => element.game.winner == getTotalGamer(element)).length;

    final loose =
        filteredGames
            .where(
              (element) =>
                  element.game.winner != null && element.game.winner != getTotalGamer(element),
            )
            .length;

    /*final draw = recentGames.value!.where((element) => element.game.winner == null).length;

    final win =
        recentGames.value!.where((element) => element.game.winner == getTotalGamer(element)).length;

    final loose =
        recentGames.value!
            .where(
              (element) =>
                  element.game.winner != null && element.game.winner != getTotalGamer(element),
            )
            .length;*/

    final String avatarSeed = userSession?.user.name ?? 'default';

    return Scaffold(
      backgroundColor: const Color(0xFF0F151A),
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                height: 120,
                width: 120,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                child: ClipOval(child: RandomAvatar(avatarSeed, height: 120, width: 120)),
              ),

              // Image.asset(
              //   'assets/images/user_profile_avatar.png', // Replace with your asset or use network image
              //   fit: BoxFit.cover,
              //   height: 120,
              //   width: 120,
              //   errorBuilder: (context, error, stackTrace) {
              //     return const Icon(Icons.person, color: Colors.green, size: 120);
              //   },
              // ),
              const SizedBox(height: 10),
              if (userSession != null) Text('${userSession.user.name}'),
              // const Text(
              //   'Magnus Carlsen 🇺🇸',
              //   style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              // ),
              // const SizedBox(height: 5),
              // const Text('@magnuscarlsen', style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Wins',
                        count: win,
                        color: Colors.green,
                        labelIcon: 'W',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        label: 'Losses',
                        count: loose,
                        color: Colors.red,
                        labelIcon: 'L',
                      ),
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: _StatCard(
                        label: 'Draws',
                        count: draw,
                        color: Colors.blue,
                        labelIcon: 'D',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xff464A4F),
                ),
                margin: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _MenuItem(
                      icon: 'assets/images/profile.svg',
                      title: 'My Activity',
                      onTap: () {
                        ref.invalidate(accountActivityProvider);
                        Navigator.of(context).push(ProfileScreen.buildRoute(context));
                      },
                    ),
                    const Divider(color: Colors.white24, height: 1),
                    _MenuItem(
                      icon: 'assets/images/svg/refer.svg',
                      title: 'Refer & Earn',
                      onTap:
                          () => Navigator.of(context).push(ReferAndEarnScreen.buildRoute(context)),
                    ),
                    const Divider(color: Colors.white24, height: 1),
                    /*_MenuItem(
                      icon: 'assets/images/leaderboard.svg',
                      title: 'Leaderboard',
                      onTap: () => Navigator.of(context).push(PlayerScreen.buildRoute(context)),
                    ),
                    const Divider(color: Colors.white24, height: 1),*/

                    // _MenuItem(icon: Icons.notifications_none, title: 'Notification'),
                    // const Divider(color: Colors.white24),
                    _MenuItem(
                      icon: 'assets/images/star.svg',
                      title: 'Rate this App',
                      onTap: () {
                        launchUrl(Uri.parse('https://onelink.to/u9ktwp'));
                      },
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xff464A4F),
                ),
                margin: const EdgeInsets.all(16),
                child: _MenuItem(
                  icon: 'assets/images/logout.svg',
                  title: 'Logout',
                  onTap: () {
                    _showSignOutConfirmDialog(context, ref);
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _showDeleteAccountConfirmSheet(context, ref),
                  child: const Text(
                    'Delete Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 10.0),
              //   child: TextButton.icon(
              //     onPressed: () {},
              //     icon: const Icon(Icons.logout, color: Colors.white),
              //     label: const Text('Logout', style: TextStyle(color: Colors.white)),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showDeleteAccountConfirmSheet(BuildContext context, WidgetRef ref) {
  final authController = ref.read(authControllerProvider.notifier);
  bool isLoading = false;

  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: const Color(0xFF1A1F24),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return PopScope(
            // Prevent back button from dismissing while loading
            canPop: !isLoading,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 50),
                    const SizedBox(height: 20),
                    Text(
                      'Delete Account',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'This action cannot be undone. Once your account is deleted, you cannot create a new account with the same username and email.',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[300]),
                    ),
                    const SizedBox(height: 30),
                    if (isLoading)
                      Column(
                        children: [
                          const CircularProgressIndicator(color: Colors.white),
                          const SizedBox(height: 16),
                          Text(
                            'Deleting account',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });

                              try {
                                await authController.deleteAccount();
                                if (context.mounted) {
                                  Navigator.of(context).pop(); // Close the sheet
                                  ref.read(currentBottomTabProvider.notifier).state =
                                      BottomTab.home;
                                  rootNavigatorKey.currentState?.pushAndRemoveUntil(
                                    MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                                    (route) => false,
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('$e'),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 4),
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text(
                              'Delete My Account',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[300],
                              minimumSize: const Size.fromHeight(50),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(context.l10n.cancel),
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
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
    return ClipPath(
      clipper: ContainerClipper(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24).copyWith(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xff464A4F),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: 12,
              child: Text(labelIcon, style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

_showSignOutConfirmDialog(BuildContext context, WidgetRef ref) {
  final authController = ref.read(authControllerProvider.notifier);
  if (Theme.of(context).platform == TargetPlatform.iOS) {
    return showCupertinoActionSheet(
      context: context,
      actions: [
        BottomSheetAction(
          makeLabel: (context) => Text(context.l10n.logOut),
          isDestructiveAction: true,
          onPressed: () async {
            Navigator.of(context).pop(); // Dismiss the dialog

            await Future.delayed(const Duration(milliseconds: 200)); // Let animation finish

            authController.signOut();

            // Reset current tab to avoid keeping state
            ref.read(currentBottomTabProvider.notifier).state = BottomTab.home;

            // Navigate to login from root navigator
            rootNavigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
        ),
      ],
    );
  } else {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.l10n.logOut),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(textStyle: TextTheme.of(context).labelLarge),
              child: Text(context.l10n.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(textStyle: TextTheme.of(context).labelLarge),
              child: Text(context.l10n.mobileOkButton),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog first
                authController.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
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
      leading: SvgPicture.asset(icon),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.normal),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
      onTap: onTap,
    );
  }
}

class InwardRoundedRectangleBorder extends ShapeBorder {
  final double topLeftRadius;
  final double topRightRadius;

  const InwardRoundedRectangleBorder({this.topLeftRadius = 0.0, this.topRightRadius = 0.0});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final Path path = Path();

    // Start from top-left corner, then draw the inward curve
    path.moveTo(rect.left, rect.top);

    // Top-left inward curve
    if (topLeftRadius > 0) {
      path.lineTo(rect.left + topLeftRadius, rect.top);
      path.arcToPoint(
        Offset(rect.left, rect.top + topLeftRadius),
        radius: Radius.circular(topLeftRadius),
        clockwise: false,
      );
    }

    // Bottom-left corner (straight)
    path.lineTo(rect.left, rect.bottom);

    // Bottom edge
    path.lineTo(rect.right, rect.bottom);

    // Bottom-right to top-right (straight)
    path.lineTo(rect.right, rect.top + topRightRadius);

    // Top-right inward curve
    if (topRightRadius > 0) {
      path.arcToPoint(
        Offset(rect.right - topRightRadius, rect.top),
        radius: Radius.circular(topRightRadius),
        clockwise: false,
      );
    }

    // Back to start
    path.lineTo(rect.left, rect.top);

    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) {
    return InwardRoundedRectangleBorder(
      topLeftRadius: topLeftRadius * t,
      topRightRadius: topRightRadius * t,
    );
  }
}

class GameWonCard extends StatelessWidget {
  final int score;

  const GameWonCard({Key? key, required this.score}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 250,
        height: 300,
        child: ClipPath(
          // clipper: CutCornerClipper(),
          child: Container(
            color: const Color(0xFF2D2D30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Green circle with W
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(color: Color(0xFF7BC143), shape: BoxShape.circle),
                  child: const Center(
                    child: Text(
                      'W',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Game Won text
                const Text(
                  'Games Won',
                  style: TextStyle(
                    color: Color(0xFF818181),
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                // Score text
                Text(
                  '$score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// // Custom clipper for the top-right corner curve
// class CutCornerClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     Path path = Path();
//     double cornerRadius = 15.0;

//     path.moveTo(0, cornerRadius);
//     path.quadraticBezierTo(0, 0, cornerRadius, 0);
//     path.lineTo(size.width * 0.75, 0);

//     // Smooth top-right curve for the folder effect
//     path.quadraticBezierTo(size.width * 0.70, 50, size.width, 50);

//     path.lineTo(size.width, size.height - cornerRadius);
//     path.quadraticBezierTo(size.width, size.height, size.width - cornerRadius, size.height);
//     path.lineTo(cornerRadius, size.height);
//     path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);
//     path.close();

//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }

// Example of how to use this widget
class NewGameScreen extends StatelessWidget {
  const NewGameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: GameWonCard(score: 500)),
    );
  }
}
