import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WalletAddCoinsPage extends StatelessWidget {
  const WalletAddCoinsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(surfaceTintColor: Colors.transparent, title: const Text('Add Silver Coin')),
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
                    final List<int> values = [10, 20, 50, 100];
                    return Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xff2B2D30),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xff464A4F)),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '+',
                              style: TextStyle(fontSize: 24, color: Color(0xff54C339), height: 0),
                            ),
                            Text(
                              '₹${values[index]}',
                              style: const TextStyle(
                                fontSize: 24,
                                color: Color(0xffEFEDED),
                                height: 0,
                              ),
                            ),
                            // const Text(
                            //   'COINS',
                            //   style: TextStyle(
                            //     fontSize: 12,
                            //     color: Color(0xff7D8082),
                            //     fontWeight: FontWeight.w500,
                            //   ),
                            // ),
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffF4F4F4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Summary',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                  ),
                  Column(
                    spacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('You Pay', style: TextStyle(color: Colors.black)),
                            Text(
                              '₹20',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('GST (28%)', style: TextStyle(color: Colors.black)),
                            Text('₹ -5.6', style: TextStyle(color: Color(0xffF77178))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'You Get',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                  ),
                  Column(
                    spacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Silver Coins', style: TextStyle(color: Color(0xff9A710A))),
                            Row(
                              spacing: 4,
                              children: [
                                SvgPicture.asset('assets/images/svg/silver_coin.svg'),
                                const Text(
                                  '1440',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Bonus Silver Coins', style: TextStyle(color: Colors.black)),
                            Row(
                              spacing: 4,
                              children: [
                                SvgPicture.asset('assets/images/svg/silver_coin.svg'),
                                const Text(
                                  '560',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff54C339),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xffFCEABD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Silver Coins',
                          style: TextStyle(color: Color(0xff222222), fontWeight: FontWeight.w600),
                        ),
                        Row(
                          spacing: 4,
                          children: [
                            SvgPicture.asset('assets/images/svg/silver_coin.svg'),
                            const Text(
                              '2000',
                              style: TextStyle(
                                color: Color(0xff222222),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: MaterialButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          height: 54,
          color: const Color(0xff54C339),
          onPressed: () {},
          child: Text(
            'Proceed to pay'.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}
