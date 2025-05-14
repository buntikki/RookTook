import 'package:flutter/widgets.dart';

class ContainerClipper extends CustomClipper<Path> {
  final double notch;

  ContainerClipper({super.reclip, this.notch = 60});
  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    const double radius = 12;
    final path = Path();
    path.moveTo(radius, 0);
    path.lineTo(width - notch, 0);
    path.quadraticBezierTo(width - notch + radius, 0, width - notch + radius + 4, radius);
    path.quadraticBezierTo(
      width - notch + radius + 8,
      radius + 12,
      width - notch + radius + radius + radius,
      radius + 12,
    );
    path.lineTo(width - radius, radius + 12);
    path.quadraticBezierTo(width, radius + 12, width, radius + radius + radius);
    path.lineTo(width, height - radius);
    path.quadraticBezierTo(width, height, width - radius, height);
    path.lineTo(radius, height);
    path.quadraticBezierTo(0, height, 0, height - radius);
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xff464a4f)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1; // Border thickness

    // Draw the same path as the clipper for the border
    final path = ContainerClipper().getClip(size);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
