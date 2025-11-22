import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rooktook/src/network/connectivity.dart';

class ConnectivityOverlay extends ConsumerWidget {
  final Widget child;
  const ConnectivityOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectivityChangesProvider);

    // Show a slim banner when offline; nothing when online/loading.
    final banner = status.whenIsLoading(
      loading: () => const SizedBox.shrink(),
      online: () => const SizedBox.shrink(),
      offline: () => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            color: Colors.red,
            child: const DefaultTextStyle(
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              child: Text('No Internet Connection', textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    );

    return Stack(children: [child, banner]);
  }
}
