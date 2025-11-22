import 'package:flutter/material.dart';

class TopSnackBar {
  TopSnackBar._();
  static void show(
    BuildContext context, {
    required String message,
    Color backgroundColor = Colors.red,
    Duration duration = const Duration(seconds: 2),
    TextStyle? textStyle,
    Color? textColor = Colors.white,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => _TopSnackBarWidget(
            message: message,
            backgroundColor: backgroundColor,
            textStyle: textStyle,
            textColor: textColor,
            duration: duration,
            onDismissed: () => overlayEntry.remove(),
          ),
    );

    overlay.insert(overlayEntry);
  }
}

class _TopSnackBarWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final TextStyle? textStyle;
  final Color? textColor;
  final Duration duration;
  final VoidCallback onDismissed;

  const _TopSnackBarWidget({
    required this.message,
    required this.backgroundColor,
    required this.textStyle,
    required this.textColor,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_TopSnackBarWidget> createState() => _TopSnackBarWidgetState();
}

class _TopSnackBarWidgetState extends State<_TopSnackBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // Wait for duration, then reverse animation and remove overlay
    Future.delayed(widget.duration, () async {
      await _controller.reverse();
      widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 8,
      right: 8,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
              ],
            ),
            child: Text(widget.message, style: widget.textStyle),
          ),
        ),
      ),
    );
  }
}
