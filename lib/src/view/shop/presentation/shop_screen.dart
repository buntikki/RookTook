import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    ref.read(walletProvider.notifier).getUserLedger();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopProvider);
    final fetchProvider = ref.watch(fetchShopItems);
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        actions: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xff2B2D30),
              border: Border.all(color: const Color(0xff464A4F), width: .5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              spacing: 8,
              children: [
                SvgPicture.asset('assets/images/svg/gold_coin.svg'),
                Text(
                  '${ref.watch(walletProvider).walletInfo.goldCoins}',
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(color: Color(0xffEFEDED), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
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
        ],
      ),
      body: fetchProvider.when(
        data:
            (_) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  const Text(
                    'Store',
                    style: TextStyle(
                      color: Color(0xffEFEDED),
                      fontWeight: FontWeight.w600,
                      fontSize: 32,
                    ),
                  ),
                  Expanded(
                    child:
                        state.items.isEmpty
                            ? const Center(child: Text('No items right now'))
                            : RefreshIndicator.adaptive(
                              onRefresh: () async {
                                ref.invalidate(fetchShopItems);
                              },
                              child: ListView.separated(
                                itemCount: state.items.length,
                                // shrinkWrap: true,
                                separatorBuilder: (context, index) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final item = state.items[index];
                                  return ShopItemCard(item: item);
                                },
                              ),
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
