import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lichess_mobile/src/utils/google_sign_in_service.dart';

class GoogleSignInButton extends StatelessWidget {
  final GoogleSignInService _googleSignInService = GoogleSignInService();
  final Function(UserCredential)  onSignInSuccess;
  final Function(dynamic) onSignInError;

  GoogleSignInButton({
    required this.onSignInSuccess,
    required this.onSignInError,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Image.asset(
        'assets/images/googleimage.png',
        height: 24.0,
      ),
      label: Text('Continue with Google', style: TextTheme.of(context).titleMedium),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff464A4F),
        foregroundColor: const Color(0xff464A4F),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () async {
        try {
          final userCredential = await _googleSignInService.signInWithGoogle();
          if (userCredential != null) {
            onSignInSuccess(userCredential);
          }
        } catch (e) {
          onSignInError(e);
        }
      },
    );
  }
}
