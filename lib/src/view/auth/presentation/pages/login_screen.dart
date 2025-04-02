import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:lichess_mobile/src/navigation.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';
import 'package:lichess_mobile/src/view/auth/presentation/pages/create_password_screen.dart';
import 'package:lichess_mobile/src/view/common/apple_sign_in_button.dart';
import 'package:lichess_mobile/src/view/common/google_sign_in_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              children: [
                const SizedBox(height: 120),

                // Heading text
                const Center(
                  child: Text(
                    'A Platform for\nnext level chess',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 80),

                AppleSignInButton(onSignInSuccess: (data) {
                  Navigator.of(context).pushReplacement(
                    buildScreenRoute<void>(context, screen: const BottomNavScaffold()),
                  );
                }, onSignInError: (error) {}),
                const SizedBox(height: 12),
                // Google login button
                GoogleSignInButton(
                  onSignInSuccess: (data) {
                    Navigator.of(context).pushReplacement(
                      buildScreenRoute<void>(context, screen: const BottomNavScaffold()),
                    );
                  },
                  onSignInError: (error) {
                    print(error);
                  },
                ),

                const SizedBox(height: 40),

                // OR divider
                const Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                  ],
                ),

                const SizedBox(height: 40),

                // Username or Email text field
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Username or Email',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xff2B2D30),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(CreatePasswordScreen.buildRoute(context));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'CONTINUE WITH EMAIL',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 56,
            right: 24,
            child: OutlinedButton(
              onPressed:
                  () => {
                Navigator.of(context).pushReplacement(
                  buildScreenRoute<void>(context, screen: const BottomNavScaffold()),
                ),
              },
              child: const Text('Skip'),
            ),
          ),
        ],
      ),
    );
  }
}
