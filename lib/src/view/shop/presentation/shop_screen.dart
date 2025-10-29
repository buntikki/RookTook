import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:rooktook/src/view/common/container_clipper.dart';
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
    // _initializeIAP();
    ref.read(walletProvider.notifier).getUserLedger();
  }

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  bool _available = false;
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];

  static const Set<String> _kProductIds = {'com.rooktook.battlepass_test'};

  Future<void> _initializeIAP() async {
    _available = await _iap.isAvailable();
    if (!_available) {
      print('IAP not available');
      return;
    }

    final ProductDetailsResponse response = await _iap.queryProductDetails(_kProductIds);
    if (response.error != null) {
      print('Error fetching products: ${response.error}');
    } else {
      setState(() {
        _products = response.productDetails;
      });
      print('Products fetched: ${response.productDetails}');
    }

    _subscription = _iap.purchaseStream.listen(
      (purchases) {
        _handlePurchaseUpdates(purchases);
      },
      onDone: () {
        print('Purchase Stream done');
        _subscription.cancel();
      },
      onError: (Object? error) {
        print('Purchase Stream Error: $error');
      },
    );
  }

  void _buyProduct() {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: _products.first);

    // _iap.buyConsumable(purchaseParam: purchaseParam);
    // } else {
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
    // }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _deliverProduct(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        print('Purchase Error: ${purchase.error}');
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  void _deliverProduct(PurchaseDetails purchase) {
    // Unlock features or credit coins
    debugPrint(
      'Purchase delivered: ${purchase.productID}, ${purchase.status} , ${purchase.pendingCompletePurchase}, ${purchase.error}, ${purchase.transactionDate}, ${purchase.purchaseID}',
    );
    debugPrint('Local Verification Data: ${purchase.verificationData.localVerificationData}');
    debugPrint('Server Verification Data: ${purchase.verificationData.serverVerificationData}');
    debugPrint('Source Data: ${purchase.verificationData.source}');
  }

  Future<void> _restorePurchases() async {
    await _iap.restorePurchases();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopProvider);
    final fetchProvider = ref.watch(fetchShopItems);
    final walletInfo = ref.watch(walletProvider).walletInfo;
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
      body: fetchProvider.when(
        data:
            (_) => SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Coins',
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
                  if (_available && _products.isNotEmpty) const SizedBox(height: 24),
                  if (_available && _products.isNotEmpty)
                    MaterialButton(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minWidth: double.infinity,
                      color: const Color(0xff54C339),
                      onPressed: () {
                        _buyProduct();
                      },
                      child: const Text(
                        'REDEEM COINS',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ),
                  const SizedBox(height: 40),
                  const Text(
                    'Premium Rewards',
                    style: TextStyle(
                      color: Color(0xffEFEDED),
                      fontWeight: FontWeight.w500,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (state.items.isEmpty)
                    const Center(child: Text('No items right now'))
                  else
                    RefreshIndicator.adaptive(
                      onRefresh: () async {
                        ref.invalidate(fetchShopItems);
                      },
                      child: ListView.separated(
                        itemCount: state.items.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          return ShopItemCard(item: item);
                        },
                      ),
                    ),
                ],
              ),
            ),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
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
      child: Stack(
        children: [
          ClipPath(
            clipper: isShowArrow ? ContainerClipper() : null,
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
                      (index) =>
                          Expanded(child: Container(height: 4, width: 1, color: Colors.white24)),
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
          ),
          if (isShowArrow)
            Positioned(
              top: 0,
              right: 12,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xff2B2D30),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xff464A4F), width: .5),
                ),
                child: const Icon(Icons.arrow_outward_rounded, color: Colors.white, size: 16),
              ),
            ),
        ],
      ),
    );
  }
}
