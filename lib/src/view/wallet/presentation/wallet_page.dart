import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:rooktook/src/view/wallet/presentation/wallet_add_coins_page.dart';
import 'package:rooktook/src/view/wallet/presentation/wallet_faq_screen.dart';
import 'package:rooktook/src/view/wallet/presentation/wallet_ledger_page.dart';
import 'package:rooktook/src/view/wallet/provider/wallet_provider.dart';

class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});

  @override
  ConsumerState<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.invalidate(fetchWalletPageDetails);
  }

  final List<Map<String, String>> goldFaqs = [
    {
      'question': 'What are Gold Coins?',
      'answer':
          'Gold Coins are a premium currency awarded for exceptional performance in tournaments.',
    },
    {
      'question': 'How can I earn Gold Coins?',
      'answer': 'Finishing in top positions in select tournaments',
    },
    {
      'question': 'Can I purchase Gold Coins?',
      'answer': 'No, Gold Coins cannot be purchased. They must be earned through gameplay.',
    },
    {
      'question': 'What can I do with Gold Coins?',
      'answer':
          'Gold Coins may be used in the RookTook Store to redeem exclusive items, features, or future rewards.',
    },

    {
      'question': 'Can I use Gold Coins to enter tournaments?',
      'answer': 'No, only Silver Coins can be used for tournament entry.',
    },
    {'question': 'Do Gold Coins expire?', 'answer': 'No, Gold Coins do not expire.'},
    {
      'question': 'Can I convert Gold Coins to Silver Coins?',
      'answer': 'This feature is not currently available but may be added in future versions.',
    },
    {
      'question': 'Why didn’t I receive Gold Coins after winning?',
      'answer':
          'Gold Coins are awarded only for eligible tournaments. Check the tournament rules to confirm eligibility.',
    },
  ];
  final List<Map<String, String>> silverFaqs = [
    {
      'question': 'What are Silver Coins?',
      'answer':
          'Silver Coins are a virtual currency used to participate in tournaments and unlock certain game features.',
    },
    {
      'question': 'How can I earn Silver Coins?',
      'answer':
          'You can earn Silver Coins by Winning 1v1 games, Completing puzzle challenges, Referring friends to the app',
    },
    {
      'question': 'Can I purchase Silver Coins?',
      'answer':
          'Yes, Silver Coins can be purchased using real money via our in-app payment gateway.',
    },
    {
      'question': 'Where can I use Silver Coins?',
      'answer':
          'Silver Coins are required to join tournaments and may be used in future features like power-ups or in-app purchases.',
    },
    {
      'question': 'Do Silver Coins expire?',
      'answer': 'No, Silver Coins do not expire and remain in your wallet unless spent.',
    },
    {
      'question': 'How many Silver Coins do I need to join a tournament?',
      'answer':
          'The entry cost varies for each tournament. Check the tournament details page for the required number of coins.',
    },
    {
      'question': 'Can I transfer Silver Coins to another user?',
      'answer': 'Currently, coin transfers between users are not supported.',
    },
    {
      'question':
          'What happens if I leave or disconnect from a tournament I joined using Silver Coins?',
      'answer': 'Coins used to join a tournament are non-refundable.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(fetchWalletPageDetails);
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: const Text('Wallet'),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WalletFaqScreen(silverFaqs: silverFaqs, goldFaqs: goldFaqs),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: SvgPicture.asset('assets/images/svg/faq.svg'),
            ),
          ),
        ],
      ),
      body: provider.when(
        data: (data) {
          return const WalletPageBodyWidget();
        },
        error: (error, stackTrace) => Center(child: Text('$error')),
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}

class WalletPageBodyWidget extends ConsumerWidget {
  const WalletPageBodyWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletProvider);
    final walletInfo = state.walletInfo;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: 24,
        children: [
          Row(
            spacing: 8,
            children: List.generate(2, (index) {
              return Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4).copyWith(top: 32),
                  decoration: BoxDecoration(
                    color: const Color(0xff2B2D30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xff464A4F), width: 0.5),
                  ),
                  child: Column(
                    spacing: 16,
                    children: [
                      SvgPicture.asset(
                        'assets/images/svg/${index == 0 ? 'silver' : 'gold'}_coin.svg',
                        height: 40,
                        width: 40,
                      ),
                      Column(
                        children: [
                          Text(
                            '${index == 0 ? walletInfo.silverCoins : walletInfo.goldCoins}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                              color: Color(0xffEFEDED),
                            ),
                          ),
                          Text(
                            '${index == 0 ? 'silver' : 'gold'} coins'.toUpperCase(),
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
                          if (index == 0) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const WalletAddCoinsPage()),
                            );
                          } else {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) {
                                return const ConvertCoinsSheet();
                              },
                            );
                          }
                        },
                        minWidth: double.infinity,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xff54C339)),
                        ),
                        color: index == 0 ? const Color(0xff54C339) : Colors.transparent,
                        child: FittedBox(
                          child: Text(
                            (index == 0 ? 'Add Coins' : 'Convert Coins').toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: index == 0 ? null : const Color(0xff54C339),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          if (state.ledgerList.isNotEmpty)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WalletLedgerPage()),
                );
              },
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: const Color(0xffF4F4F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ledger',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Color(0xff222222),
                            ),
                          ),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.arrow_outward, color: Colors.black, size: 20),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      spacing: 8,
                      children: [
                        ...List.generate(
                          state.ledgerList.length < 5 ? state.ledgerList.length : 5,
                          (index) {
                            final ledger = state.ledgerList.reversed.toList()[index];
                            return LedgerTile(ledger: ledger);
                          },
                        ),
                      ],
                    ),
                    // ListView.separated(
                    //   itemCount: state.ledgerList.length < 10 ? state.ledgerList.length : 10,
                    //   shrinkWrap: true,
                    //   separatorBuilder: (context, index) => const SizedBox(height: 8),
                    //   itemBuilder: (BuildContext context, int index) {
                    //     final ledger = state.ledgerList.reversed.toList()[index];
                    //     return LedgerTile(ledger: ledger);
                    //   },
                    // ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ConvertCoinsSheet extends ConsumerStatefulWidget {
  const ConvertCoinsSheet({super.key});

  @override
  ConsumerState<ConvertCoinsSheet> createState() => _ConvertCoinsSheetState();
}

class _ConvertCoinsSheetState extends ConsumerState<ConvertCoinsSheet> {
  int goldCoins = 100;
  final goldCoinController = TextEditingController(text: '100');
  int maxLimit = 1000;

  @override
  void initState() {
    super.initState();
    final int walletCoinsValue = ref.read(walletProvider).walletInfo.goldCoins;
    maxLimit = walletCoinsValue > maxLimit ? maxLimit : walletCoinsValue;
    goldCoins = walletCoinsValue > maxLimit ? maxLimit : walletCoinsValue;
    goldCoinController.text = goldCoins.toString();
    goldCoinController.addListener(
      () => setState(() {
        final int parsedValue = int.parse(
          goldCoinController.text.isEmpty ? '0' : goldCoinController.text.trim(),
        );
        goldCoins = parsedValue;
      }),
    );
  }

  @override
  void dispose() {
    goldCoinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletProvider);
    final conversion = state.goldToSilverConversion;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xff2B2D30)),
            child: const Icon(Icons.close),
          ),
        ),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xff2B2D30),
            border: Border.all(color: const Color(0xff464A4F), width: .5),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: const Text('Convert', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(color: Color(0xff2B2D30)),
          child: Column(
            spacing: 30,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Available Gold Coins',
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
                          ),
                          Row(
                            spacing: 8,
                            children: [
                              Text(
                                '${state.walletInfo.goldCoins}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff54C339),
                                ),
                              ),
                              SvgPicture.asset('assets/images/svg/gold_coin.svg'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                        color: Color(0xffFCEABD),
                      ),
                      child: Text(
                        '1 Gold Coin = ${conversion.value} Silver Coins',
                        style: const TextStyle(color: Color(0xff926C0D)),
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Row(
                    spacing: 60,
                    children: List.generate(2, (index) {
                      return Expanded(
                        child: Column(
                          spacing: 12,
                          children: [
                            SvgPicture.asset(
                              'assets/images/svg/${index == 0 ? 'gold' : 'silver'}_coin.svg',
                              height: 24,
                              width: 24,
                            ),
                            Text(
                              '${index == 0 ? 'Gold' : 'Silver'} Coins',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xff464A4F)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                spacing: 8,
                                mainAxisAlignment:
                                    index == 0
                                        ? MainAxisAlignment.spaceBetween
                                        : MainAxisAlignment.center,
                                children: [
                                  if (index == 0)
                                    GestureDetector(
                                      onTap: () {
                                        if (goldCoins > 1) {
                                          setState(() {
                                            goldCoins -= 1;

                                            goldCoinController.text = goldCoins.toString();
                                          });
                                        }
                                      },
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: const Color(0xff666666),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Icon(CupertinoIcons.minus, size: 20),
                                      ),
                                    ),
                                  if (index == 0)
                                    Expanded(
                                      child: SizedBox(
                                        height: 32,
                                        child: Center(
                                          child: TextField(
                                            textAlign: TextAlign.center,
                                            controller: goldCoinController,
                                            onChanged: (value) {
                                              final int parsedValue = int.parse(
                                                value.isEmpty ? '0' : value.trim(),
                                              );
                                              goldCoinController.text =
                                                  parsedValue > maxLimit ? '$maxLimit' : value;
                                            },
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.digitsOnly,
                                            ],
                                            cursorHeight: 16,
                                            style: const TextStyle(fontSize: 16),
                                            decoration: const InputDecoration(
                                              fillColor: Color(0xff2B2D30),
                                              // fillColor: Colors.white,
                                              filled: true,
                                              // isDense: true,
                                              isCollapsed: true,
                                              contentPadding: EdgeInsets.symmetric(horizontal: 4),
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              errorBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              focusedErrorBorder: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    SizedBox(
                                      height: 32,
                                      child: Center(
                                        child: Text(
                                          '${goldCoins * conversion.value}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  if (index == 0)
                                    GestureDetector(
                                      onTap: () {
                                        if (goldCoins <
                                            (state.walletInfo.goldCoins > maxLimit
                                                ? maxLimit
                                                : state.walletInfo.goldCoins)) {
                                          setState(() {
                                            goldCoins += 1;

                                            goldCoinController.text = goldCoins.toString();
                                          });
                                        }
                                      },
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: const Color(0xff54C339),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Icon(CupertinoIcons.add, size: 20),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),

                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 8,
                    child: Container(
                      height: 24,
                      width: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xff464A4F)),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(CupertinoIcons.equal, size: 16),
                    ),
                  ),
                ],
              ),
              MaterialButton(
                color: const Color(0xff54C339),
                minWidth: double.infinity,
                height: 54,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onPressed: () {
                  if (state.walletInfo.goldCoins > 0 && goldCoinController.text.trim().isNotEmpty) {
                    ref
                        .read(walletProvider.notifier)
                        .convertGoldToSilver(goldCoins: goldCoins, context: context);
                    Navigator.pop(context);
                  }
                },
                child: const Text('CONVERT', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LedgerTile extends StatelessWidget {
  const LedgerTile({super.key, this.radius = 0, this.isBorder = false, required this.ledger});
  final double radius;
  final bool isBorder;
  final LedgerModel ledger;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isBorder ? const Color(0xff2B2D30) : Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: isBorder ? Border.all(color: const Color(0xff464A4F), width: .5) : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Row(
        spacing: 16,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ledger.reason,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isBorder ? const Color(0xffEFEDED) : const Color(0xff222222),
                  ),
                ),
                Text(
                  DateFormat(
                    "dd MMM yyyy 'at' hh:mm a",
                  ).format(DateTime.fromMillisecondsSinceEpoch(ledger.createdAt)),

                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff959494),
                  ),
                ),
              ],
            ),
          ),
          Row(
            spacing: 4,
            children: [
              Text(
                '${ledger.amount > 0 ? '+' : ''}${ledger.amount}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: ledger.amount > 0 ? const Color(0xff54C339) : Colors.red,
                ),
              ),
              SvgPicture.asset('assets/images/svg/${ledger.coinType}_coin.svg', height: 20),
            ],
          ),
        ],
      ),
    );
  }
}
