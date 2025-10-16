import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rooktook/src/model/auth/auth_controller.dart';
import 'package:rooktook/src/model/auth/auth_session.dart';
import 'package:rooktook/src/model/auth/login/login_controller.dart';
import 'package:rooktook/src/model/auth/password/password_controller.dart';
import 'package:rooktook/src/navigation.dart';
import 'package:rooktook/src/utils/branch_repository.dart';
import 'package:rooktook/src/utils/navigation.dart';
import 'package:rooktook/src/utils/toast_widget.dart';
import 'package:rooktook/src/view/auth/presentation/pages/create_password_screen.dart';
import 'package:rooktook/src/view/auth/presentation/pages/set_username_screen.dart';
import 'package:rooktook/src/view/common/apple_sign_in_button.dart';
import 'package:rooktook/src/view/common/google_sign_in_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final List<OnboardingItem> onboardingItems = [
    OnboardingItem(
      title: '2-minute chess challenges',
      image: 'assets/images/onboarding1.png',
      description: 'Solve quick chess puzzles — perfect for both beginners and pros.',
    ),
    OnboardingItem(
      title: 'Play solo or battle others',
      image: 'assets/images/onboarding2.png',
      description: 'Go solo or compete with players from across the world.',
    ),
    OnboardingItem(
      title: 'Win real rewards',
      image: 'assets/images/onboarding3.png',
      description: 'Climb the leaderboard and unlock exciting prizes from store.',
    ),
  ];

  int _currentIndex = 0;

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

  void _handleGoogleSignInError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleAppleSignInError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthSessionState?>(authSessionProvider, (previous, current) {
      if (previous == null && current != null) {
        // Navigate to main screen
        Navigator.of(context).pushAndRemoveUntil(
          buildScreenRoute<void>(context, screen: const BottomNavScaffold()),
          (route) => false,
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF13191D),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // const SizedBox(height: 120),

            // // Heading text
            // const Center(
            //   child: Text(
            //     'A Platform for\nNext Level Chess',
            //     textAlign: TextAlign.center,
            //     style: TextStyle(
            //       color: Colors.white,
            //       fontSize: 34,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),

            // const SizedBox(height: 80),
            Expanded(
              child: PageView.builder(
                itemCount: onboardingItems.length,
                onPageChanged: (value) {
                  setState(() {
                    _currentIndex = value;
                  });
                },
                itemBuilder: (context, index) {
                  final item = onboardingItems[index];
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          item.title,
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: FittedBox(fit: BoxFit.scaleDown, child: Image.asset(item.image)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          item.description,
                          style: const TextStyle(fontSize: 14, color: Color(0xff8F9193)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              spacing: 6,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(onboardingItems.length, (index) {
                final isActive = index == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isActive ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xff54C339).withValues(alpha: isActive ? 1 : 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const Divider(color: Color(0xff939393), thickness: .5, height: 0),
                  const SizedBox(height: 24),
                  AppleSignInButton(
                    onNewUserVerified: _handleNewAppleUser,
                    onSignInError: _handleAppleSignInError,
                  ),
                  const SizedBox(height: 16),
                  // Google login button
                  GoogleSignInButton(
                    onNewUserVerified: _handleNewGoogleUser,
                    onSignInError: _handleGoogleSignInError,
                  ),

                  // const SizedBox(height: 40),

                  // OR divider
                  // const Row(
                  //   children: [
                  //     Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                  //     Padding(
                  //       padding: EdgeInsets.symmetric(horizontal: 16),
                  //       child: Text(
                  //         'OR',
                  //         style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                  //       ),
                  //     ),
                  //     Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                  //   ],
                  // ),

                  // const SizedBox(height: 40),

                  // Username or Email text field
                  // TextField(
                  //   controller: _usernameController,
                  //   inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                  //   decoration: InputDecoration(
                  //     hintText: 'Username or Email',
                  //     hintStyle: const TextStyle(color: Colors.grey),
                  //     filled: true,
                  //     fillColor: const Color(0xff2B2D30),
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(8),
                  //       borderSide: BorderSide.none,
                  //     ),
                  //     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  //   ),
                  // ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        useSafeArea: true,
                        builder: (context) => ContinueWithEmailBottomSheet(),
                      );
                    },
                    child: const Text(
                      'Continue with Email',
                      style: TextStyle(
                        color: Color(0xff54C339),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xff54C339),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Continue button with loading state
            // ElevatedButton(
            //   onPressed:
            //       loginState.isLoading
            //           ? null // Disable button when loading
            //           : _handleContinueWithEmail,
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.green,
            //     foregroundColor: Colors.white,
            //     padding: const EdgeInsets.symmetric(vertical: 16),
            //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            //     disabledBackgroundColor: Colors.green.withOpacity(0.5),
            //   ),
            //   child:
            //       loginState.isLoading
            //           ? const SizedBox(
            //             height: 20,
            //             width: 20,
            //             child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            //           )
            //           : Text(
            //             'CONTINUE',
            //             style: Theme.of(context).textTheme.titleMedium?.copyWith(
            //               color: Colors.white,
            //               fontWeight: FontWeight.bold,
            //             ),
            //           ),
            // ),
          ],
        ),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String image;
  final String description;

  OnboardingItem({required this.title, required this.image, required this.description});
}

class ContinueWithEmailBottomSheet extends ConsumerStatefulWidget {
  const ContinueWithEmailBottomSheet({super.key});

  @override
  ConsumerState<ContinueWithEmailBottomSheet> createState() => _ContinueWithEmailBottomSheetState();
}

class _ContinueWithEmailBottomSheetState extends ConsumerState<ContinueWithEmailBottomSheet> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isInputEmail = false;
  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      ref.read(passwordControllerProvider.notifier).updatePassword(_passwordController.text.trim());
    });

    _isInputEmail = _isEmail(_usernameController.text.trim());
  }

  void _handleSignIn() {
    final usernameOrEmail = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    ref.read(authControllerProvider.notifier).signInWithPassword(usernameOrEmail, password);
  }

  bool _isEmail(String input) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(input);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
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
      TopSnackBar.show(
        context,
        message: 'Username must be 25 characters or less',
        textColor: Colors.red,
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text(
      //       'Username must be 25 characters or less',
      //       style: TextStyle(color: Colors.white),
      //     ),
      //     backgroundColor: Colors.red.shade700,
      //     behavior: SnackBarBehavior.floating,
      //   ),
      // );
      return;
    }

    ref.read(loginControllerProvider.notifier).checkUsername(usernameOrEmail);
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final state = ref.watch(passwordControllerProvider);
    final isLoading = loginState.isLoading || authState.isLoading;
    final border = OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xff464A4F)),
      borderRadius: BorderRadius.circular(12),
    );
    final controller = ref.watch(passwordControllerProvider.notifier);
    const mode = PasswordScreenMode.login;

    if (mode == PasswordScreenMode.login) {
      ref.listen<AuthSessionState?>(authSessionProvider, (previous, current) {
        if (previous == null && current != null) {
          BranchRepository.trackCustomEvent('login', ref: ref);
          Future.delayed(const Duration(milliseconds: 900), () {
            Navigator.pushAndRemoveUntil(
              context,
              buildScreenRoute<void>(context, screen: const BottomNavScaffold()),
              (route) => false,
            );
          });
        }
      });

      ref.listen<AsyncValue<void>>(authControllerProvider, (previous, current) {
        if (previous?.isLoading == true && current.hasError) {
          TopSnackBar.show(
            context,
            message: 'Login failed: ${current.error}',
            textColor: Colors.red,
          );
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('Login failed: ${current.error}'), backgroundColor: Colors.red),
          // );
        }
      });
    }
    ref.listen<AsyncValue<UsernameCheckResult?>>(loginControllerProvider, (previous, current) {
      // Handle data state
      current.whenData((result) {
        if (result == null) return;
        switch (result.state) {
          case LoginState.userExists:
            // Navigator.of(context).push(
            //   CreatePasswordScreen.buildRoute(
            //     context,
            //     PasswordScreenMode.login,
            //     result.usernameOrEmail,
            //   ),
            // );
            _handleSignIn();
            ref.read(loginControllerProvider.notifier).reset();
          case LoginState.userDoesNotExist:
            // Navigator.of(context).push(
            //   CreatePasswordScreen.buildRoute(
            //     context,
            //     PasswordScreenMode.create,
            //     result.usernameOrEmail,
            //   ),
            // );
            TopSnackBar.show(
              context,
              message: 'Please signup with Google or Apple',
              textColor: Colors.red,
            );
            // ScaffoldMessenger.of(context).showSnackBar(
            //   const SnackBar(
            //     content: Text(
            //       'Please signup with Google or Apple',
            //       style: TextStyle(color: Colors.white),
            //     ),
            //     backgroundColor: Colors.red,
            //     duration: Duration(seconds: 3),
            //   ),
            // );
            ref.read(loginControllerProvider.notifier).reset();
          default:
            break;
        }
      });
      if (current.hasError && !current.isLoading) {
        TopSnackBar.show(context, message: current.error.toString(), textColor: Colors.red);
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(current.error.toString()),
        //     backgroundColor: Colors.red,
        //     duration: const Duration(seconds: 3),
        //   ),
        // );
        Future.delayed(
          const Duration(seconds: 3),
          () => ref.read(loginControllerProvider.notifier).reset(),
        );
      }
    });
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xff464A4F), width: .5),
              shape: BoxShape.circle,
              color: const Color(0xff2B2D30),
            ),
            child: const Icon(Icons.close_rounded, color: Colors.white),
          ),
        ),
        const SizedBox(height: 40),
        Flexible(
          child: Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xff464A4F), width: .5),
              color: const Color(0xff2B2D30),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xff3C3C3C), Color(0xff222222)],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Login with Email/Username',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xff464A4F), thickness: .5),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email/Username',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _usernameController,
                          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                          decoration: InputDecoration(
                            hintText: 'Enter Email/Username',
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: border,
                            enabledBorder: border,
                            focusedBorder: border,
                            focusedErrorBorder: border,
                            errorBorder: border,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: SvgPicture.asset('assets/images/svg/Message.svg'),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 32,
                              maxHeight: 32,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Password',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: !state.isPasswordVisible,
                          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                          decoration: InputDecoration(
                            hintText: 'Enter Password',
                            hintStyle: const TextStyle(color: Colors.grey),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            border: border,
                            enabledBorder: border,
                            focusedBorder: border,
                            focusedErrorBorder: border,
                            errorBorder: border,
                            suffixIcon: IconButton(
                              icon: Icon(
                                state.isPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                controller.togglePasswordVisibility();
                              },
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: SvgPicture.asset('assets/images/svg/Lock.svg'),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 32,
                              maxHeight: 32,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(height: 24),
                        MaterialButton(
                          height: 48,
                          color: const Color(0xff54C339),
                          onPressed: isLoading ? () {} : _handleContinueWithEmail,
                          minWidth: double.infinity,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child:
                              isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text(
                                    'LOGIN',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
