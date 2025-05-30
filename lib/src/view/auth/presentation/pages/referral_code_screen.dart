import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rooktook/src/navigation.dart';
import 'package:rooktook/src/utils/navigation.dart';
import 'package:rooktook/src/view/user/provider/referral_provider.dart';

class ReferralCodeScreen extends ConsumerStatefulWidget {
  const ReferralCodeScreen({super.key});

  @override
  ConsumerState<ReferralCodeScreen> createState() => _ReferralCodeScreenState();
}

class _ReferralCodeScreenState extends ConsumerState<ReferralCodeScreen> {
  final controller = TextEditingController();
  @override
  void dispose() {
    controller.clear();
    super.dispose();
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Text(
              'Enter the referral code',
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextField(
              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter the referral code',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: border,
                suffixStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                await ref.read(referralProvider.notifier).createReferral(controller.text.trim());
                Navigator.of(context).pushAndRemoveUntil(
                  buildScreenRoute<void>(context, screen: const BottomNavScaffold()),
                  (route) => false,
                );
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
