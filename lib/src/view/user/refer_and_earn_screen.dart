import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rooktook/src/utils/navigation.dart';
import 'package:share_plus/share_plus.dart';

class ReferAndEarnScreen extends StatelessWidget {
  const ReferAndEarnScreen({super.key});
  static Route<dynamic> buildRoute(BuildContext context) {
    return buildScreenRoute(context, screen: const ReferAndEarnScreen());
  }

  final List<String> steps = const [
    'Invite your frind to install the app with your referral link',
    'He will play his 1st Tournament',
    'You both will get 100 Silver coins each',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refer & Earn')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Container(
              width: double.infinity,
              height: 350,
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 56),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/refer_banner.png'),
                  fit: BoxFit.contain,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Text(
                        'EARN 500',
                        style: GoogleFonts.bricolageGrotesque(
                          fontWeight: FontWeight.w900,
                          fontSize: 36,
                        ),
                      ),
                      SvgPicture.asset('assets/images/svg/silver_coin.svg', height: 28),
                    ],
                  ),
                  const Text(
                    'Invite your friends & family on RookTook. And you’ll earn 500 silver coins on their 1st play',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            CustomPaint(
              painter: _DashedBorderPainter(
                borderRadius: 12,
                color: const Color(0xff6F7276),
                dashSpace: 4,
                dashWidth: 4,
                strokeWidth: .5,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xff54C339).withValues(alpha: .06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your referral code',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Color(0xff7D8082),
                          ),
                        ),
                        Text(
                          'rooktook.com/ROOKT01YOGI',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: Color(0xffEFEDED),
                          ),
                        ),
                      ],
                    ),
                    MaterialButton(
                      onPressed: () {
                        SharePlus.instance.share(
                          ShareParams(uri: Uri.parse('rooktook.com/ROOKT01YOGI')),
                        );
                      },
                      padding: EdgeInsets.zero,
                      color: const Color(0xff54C339),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      child: const Text(
                        'SHARE',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: Color(0xffEFEDED),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Text(
              'How It Works',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xffEFEDED)),
            ),
            Column(
              children: List.generate(steps.length, (index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xff2B2D30),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xff464A4F), width: .5),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        spacing: 16,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            // padding: EdgeInsets.all(4),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xff13191D),
                            ),
                            child: Text('${index + 1}'),
                          ),
                          Expanded(
                            child: Text(
                              steps[index],
                              style: const TextStyle(color: Color(0xff959494)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index < steps.length - 1)
                      Column(
                        spacing: 2,
                        children: [
                          ...List.generate(
                            4,
                            (index) => Container(
                              margin: const EdgeInsets.only(left: 16),
                              height: 4,
                              width: .5,
                              color: const Color(0xff464A4F),
                            ),
                          ),
                        ],
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  _DashedBorderPainter({
    required this.strokeWidth,
    required this.color,
    required this.dashWidth,
    required this.dashSpace,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(borderRadius));

    final Path path = Path()..addRRect(rrect);

    final PathMetrics pathMetrics = path.computeMetrics();
    for (final PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final Path extractPath = pathMetric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
