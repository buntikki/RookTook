import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key, this.forceUpdate = false});
  final bool forceUpdate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(24),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/images/svg/logo.svg'),
                if (forceUpdate)
                  SvgPicture.asset('assets/images/svg/update_icon.svg', height: 100, width: 100)
                else
                  SvgPicture.asset('assets/images/svg/maintenance.svg'),
                if (forceUpdate)
                  Column(
                    spacing: 16,
                    children: [
                      MaterialButton(
                        color: const Color(0xFF54C339),
                        minWidth: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onPressed: () {
                          launchUrl(
                            Uri.parse(
                              Platform.isAndroid
                                  ? 'https://play.google.com/store/apps/details?id=com.rooktook&hl=en_IN'
                                  : 'https://apps.apple.com/in/app/rooktook-chess-puzzles/id6744465194',
                            ),

                            mode: LaunchMode.externalApplication,
                          );
                        },
                        child: const Text(
                          'Update',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Text(
                        'Please update to the latest version to continue and access new features.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  )
                else
                  const Column(
                    spacing: 16,
                    children: [
                      Text(
                        'Maintenance',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 28),
                      ),
                      Text(
                        "We are currently under maintenance this won't take long",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
