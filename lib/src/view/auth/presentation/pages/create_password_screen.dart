import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:rooktook/src/model/auth/auth_controller.dart';
import 'package:rooktook/src/model/auth/auth_session.dart';
import 'package:rooktook/src/model/auth/password/password_controller.dart';
import 'package:rooktook/src/navigation.dart';
import 'package:rooktook/src/utils/branch_repository.dart';
import 'package:rooktook/src/utils/navigation.dart';
import 'package:rooktook/src/view/auth/presentation/pages/set_username_screen.dart';

enum PasswordScreenMode { login, create }

class CreatePasswordScreen extends ConsumerStatefulWidget {
  final PasswordScreenMode screenMode;
  final String username;
  const CreatePasswordScreen(this.screenMode, this.username, {super.key});

  static Route<dynamic> buildRoute(
    BuildContext context,
    PasswordScreenMode screenMode,
    String username,
  ) {
    return buildScreenRoute(context, screen: CreatePasswordScreen(screenMode, username));
  }

  @override
  ConsumerState<CreatePasswordScreen> createState() => _PasswordCreationScreenState();
}

class _PasswordCreationScreenState extends ConsumerState<CreatePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isInputEmail = false;
  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      ref.read(passwordControllerProvider.notifier).updatePassword(_passwordController.text.trim());
    });

    _isInputEmail = _isEmail(widget.username);
  }

  bool _isEmail(String input) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(input);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    final usernameOrEmail = widget.username;
    final password = _passwordController.text.trim();
    ref.read(authControllerProvider.notifier).signInWithPassword(usernameOrEmail, password);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordControllerProvider);
    final controller = ref.watch(passwordControllerProvider.notifier);
    final mode = widget.screenMode;

    final authState = ref.watch(authControllerProvider);

    if (mode == PasswordScreenMode.login) {
      ref.listen<AuthSessionState?>(authSessionProvider, (previous, current) {
        if (previous == null && current != null) {
          BranchRepository.trackCustomEvent('login', ref: ref);
          Navigator.of(context).pushAndRemoveUntil(
            buildScreenRoute<void>(context, screen: const BottomNavScaffold()),
            (route) => false,
          );
        }
      });

      ref.listen<AsyncValue<void>>(authControllerProvider, (previous, current) {
        if (previous?.isLoading == true && current.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${current.error}'), backgroundColor: Colors.red),
          );
        }
      });
    }

    // Now you can use it for conditional logic
    final String titleText =
        mode == PasswordScreenMode.create ? 'Create Your\nPassword' : 'Enter Your\nPassword';

    return Scaffold(
      backgroundColor: const Color(0xFF13191D),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xff2B2D30),
                          border: Border.all(color: const Color(0xff464A4F), width: 0.5),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),

                      const SizedBox(height: 32),
                      // Create Your Password text
                      Text(
                        titleText,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xff2B2D30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Your ${_isInputEmail ? 'Email' : 'Username'}"),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.green,
                                  child:
                                      _isInputEmail
                                          ? const Icon(Icons.email, color: Colors.white, size: 12)
                                          : RandomAvatar(widget.username),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.username,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.copyWith(color: const Color(0xff4CAF50)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: !state.isPasswordVisible,
                        inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                        decoration: InputDecoration(
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.1),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
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
                        ),
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),

                      const SizedBox(height: 24),

                      // Password strength indicator
                      if (state.password.isNotEmpty && mode == PasswordScreenMode.create)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 8,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: controller.getPasswordStrengthColor(),
                          ),
                        ),

                      if (state.password.isNotEmpty && mode == PasswordScreenMode.create)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            controller.getPasswordStrengthText(),
                            style: TextStyle(
                              color: controller.getPasswordStrengthColor(),
                              fontSize: 14,
                            ),
                          ),
                        ),

                      // Add extra space at the bottom to ensure content isn't hidden behind the button
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
            // Fixed button at the bottom
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              decoration: const BoxDecoration(color: Color(0xFF13191D)),
              child: ElevatedButton(
                onPressed:
                    authState.isLoading
                        ? null
                        : (controller.isButtonEnabled
                            ? () {
                              if (mode == PasswordScreenMode.create) {
                                Navigator.of(context).push(
                                  SetUsernameScreen.buildRoute(
                                    context,
                                    previousInput: widget.username,
                                    password: _passwordController.text.trim(),
                                  ),
                                );
                                debugPrint('Password submitted: ${state.password}');
                              } else {
                                _handleSignIn();
                              }
                            }
                            : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff4CAF50),
                  // Green color
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  disabledBackgroundColor: Colors.grey.shade700,
                ),
                child:
                    authState.isLoading
                        ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0),
                        )
                        : Text(
                          mode == PasswordScreenMode.create ? 'CONTINUE' : 'LOGIN',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
