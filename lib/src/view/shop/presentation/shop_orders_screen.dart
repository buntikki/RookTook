import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rooktook/src/view/shop/provider/shop_provider.dart';

class ShopOrdersScreen extends ConsumerStatefulWidget {
  const ShopOrdersScreen({super.key});

  @override
  ConsumerState<ShopOrdersScreen> createState() => _ShopOrdersScreenState();
}

class _ShopOrdersScreenState extends ConsumerState<ShopOrdersScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.invalidate(fetchOrders);
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = ref.watch(fetchOrders);
    final state = ref.watch(shopProvider);
    final orders = state.orders;
    return Scaffold(
      appBar: AppBar(surfaceTintColor: Colors.transparent, title: const Text('Orders')),
      body: orderProvider.when(
        data:
            (_) =>
                orders.isEmpty
                    ? const Center(child: Text("You don't have any orders yet."))
                    : RefreshIndicator.adaptive(
                      onRefresh: () async {
                        ref.invalidate(fetchOrders);
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          return OrderCard(item: orders[index]);
                        },
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                      ),
                    ),
        error: (error, stackTrace) => Center(child: Text('$error')),
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.item});

  final OrderModel item;
  Color getStatusColor(String status) {
    switch (status) {
      case 'cancelled':
        return Colors.red;
      case 'processing':
        return Colors.orange.shade700;
      case 'confirmed':
        return Colors.green;
      case 'shipped':
        return Colors.blue;
      case 'fulfilled':
        return Colors.green;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Stack(
        children: [
          Container(
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
                      child: Image.network(item.productUrl, fit: BoxFit.cover),
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
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
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
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: getStatusColor(item.status),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.status.toUpperCase(),
                            textScaler: TextScaler.noScaling,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
