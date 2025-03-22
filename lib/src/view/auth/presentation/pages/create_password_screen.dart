import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/auth/password/password_controller.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';
import 'package:lichess_mobile/src/view/auth/presentation/pages/set_username_screen.dart';

class CreatePasswordScreen extends ConsumerStatefulWidget {
  const CreatePasswordScreen({super.key});

  static Route<dynamic> buildRoute(
      BuildContext context) {
    return buildScreenRoute(
      context,
      screen: const CreatePasswordScreen(),
    );
  }

  @override
  ConsumerState<CreatePasswordScreen> createState() => _PasswordCreationScreenState();
}

class _PasswordCreationScreenState extends ConsumerState<CreatePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      ref.read(passwordControllerProvider.notifier).updatePassword(_passwordController.text);
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordControllerProvider);
    final controller = ref.watch(passwordControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF13191D),
      body: SafeArea(
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
                'Create Your\nPassword',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'We will send you a confirmation code',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: const Color(0xff8F9193))
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _passwordController,
                obscureText: !state.isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Enter Password',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.withValues(alpha:0.1),
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
              if (state.password.isNotEmpty)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: controller.getPasswordStrengthColor(),
                  ),
                ),

              if (state.password.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    controller.getPasswordStrengthText(),
                    style: TextStyle(color: controller.getPasswordStrengthColor(), fontSize: 14),
                  ),
                ),
              const Spacer(),
              // Continue button
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: ElevatedButton(
                  onPressed:
                      controller.isButtonEnabled
                          ? () {
                        Navigator.of(context).push(SetUsernameScreen.buildRoute(context));
                            debugPrint('Password submitted: ${state.password}');
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff4CAF50),
                    // Green color
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    disabledBackgroundColor: Colors.grey.shade700,
                  ),
                  child: Text(
                    'CONTINUE',
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
      ),
    );
  }
}
