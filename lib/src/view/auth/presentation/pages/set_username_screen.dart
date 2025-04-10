import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/auth/auth_controller.dart';
import 'package:lichess_mobile/src/model/auth/auth_input_controller.dart';
import 'package:lichess_mobile/src/model/auth/auth_input_state.dart';
import 'package:lichess_mobile/src/model/auth/auth_session.dart';
import 'package:lichess_mobile/src/navigation.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';

enum RegistrationType {
  email,
  google,
  apple,
}

class SetUsernameScreen extends ConsumerStatefulWidget {
  const SetUsernameScreen({
    super.key,
    required this.previousInput,
    this.password,
    this.registrationType = RegistrationType.email,
    this.idToken,
    this.appleUserId,
  });

  final String previousInput;
  final String? password;
  final RegistrationType registrationType;
  final String? idToken;
  final String? appleUserId;

  static Route<dynamic> buildRoute(
      BuildContext context, {
        required String previousInput,
        String? password,
        RegistrationType registrationType = RegistrationType.email,
        String? idToken,
        String? appleUserId,
      }) {
    return buildScreenRoute(
      context,
      screen: SetUsernameScreen(
        previousInput: previousInput,
        password: password,
        registrationType: registrationType,
        idToken: idToken,
        appleUserId: appleUserId,
      ),
    );
  }

  @override
  ConsumerState<SetUsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends ConsumerState<SetUsernameScreen> {
  final TextEditingController _inputController = TextEditingController();
  bool _isSubmitting = false;
  bool _isInputEmail = false;
  late final bool _isSocialSignIn;
  late final String _socialAccountType;

  @override
  void initState() {
    super.initState();
    _isSocialSignIn = widget.registrationType == RegistrationType.google ||
        widget.registrationType == RegistrationType.apple;
    _socialAccountType = widget.registrationType == RegistrationType.google ? 'Google' : 'Apple';
    _isInputEmail = _isEmail(widget.previousInput);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authInputControllerProvider.notifier).setInputType(
          _isSocialSignIn || _isInputEmail ? InputType.username : InputType.email
      );
    });

    _inputController.addListener(() {
      ref.read(authInputControllerProvider.notifier).updateInput(_inputController.text.trim());
    });
  }

  bool _isEmail(String input) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(input);
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
    });

    if (widget.registrationType == RegistrationType.google) {
      // Handle Google sign-up with username
      final email = widget.previousInput;
      final username = _inputController.text.trim();

      ref.read(authControllerProvider.notifier).signUpWithGoogle(
        email,
        username,
        widget.idToken!,
      );
    } else if (widget.registrationType == RegistrationType.apple) {
      // Handle Apple sign-up with username
      final email = widget.previousInput;
      final username = _inputController.text.trim();

      ref.read(authControllerProvider.notifier).signUpWithApple(
        email,
        username,
        widget.appleUserId!,
      );
    } else {
      // Handle regular email/password sign-up
      final email = _isInputEmail ? widget.previousInput : _inputController.text.trim();
      final username = _isInputEmail ? _inputController.text.trim() : widget.previousInput;

      ref.read(authControllerProvider.notifier).signUp(
        email,
        username,
        widget.password!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authInputControllerProvider);
    final authState = ref.watch(authControllerProvider);

    ref.listen<AuthSessionState?>(
        authSessionProvider,
            (previous, current) {
          if (previous == null && current != null) {
            Navigator.of(context).pushAndRemoveUntil(
              buildScreenRoute<void>(context, screen: const BottomNavScaffold()),
                  (route) => false,
            );
          }
        }
    );

    ref.listen<AsyncValue<void>>(
      authControllerProvider,
          (previous, current) {
        if (previous?.isLoading == true && current.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Signup failed: ${current.error.toString().replaceAll('Exception: ', '')}',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );

    if (authState.isLoading != _isSubmitting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isSubmitting = authState.isLoading;
        });
      });
    }

    String pageTitle;
    String fieldLabel;
    String hintText;
    String helperText;

    if (_isSocialSignIn) {
      pageTitle = 'Create\nYour Username';
      fieldLabel = 'Username';
      hintText = 'Create username';
      helperText = 'Other players will see this when you play';
    } else {
      fieldLabel = _isInputEmail ? 'Username' : 'Email';
      pageTitle = 'Enter\nYour $fieldLabel';
      hintText = _isInputEmail ? 'Create username' : 'Enter email';
      helperText = _isInputEmail
          ? 'Other players will see this when you play'
          : "We'll use this to contact you about your account";
    }

    return Scaffold(
      backgroundColor: const Color(0xff1C1E21),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
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
                      Text(
                        pageTitle,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 16),
                      Text(
                        helperText,
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(color: const Color(0xff8F9193)),
                      ),

                      if (_isSocialSignIn) ...[
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
                              Text(
                                '$_socialAccountType Account',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.green,
                                    child: Icon(
                                      widget.registrationType == RegistrationType.google
                                          ? Icons.android
                                          : Icons.apple,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      widget.previousInput,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xff2B2D30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
                          controller: _inputController,
                          decoration: InputDecoration(
                            hintText: hintText,
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            border: InputBorder.none,
                            suffixText: '${state.value.length}/${state.maxLength}',
                            suffixStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                          ),
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                          maxLength: state.maxLength,
                          keyboardType: _isInputEmail || _isSocialSignIn
                              ? TextInputType.text
                              : TextInputType.emailAddress,
                          buildCounter:
                              (context, {required currentLength, required isFocused, maxLength}) => null,
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              decoration: const BoxDecoration(
                color: Color(0xff1C1E21),
              ),
              child: ElevatedButton(
                onPressed: (_isSubmitting || !state.isValid) ? null : _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff4CAF50), // Green color
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade800,
                  disabledForegroundColor: Colors.grey,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                )
                    : Text(
                  'SIGN UP',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold
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
