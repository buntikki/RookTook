import 'package:flutter/material.dart';
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
          Container(
            color: const Color(0xFF13191D),
          ),

          // Chess background image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                'assets/images/bg_chess.png',
                fit: BoxFit.fitWidth,
              ),
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

                AppleSignInButton(onSignInSuccess: (data){}, onSignInError: (error){},),
                const SizedBox(height: 12),
                // Google login button
                GoogleSignInButton(onSignInSuccess: (data){}, onSignInError: (error){}),

                const SizedBox(height: 40),

                // OR divider
                const Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
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

                // Continue with Email button
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'CONTINUE WITH EMAIL',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
