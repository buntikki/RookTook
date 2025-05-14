import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rooktook/src/model/auth/auth_controller.dart';
import 'package:rooktook/src/model/auth/auth_session.dart';
import 'package:rooktook/src/utils/google_sign_in_service.dart';

class GoogleSignInButton extends ConsumerWidget {
  final GoogleSignInService _googleSignInService = GoogleSignInService();
  final void Function(String email, String idToken) onNewUserVerified;
  final void Function(dynamic) onSignInError;

  GoogleSignInButton({
    required this.onNewUserVerified,
    required this.onSignInError,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      icon: Image.asset(
        'assets/images/googleimage.png',
        height: 24.0,
      ),
      label: Text('Continue with Google', style: Theme.of(context).textTheme.titleMedium),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff464A4F),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () async {
        // Show loading indicator
        final loadingOverlay = _showLoadingOverlay(context);

        try {
          // Get Google sign in result
          final googleSignInInfo = await _googleSignInService.signInWithGoogle();

          // Get auth repository
          final authController = ref.read(authControllerProvider.notifier);

          // Verify with server
          final result = await authController.verifyGoogleSignIn(
            googleSignInInfo.idToken);

          // Hide loading indicator

          if (result.userAlreadyRegistered) {
            // User already exists, complete sign in
            await authController.signInWithGoogle(result);
            loadingOverlay.remove();
          } else {
            // New user, needs to set username - use callback instead of direct navigation
            onNewUserVerified(googleSignInInfo.email, googleSignInInfo.idToken);
            loadingOverlay.remove();
          }
        } catch (e) {
          // Make sure to remove the loading overlay on error
          loadingOverlay.remove();
          // Call the error handler
          onSignInError(e);
        }
      },
    );
  }

  OverlayEntry _showLoadingOverlay(BuildContext context) {
    final overlay = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black.withOpacity(0.5),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );

    Overlay.of(context).insert(overlay);
    return overlay;
  }
}
