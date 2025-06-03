import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rooktook/src/utils/navigation.dart';
import 'package:rooktook/src/view/user/provider/referral_provider.dart';
import 'package:share_plus/share_plus.dart';

class ReferAndEarnScreen extends ConsumerStatefulWidget {
  const ReferAndEarnScreen({super.key});
  static Route<dynamic> buildRoute(BuildContext context) {
    return buildScreenRoute(context, screen: const ReferAndEarnScreen());
  }

  @override
  ConsumerState<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends ConsumerState<ReferAndEarnScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.invalidate(fetchUserReferralDetails);
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(fetchUserReferralDetails);
    return Scaffold(
      appBar: AppBar(title: const Text('Refer & Earn'), surfaceTintColor: Colors.transparent),
      body: provider.when(
        data: (_) => const ReferAndEarnLoaded(),
        error: (error, stackTrace) => Center(child: Text('$error')),
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}

class ReferAndEarnLoaded extends ConsumerWidget {
  const ReferAndEarnLoaded({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(referralProvider);
    final details = state.referralDetails;
    final List<String> steps = [
      'Invite your friend to signup with your referral link',
      'They will play their 1st Tournament',
      'You will get ${details.referrerRewardSetting.value} ${details.referrerRewardSetting.coinType} coins & your friend will get ${details.referredRewardSetting.value} ${details.referredRewardSetting.coinType} coins.',
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          AspectRatio(
            aspectRatio: 1 / 1,
            child: Container(
              width: double.infinity,
              // height: 350,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
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
                        'EARN ${details.referrerRewardSetting.value}',
                        style: GoogleFonts.bricolageGrotesque(
                          fontWeight: FontWeight.w900,
                          fontSize: 36,
                        ),
                      ),
                      SvgPicture.asset(
                        'assets/images/svg/${details.referrerRewardSetting.coinType}_coin.svg',
                        height: 28,
                      ),
                    ],
                  ),
                  Text(
                    'Invite your friends & family on RookTook. And you’ll earn ${details.referrerRewardSetting.value} ${details.referrerRewardSetting.coinType} coins on their 1st tournament',
                    textAlign: TextAlign.center,
                    textScaler: TextScaler.noScaling,
                  ),
                ],
              ),
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
                spacing: 16,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your referral link',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Color(0xff7D8082),
                            ),
                          ),
                          Text(
                            'play.rooktook.com/${details.referralId}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Color(0xffEFEDED),
                            ),
                            textScaler: TextScaler.noScaling,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: MaterialButton(
                      onPressed: () {
                        SharePlus.instance.share(
                          ShareParams(
                            text:
                                'Join RookTook and get ${details.referredRewardSetting.value} ${details.referredRewardSetting.coinType} Coins FREE!\nSign up with my link and get your bonus after your first tournament:\nrooktook.com/invite?ref=${details.referralId}',
                          ),
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
                          // width: 24,
                          // height: 24,
                          padding: const EdgeInsets.all(8),
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
                            margin: const EdgeInsets.only(left: 28),
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
