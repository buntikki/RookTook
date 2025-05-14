import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TournamentResult extends StatelessWidget {
  const TournamentResult({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: const Text('Results', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 28)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (BuildContext context, int index) {
          Color? color1;
          Color? color2;
          if (index == 0) {
            color1 = const Color(0xff2B291F);
            color2 = const Color(0xff463F24);
          }
          if (index == 1) {
            color1 = const Color(0xff202C33);
            color2 = const Color(0xff2E4755);
          }
          if (index == 2) {
            color1 = const Color(0xff312F3D);
            color2 = const Color(0xff413C60);
          }
          return TournamentResultCard(color1: color1, color2: color2);
        },
      ),
      bottomSheet: BottomSheet(
        shape: const BeveledRectangleBorder(),
        backgroundColor: Colors.transparent,
        onClosing: () {},
        builder:
            (context) => IntrinsicHeight(
              child: TournamentResultCard(
                margin: const EdgeInsets.all(16).copyWith(top: 0),
                isUserCard: true,
              ),
            ),
      ),
    );
  }
}

class TournamentResultCard extends StatelessWidget {
  const TournamentResultCard({
    super.key,
    this.margin,
    this.isUserCard = false,
    this.color1,
    this.color2,
  });
  final EdgeInsetsGeometry? margin;
  final Color? color1;
  final Color? color2;
  final bool isUserCard;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: isUserCard ? Colors.white : color1 ?? const Color(0xFF2B2D30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xff464a4f), width: .5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 12,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Image.asset('assets/images/profile.png'),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isUserCard ? 'You are here' : 'MagnusCarlsen Flag',
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isUserCard ? const Color(0xff222222) : Colors.white,
                          ),
                        ),
                        const Text(
                          '@magnusCarl',
                          style: TextStyle(
                            color: Color(0xff959494),
                            fontWeight: FontWeight.w500,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      spacing: 4,
                      children: [
                        SvgPicture.asset('assets/images/svg/gold_coin.svg', height: 16, width: 16),
                        Text(
                          '3500',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isUserCard ? const Color(0xff222222) : const Color(0xffEFEDED),
                          ),
                        ),
                      ],
                    ),
                    const Text('Coins', style: TextStyle(color: Color(0xff7D8082), fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(
                height: 0,
                thickness: .5,
                color: isUserCard ? const Color(0xffD9D9D9) : const Color(0xff464A4F),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Row(
                  spacing: 12,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            isUserCard
                                ? const Color(0xffBD980C)
                                : color2 ?? const Color(0xff33373c),
                        border: Border.all(
                          color: isUserCard ? const Color(0xffBD980C) : const Color(0xff464a4f),
                          width: .5,
                        ),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '#01',
                        style: TextStyle(
                          color: Color(0xffEFEDED),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Row(
                      spacing: 8,
                      children: [
                        SvgPicture.asset('assets/images/svg/puzzle.svg', height: 18.0),
                        const Text(
                          '1055',
                          style: TextStyle(color: Color(0xff7D8082), fontSize: 12),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 8,
                      children: [
                        SvgPicture.asset(
                          'assets/images/svg/${isUserCard ? 'tournament_clock_light' : 'tournament_clock'}.svg',
                          height: 18.0,
                        ),
                        const Text(
                          '2h 50m 33s',
                          style: TextStyle(color: Color(0xff7D8082), fontSize: 12),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 8,
                      children: [
                        SvgPicture.asset(
                          'assets/images/svg/${isUserCard ? 'fire_light' : 'fire'}.svg',
                          height: 18.0,
                        ),
                        const Text(
                          '3 Days',
                          style: TextStyle(color: Color(0xff7D8082), fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
