import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rooktook/src/navigation.dart';
import 'package:rooktook/src/utils/navigation.dart';
import 'package:rooktook/src/view/user/provider/referral_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReferralCodeScreen extends ConsumerStatefulWidget {
  const ReferralCodeScreen({super.key});

  @override
  ConsumerState<ReferralCodeScreen> createState() => _ReferralCodeScreenState();
}

class _ReferralCodeScreenState extends ConsumerState<ReferralCodeScreen> {
  final controller = TextEditingController();
  bool enabled = true;
  @override
  void initState() {
    super.initState();
    initControllerSetup();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => setState(() async {
        enabled = (await _getReferralCode()).isEmpty;
      }),
    );
  }

  @override
  void dispose() {
    controller.clear();
    super.dispose();
  }

  Future<void> initControllerSetup() async {
    controller.text = await _getReferralCode();
  }

  Future<String> _getReferralCode() async {
    final prefs = await SharedPreferences.getInstance();
    final referralCode = prefs.getString('referralCode') ?? '';
    return referralCode;
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey),
    );
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (enabled)
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  buildScreenRoute<void>(context, screen: const BottomNavScaffold()),
                  (route) => false,
                );
              },
              child: const Text('Skip', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Text(
              'Have a \nreferral code?',
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextField(
              enabled: enabled,
              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter referral code',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: border,
                disabledBorder: border,
                errorBorder: border,
                focusedBorder: border,
                enabledBorder: border,
                focusedErrorBorder: border,
                suffixStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      duration: Duration(seconds: 1),
                      content: Text(
                        "Referral Code can't be empty",
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  await ref
                      .read(referralProvider.notifier)
                      .createReferral(controller.text.trim())
                      .then(
                        (_) => Navigator.of(context).pushAndRemoveUntil(
                          buildScreenRoute<void>(context, screen: const BottomNavScaffold()),
                          (route) => false,
                        ),
                      );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff4CAF50), // Green color
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade800,
                disabledForegroundColor: Colors.grey,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Continue',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
