import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rooktook/src/model/auth/auth_controller.dart';
import 'package:rooktook/src/model/auth/auth_session.dart';
import 'package:rooktook/src/utils/apple_sign_in_service.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleSignInButton extends ConsumerWidget {
  final AppleSignInService _appleSignInService = AppleSignInService();
  final void Function(String email, String appleUserId) onNewUserVerified;
  final void Function(dynamic) onSignInError;

  AppleSignInButton({
    required this.onNewUserVerified,
    required this.onSignInError,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<bool>(
      future: SignInWithApple.isAvailable(),
      builder: (context, snapshot) {
        // Only show the button if Apple Sign In is available on this device
        if (snapshot.data == true) {
          return ElevatedButton.icon(
            icon: const Icon(Icons.apple, color: Colors.white, size: 24),
            label: Text('Continue with Apple', style: Theme.of(context).textTheme.titleMedium),
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
                // Get Apple sign in result
                final appleUserInfo = await _appleSignInService.signInWithApple();

                // Get auth controller
                final authController = ref.read(authControllerProvider.notifier);

                // Verify with server
                final result = await authController.verifyAppleSignIn(
                  appleUserInfo.identityToken,
                  appleUserInfo.userId,
                );

                if (result.userAlreadyRegistered) {
                  await authController.signInWithApple(result);
                  loadingOverlay.remove();
                } else {
                  loadingOverlay.remove();
                  onNewUserVerified(appleUserInfo.email.isNotEmpty?appleUserInfo.email:'', appleUserInfo.userId);
                }
              } catch (e) {
                loadingOverlay.remove();
                onSignInError(e);
              }
            },
          );
        }
        return const SizedBox.shrink(); // Don't show the button if Apple Sign In is not available
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
