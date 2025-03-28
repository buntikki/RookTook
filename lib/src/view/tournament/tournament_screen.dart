import 'package:flutter/material.dart';
import 'package:lichess_mobile/src/navigation.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';
import 'package:lichess_mobile/src/view/account/new_profile_screen.dart';
import 'package:lichess_mobile/src/view/auth/presentation/pages/create_password_screen.dart';
import 'package:lichess_mobile/src/view/common/apple_sign_in_button.dart';
import 'package:lichess_mobile/src/view/common/google_sign_in_button.dart';

class TournamentScreen extends StatelessWidget {
  const TournamentScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                style: TextStyle(fontSize: 68),
                children: [TextSpan(text: 'Soon', style: TextStyle(color: Colors.green))],
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
                  Navigator.of(context).push(UserProfileScreen.buildRoute(context));
                },
                borderRadius: BorderRadius.circular(18), // Half of width/height to make it circular
                child: CircleAvatar(
                  backgroundImage: AssetImage('assets/images/avatar.png'),
                  // child: Image.asset(
                  //   'assets/images/avatar.png', // Replace with your asset or use network image
                  //   fit: BoxFit.cover,
                  //   height: 36,
                  //   width: 36,
                  //   errorBuilder: (context, error, stackTrace) {
                  //     return const Icon(Icons.person, color: Colors.black54, size: 24);
                  //   },
                  // ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
