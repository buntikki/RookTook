import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/auth/auth_session.dart';
import 'package:lichess_mobile/src/view/account/new_profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:random_avatar/random_avatar.dart';

class TournamentScreen extends ConsumerWidget {
  const TournamentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userSession = ref.watch(authSessionProvider);
    final String avatarSeed = userSession?.user.name ?? 'default';
    return Scaffold(
      backgroundColor: const Color(0xFF13191D),
      body: Stack(
        children: [
          // Background layer with black color
          Container(color: const Color(0xFF13191D)),
          // Chess background image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.8,
              child: Image.asset('assets/images/bg_chess.png', fit: BoxFit.fitWidth),
            ),
          ),

          // Content layer with scrollable list
          Center(
            child: RichText(
              textAlign: TextAlign.center,

              text: TextSpan(
                text: 'Coming\n',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 68),
                //  TextStyle(fontSize: 68,fontFamily: GoogleFonts.bricolageGrotesqueTextTheme.),
                children: const [
                  TextSpan(text: 'Soon', style: TextStyle(color: Colors.green, height: 0.5)),
                ],
              ),
            ),
            // Text(
            //   'COMING\n SOON',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(color: Colors.white, fontSize: 34),
            // ),
          ),
          Positioned(
            top: 56,
            right: 24,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  // Navigate to profile screen
                  Navigator.of(context).push(NewProfileScreen.buildRoute(context));
                },
                borderRadius: BorderRadius.circular(18),
                // Half of width/height to make it circular
                child: Center(
                  child: RandomAvatar(avatarSeed, height: 36, width: 36),
                  // Image.asset(
                  //   'assets/images/avatar.png', // Replace with your asset or use network image
                  //   fit: BoxFit.cover,
                  //   height: 36,
                  //   width: 36,
                  //   errorBuilder: (context, error, stackTrace) {
                  //     return const Icon(Icons.person, color: Colors.black54, size: 24);
                  //   },
                  // ),
                ),
                //  CircleAvatar(
                //   backgroundImage: AssetImage('assets/images/avatar.png'),
                //   // child: Image.asset(
                //   //   'assets/images/avatar.png', // Replace with your asset or use network image
                //   //   fit: BoxFit.cover,
                //   //   height: 36,
                //   //   width: 36,
                //   //   errorBuilder: (context, error, stackTrace) {
                //   //     return const Icon(Icons.person, color: Colors.black54, size: 24);
                //   //   },
                //   // ),
                // ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
