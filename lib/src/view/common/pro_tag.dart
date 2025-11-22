import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rooktook/src/view/home/home_tab_screen.dart';

class ProTag extends ConsumerWidget {
  const ProTag({super.key, this.isProTag = false});
  final bool isProTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        if (isProTag) {
          openBattlepassUpgradeSheet(context, ref, isProTag: true);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xff2B2D30),
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1,
            colors: [Colors.transparent, const Color(0xff54C339).withValues(alpha: .5)],
          ),
          border: Border.all(color: const Color(0xff54C339), width: .5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          spacing: 8,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset('assets/images/svg/pro_icon.svg', height: 16),
            const Text(
              'PRO',
              style: TextStyle(color: Color(0xff54C339), fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
