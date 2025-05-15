import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rooktook/src/view/wallet/wallet_add_coins_page.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: const Text('Wallet', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 24,
          children: [
            Row(
              spacing: 8,
              children: List.generate(2, (index) {
                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ).copyWith(top: 32),
                    decoration: BoxDecoration(
                      color: const Color(0xff2B2D30),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xff464A4F), width: 0.5),
                    ),
                    child: Column(
                      spacing: 16,
                      children: [
                        SvgPicture.asset(
                          'assets/images/svg/silver_coin.svg',
                          height: 40,
                          width: 40,
                        ),
                        Column(
                          children: [
                            const Text(
                              '2500',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                                color: Color(0xffEFEDED),
                              ),
                            ),
                            Text(
                              'Silver coins'.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: Color(0xff7D8082),
                              ),
                            ),
                          ],
                        ),
                        MaterialButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const WalletAddCoinsPage()),
                            );
                          },
                          minWidth: double.infinity,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: const Color(0xff54C339),
                          child: const Text('Add Coins'),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            Expanded(
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: const Color(0xffF4F4F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      child: Text(
                        'Ledger',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Color(0xff222222),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: 10,
                        shrinkWrap: true,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Versus Game', style: TextStyle(color: Color(0xff222222))),
                                    Text(
                                      '5 min ago',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff959494),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 4,
                                  children: [
                                    const Text(
                                      '+ 500',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xff54C339),
                                      ),
                                    ),
                                    SvgPicture.asset('assets/images/svg/gold_coin.svg'),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
