import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lichess_mobile/src/model/auth/auth_controller.dart';
import 'package:lichess_mobile/src/model/auth/auth_input_controller.dart';
import 'package:lichess_mobile/src/model/auth/auth_input_state.dart';
import 'package:lichess_mobile/src/model/auth/auth_session.dart';
import 'package:lichess_mobile/src/navigation.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';

class SetUsernameScreen extends ConsumerStatefulWidget {
  const SetUsernameScreen({
    super.key,
    required this.previousInput,
    required this.password,
  });

  final String previousInput;
  final String password;

  static Route<dynamic> buildRoute(
      BuildContext context, {
        required String previousInput,
        required String password,
      }) {
    return buildScreenRoute(
      context,
      screen: SetUsernameScreen(
        previousInput: previousInput,
        password: password,
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

  @override
  void initState() {
    super.initState();
    _isInputEmail = _isEmail(widget.previousInput);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authInputControllerProvider.notifier).setInputType(
          _isInputEmail ? InputType.username : InputType.email
      );
    });

    _inputController.addListener(() {
      ref.read(authInputControllerProvider.notifier).updateInput(_inputController.text);
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

    final email = _isInputEmail ? widget.previousInput : _inputController.text;
    final username = _isInputEmail ? _inputController.text : widget.previousInput;

    ref.read(authControllerProvider.notifier).signUp(
      email,
      username,
      widget.password,
    );
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

    final fieldLabel = _isInputEmail ? 'Username' : 'Email';
    final hintText = _isInputEmail ? 'Create username' : 'Enter12345678 email';

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
                        'Enter\nYour $fieldLabel',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 16),
                      Text(
                        _isInputEmail
                            ? 'Other players will see this when you play'
                            : "We'll use this to contact you about your account",
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(color: const Color(0xff8F9193)),
                      ),

                     /* const SizedBox(height: 32),

                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xff2B2D30),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0x4DFFFFFF),
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Center(
                          child: SvgPicture.asset('assets/images/svg/select_avatar.svg', width: 48, height: 48),
                        ),
                      ),*/
                      const SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xff2B2D30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
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
                          maxLength: _isInputEmail? null :state.maxLength,
                          keyboardType: _isInputEmail ? TextInputType.text : TextInputType.emailAddress,
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
              decoration: BoxDecoration(
                color: const Color(0xff1C1E21),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
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
