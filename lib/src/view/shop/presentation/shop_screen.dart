import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rooktook/src/model/auth/auth_session.dart';
import 'package:rooktook/src/view/auth/providers/auth_provider.dart';
import 'package:rooktook/src/view/common/container_clipper.dart';
import 'package:rooktook/src/view/common/pro_tag.dart';
import 'package:rooktook/src/view/home/home_provider.dart';
import 'package:rooktook/src/view/home/home_tab_screen.dart';
import 'package:rooktook/src/view/home/iap_provider.dart';
import 'package:rooktook/src/view/shop/presentation/shop_item_details_screen.dart';
import 'package:rooktook/src/view/shop/presentation/shop_orders_screen.dart';
import 'package:rooktook/src/view/shop/provider/shop_provider.dart';
import 'package:rooktook/src/view/wallet/provider/wallet_provider.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(walletProvider.notifier).getUserLedger();
    ref.read(shopProvider.notifier).fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopProvider);
    final fetchProvider = ref.watch(fetchShopItems);
    final walletInfo = ref.watch(walletProvider).walletInfo;
    final uniqueId = ref.watch(authSessionProvider)?.user.id.value;
    final isLoading = ref.watch(openXoxoLoadingProvider);
    final isPremium = ref.watch(homeProvider).isPremium;
    final isAvailableRemote = ref.watch(iapProvider).isAvailableRemote;
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Store',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xffEFEDED)),
        ),
        actions: [
          // Container(
          //   padding: const EdgeInsets.all(8),
          //   decoration: BoxDecoration(
          //     color: const Color(0xff2B2D30),
          //     border: Border.all(color: const Color(0xff464A4F), width: .5),
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   child: Row(
          //     spacing: 8,
          //     children: [
          //       SvgPicture.asset('assets/images/svg/gold_coin.svg'),
          //       Text(
          //         '${ref.watch(walletProvider).walletInfo.goldCoins}',
          //         textScaler: TextScaler.noScaling,
          //         style: const TextStyle(color: Color(0xffEFEDED), fontWeight: FontWeight.w500),
          //       ),
          //     ],
          //   ),
          // ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShopOrdersScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xff2B2D30),
                border: Border.all(color: const Color(0xff464A4F), width: .5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset('assets/images/svg/Buy.svg'),
            ),
          ),
          // GestureDetector(
          //   onTap: () {
          //     Navigator.push(context, InAppPurchaseScreen.route());
          //   },
          //   child: Container(
          //     margin: const EdgeInsets.symmetric(horizontal: 8),
          //     padding: const EdgeInsets.all(8),
          //     decoration: BoxDecoration(
          //       color: const Color(0xff2B2D30),
          //       border: Border.all(color: const Color(0xff464A4F), width: .5),
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //     child: SvgPicture.asset('assets/images/svg/Buy.svg'),
          //   ),
          // ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(fetchShopItems);
          ref.invalidate(fetchOrders);
          ref.read(walletProvider.notifier).getUserLedger();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Instant Store',
                    style: TextStyle(
                      color: Color(0xffEFEDED),
                      fontWeight: FontWeight.w500,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    spacing: 10,
                    children: List.generate(2, (index) {
                      return Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xff2B2D30),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xff464A4F), width: 1),
                            gradient: const LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [Color(0xff3C3C3C), Color(0xff222222)],
                            ),
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
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  // if (_available && _products.isNotEmpty)
                  MaterialButton(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minWidth: double.infinity,
                    color:
                        !isAvailableRemote
                            ? const Color(0xff54C339)
                            : isPremium
                            ? const Color(0xff54C339)
                            : const Color(0xff2B2D30),
                    onPressed:
                        !isAvailableRemote
                            ? () async {
                              if (isLoading || uniqueId == null) return;

                              ref.read(openXoxoLoadingProvider.notifier).state = true;

                              try {
                                await ref.read(
                                  openXOXO(
                                    OpenXOXOParams(uniqueId: uniqueId, context: context),
                                  ).future,
                                );
                              } finally {
                                ref.read(openXoxoLoadingProvider.notifier).state = false;
                              }
                            }
                            : !isPremium
                            ? () {
                              openBattlepassUpgradeSheet(context, ref);
                            }
                            : () async {
                              if (!isPremium) {
                              } else {
                                if (isLoading || uniqueId == null) return;

                                ref.read(openXoxoLoadingProvider.notifier).state = true;

                                try {
                                  await ref.read(
                                    openXOXO(
                                      OpenXOXOParams(uniqueId: uniqueId, context: context),
                                    ).future,
                                  );
                                } finally {
                                  ref.read(openXoxoLoadingProvider.notifier).state = false;
                                }
                              }
                            },
                    child:
                        isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                            : !isAvailableRemote
                            ? const Text(
                              'REDEEM COINS',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            )
                            : isPremium
                            ? const Text(
                              'REDEEM COINS',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            )
                            : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 8,
                              children: [
                                ProTag(),
                                Text(
                                  'ACCESS STORE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'More Rewards. Instant Redemption.',
                      style: TextStyle(
                        color: Color(0xff7D8082),
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                  fetchProvider.when(
                    data: (data) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Basic Store',
                            style: TextStyle(
                              color: Color(0xffEFEDED),
                              fontWeight: FontWeight.w500,
                              fontSize: 24,
                            ),
                          ),
                          const Text(
                            'Basic store redemption will take 4 working days to process your order.',
                            style: TextStyle(
                              color: Color(0xff7D8082),
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (state.items.isEmpty)
                            const Center(child: Text('No items right now'))
                          else
                            ListView.separated(
                              itemCount: state.items.length,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              separatorBuilder: (context, index) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final item = state.items[index];
                                return ShopItemCard(item: item);
                              },
                            ),
                        ],
                      );
                    },
                    error: (error, stackTrace) => const SizedBox.shrink(),
                    loading: () => const Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShopItemCard extends StatelessWidget {
  const ShopItemCard({super.key, required this.item, this.isShowArrow = true});

  final ShopItemModel item;
  final bool isShowArrow;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ShopItemDetailsScreen(item: item)),
        );
      },
      child: Container(
        height: 108,
        decoration: BoxDecoration(
          color: const Color(0xff2B2D30),
          border: Border.all(color: const Color(0xff464A4F), width: .5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          spacing: 4,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Show a placeholder or error widget
                      return const Icon(Icons.broken_image);
                    },
                  ),
                ),
              ),
            ),
            Column(
              spacing: 4,
              children: List.generate(
                16,
                (index) => Expanded(child: Container(height: 4, width: 1, color: Colors.white24)),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                    ).copyWith(right: isShowArrow ? 60 : null, top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          maxLines: 2,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                          textScaler: TextScaler.noScaling,
                        ),
                        Text(
                          item.brandName,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff959494),
                          ),
                          overflow: TextOverflow.ellipsis,
                          textScaler: TextScaler.noScaling,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                    ).copyWith(right: isShowArrow ? 60 : null, bottom: 12),
                    child: Row(
                      spacing: 8,
                      children: [
                        SvgPicture.asset(
                          'assets/images/svg/${item.coinType}_coin.svg',
                          height: 16.0,
                        ),
                        Text(
                          '${item.coinRequired}',
                          textScaler: TextScaler.noScaling,
                          style: const TextStyle(fontWeight: FontWeight.w700),
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
    );
  }
}
