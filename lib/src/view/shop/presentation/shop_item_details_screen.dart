import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rooktook/src/view/common/container_clipper.dart';
import 'package:rooktook/src/view/shop/presentation/create_order_form_screen.dart';
import 'package:rooktook/src/view/shop/provider/shop_provider.dart';

class ShopItemDetailsScreen extends StatelessWidget {
  const ShopItemDetailsScreen({super.key, required this.item});
  final ShopItemModel item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.share, color: Colors.white))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(item.imageUrl)),
            Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
            CustomPaint(
              painter: BorderPainter(),
              child: ClipPath(
                clipper: ContainerClipper(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  width: double.infinity,
                  decoration: const BoxDecoration(color: Color(0xff2B291F)),
                  child: Row(
                    spacing: 16,
                    children: [
                      SvgPicture.asset('assets/images/svg/gold_coin.svg', height: 28),
                      Text(
                        item.coinRequired.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            MaterialButton(
              minWidth: double.infinity,
              color: const Color(0xff54C339),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateOrderFormScreen(item: item)),
                );
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              height: 54,
              child: const Text(
                'Redeem Your Coins',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xff2B2D30),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                children: [
                  _ListTile(
                    icon: 'assets/images/svg/tournament_rules.svg',
                    title: 'Description',
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder:
                            (context) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 16,
                                children: [
                                  Container(
                                    height: 4,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[600],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  Text(item.description),
                                ],
                              ),
                            ),
                      );
                    },
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  _ListTile(
                    icon: 'assets/images/svg/how_to_play.svg',
                    title: 'How to Redeem',
                    onTap: () {},
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

class _ListTile extends StatelessWidget {
  _ListTile({required this.icon, required this.title, required this.onTap});
  final String icon;
  final String title;
  void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      leading: SvgPicture.asset(icon),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.normal),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xff7D8082), size: 16),
      onTap: onTap,
    );
  }
}
