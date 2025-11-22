import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void showSuccessOverlay(BuildContext context) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) {
    // Optionally show a fallback or log the error
    print('No Overlay found in the widget tree for this context.');
    return;
  }

  final entry = OverlayEntry(
    builder: (context) => Positioned.fill(
      child: ColoredBox(
        color: Colors.black38,
        child: Center(
          child: Lottie.asset('assets/success.json', height: 120),
        ),
      ),
    ),
  );

  overlay.insert(entry);

  Future.delayed(const Duration(seconds: 1), () {
    entry.remove();
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  });
}

void showFailedOverlay(BuildContext context) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) {
    // Optionally show a fallback or log the error
    print('No Overlay found in the widget tree for this context.');
    return;
  }

  final entry = OverlayEntry(
    builder: (context) => Positioned.fill(
      child: ColoredBox(
        color: Colors.black38,
        child: Lottie.asset('assets/failed.json'),
      ),
    ),
  );

  overlay.insert(entry);

  Future.delayed(const Duration(milliseconds: 1500), () {
    entry.remove();
  });
}
