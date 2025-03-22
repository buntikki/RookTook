import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lichess_mobile/src/model/auth/username_controller.dart';
import 'package:lichess_mobile/src/navigation.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';

class SetUsernameScreen extends ConsumerStatefulWidget {
  const SetUsernameScreen({super.key});

  static Route<dynamic> buildRoute(
      BuildContext context) {
    return buildScreenRoute(
      context,
      screen: const SetUsernameScreen(),
    );
  }

  @override
  ConsumerState<SetUsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends ConsumerState<SetUsernameScreen> {
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(() {
      ref.read(usernameControllerProvider.notifier).updateUsername(_usernameController.text);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usernameControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xff1C1E21), // Darker background than 0xff2B2D30
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content area
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
                        'Choose\nYour Username',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 16),
                      Text(
                        'Other players will see this when you play',
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(color: const Color(0xff8F9193)),
                      ),

                      const SizedBox(height: 32),

                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xff2B2D30),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.3),
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Center(
                          child: SvgPicture.asset('assets/images/svg/select_avatar.svg', width: 48, height: 48),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xff2B2D30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: 'Username',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            border: InputBorder.none,
                            suffixText: '${state.username.length}/${state.maxLength}',
                            suffixStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                          ),
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                          maxLength: state.maxLength,
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

            // Fixed button at bottom
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
                onPressed: state.isValid ? () {
                  // Handle username submission
                  print('Username submitted: ${state.username}');
                  // Hide keyboard when button is pressed
                  FocusScope.of(context).unfocus();
                  Navigator.of(context).pushAndRemoveUntil(
                    buildScreenRoute<void>(context, screen: const BottomNavScaffold()), (route) => false,
                  );
                } : null,
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
    );
  }
}
