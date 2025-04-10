import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/auth/auth_session.dart';
import 'package:lichess_mobile/src/model/auth/login/login_controller.dart';
import 'package:lichess_mobile/src/navigation.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';
import 'package:lichess_mobile/src/view/auth/presentation/pages/create_password_screen.dart';
import 'package:lichess_mobile/src/view/auth/presentation/pages/set_username_screen.dart';
import 'package:lichess_mobile/src/view/common/apple_sign_in_button.dart';
import 'package:lichess_mobile/src/view/common/google_sign_in_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _handleContinueWithEmail() {
    final usernameOrEmail = _usernameController.text.trim();

    // Check if input is an email using regex pattern
    final bool isEmail = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
    ).hasMatch(usernameOrEmail);

    // If it's a username and longer than 25 characters, show error
    if (!isEmail && usernameOrEmail.length > 25) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Username must be 25 characters or less',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ref.read(loginControllerProvider.notifier).checkUsername(usernameOrEmail);
  }
  void _handleNewGoogleUser(String email, String idToken) {
    // Navigate to username selection screen for Google sign-up
    Navigator.of(context).push(
      SetUsernameScreen.buildRoute(
        context,
        previousInput: email,
        registrationType: RegistrationType.google,
        idToken: idToken,
      ),
    );
  }

  void _handleNewAppleUser(String email, String appleUserId) {
    // Navigate to username selection screen for Apple sign-up
    Navigator.of(context).push(
      SetUsernameScreen.buildRoute(
        context,
        previousInput: email,
        registrationType: RegistrationType.apple,
        appleUserId: appleUserId,
      ),
    );
  }

  void _handleGoogleSignInError(dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Google sign-in failed: ${error.toString().replaceAll('Exception: ', '')}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleAppleSignInError(dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Apple sign-in failed: ${error.toString().replaceAll('Exception: ', '')}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);
    ref.listen<AsyncValue<UsernameCheckResult?>>(loginControllerProvider, (previous, current) {
      // Handle data state
      current.whenData((result) {
        if (result == null) return;
        switch (result.state) {
          case LoginState.userExists:
            Navigator.of(context).push(
              CreatePasswordScreen.buildRoute(
                context,
                PasswordScreenMode.login,
                result.usernameOrEmail,
              ),
            );
            ref.read(loginControllerProvider.notifier).reset();
          case LoginState.userDoesNotExist:
            Navigator.of(
              context,
            ).push(CreatePasswordScreen.buildRoute(context, PasswordScreenMode.create, result.usernameOrEmail));
            ref.read(loginControllerProvider.notifier).reset();
          default:
            break;
        }
      });
      if (current.hasError && !current.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(current.error.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        Future.delayed(
          const Duration(seconds: 3),
              () => ref.read(loginControllerProvider.notifier).reset(),
        );
      }
    });

    ref.listen<AuthSessionState?>(
      authSessionProvider,
          (previous, current) {
        if (previous == null && current != null) {
          // Navigate to main screen
          Navigator.of(context).pushAndRemoveUntil(
            buildScreenRoute<void>(context, screen: const BottomNavScaffold()),
                (route) => false,
          );
        }
      },
    );

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
                    'A Platform for\nNext Level Chess',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 80),

                AppleSignInButton(
                  onNewUserVerified: _handleNewAppleUser,
                  onSignInError: _handleAppleSignInError,
                ),
                const SizedBox(height: 12),
                // Google login button
                GoogleSignInButton(
                  onNewUserVerified: _handleNewGoogleUser,
                  onSignInError: _handleGoogleSignInError,
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
                  controller: _usernameController,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
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

                // Continue button with loading state
                ElevatedButton(
                  onPressed:
                  loginState.isLoading
                      ? null // Disable button when loading
                      : _handleContinueWithEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    disabledBackgroundColor: Colors.green.withOpacity(0.5),
                  ),
                  child:
                  loginState.isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : Text(
                    'CONTINUE',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
