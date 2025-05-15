import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WalletAddCoinsPage extends StatelessWidget {
  const WalletAddCoinsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: const Text('Wallet', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 40,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xff2B2D30),
                border: Border.all(color: const Color(0xff464A4F), width: .5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      spacing: 16,
                      children: [
                        SvgPicture.asset(
                          'assets/images/svg/silver_coin.svg',
                          height: 40,
                          width: 40,
                        ),
                        const Column(
                          children: [
                            Text(
                              '2500',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
                            ),
                            Text(
                              'Current Silver coins',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Color(0xff7D8082),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xff2B291F),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                      border: Border(top: BorderSide(color: Color(0xff464A4F), width: .5)),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '₹1 = 100 Silver Coins',
                      style: TextStyle(color: Color(0xff959494)),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select no. of coins',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xffEFEDED)),
                ),
                Row(
                  spacing: 8,
                  children: List.generate(4, (index) {
                    List<int> values = [10, 20, 50, 100];
                    return Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xff2B2D30),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xff464A4F)),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '₹',
                              style: TextStyle(fontSize: 24, color: Color(0xff54C339), height: 0),
                            ),
                            Text(
                              values[index].toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                color: Color(0xffEFEDED),
                                height: 0,
                              ),
                            ),
                            const Text(
                              'COINS',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xff7D8082),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: const Color(0xffF4F4F4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xffFCEABD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Add to current coins ',
                          style: TextStyle(color: Color(0xff926C0D)),
                        ),
                        Row(
                          spacing: 4,
                          children: [
                            const Text('2000', style: TextStyle(color: Color(0xff222222))),
                            SvgPicture.asset('assets/images/svg/silver_coin.svg'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ListView.separated(
                    itemCount: 5,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (BuildContext context, int index) {
                      final List<String> titles = [
                        'Deposit Amount',
                        'Govt. Tax (28% GST)',
                        'Total',
                        'Discount',
                        'Total Pay',
                      ];
                      final String title = titles[index];
                      return Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(title, style: const TextStyle(color: Color(0xff222222))),
                            const Text(
                              '₹ 500',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xff222222),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
