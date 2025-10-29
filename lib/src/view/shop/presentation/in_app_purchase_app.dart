import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchaseScreen extends StatefulWidget {
  const InAppPurchaseScreen({super.key});
  static CupertinoPageRoute<void> route() =>
      CupertinoPageRoute(builder: (context) => const InAppPurchaseScreen());
  @override
  _InAppPurchaseScreenState createState() => _InAppPurchaseScreenState();
}

class _InAppPurchaseScreenState extends State<InAppPurchaseScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  bool _available = false;
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];

  static const Set<String> _kProductIds = {'0.001', '0.0001'};

  @override
  void initState() {
    super.initState();
    _initializeIAP();
  }

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
      log('Products fetched: ${response.productDetails}');
    }

    _subscription = _iap.purchaseStream.listen(
      (purchases) {
        _handlePurchaseUpdates(purchases);
      },
      onDone: () {
        _subscription.cancel();
      },
      onError: (Object? error) {
        print('Purchase Stream Error: $error');
      },
    );
  }

  void _buyProduct(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);

    _iap.buyConsumable(purchaseParam: purchaseParam);
    // } else {
    //   _iap.buyNonConsumable(purchaseParam: purchaseParam);
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
    print('Purchase delivered: ${purchase.productID}');
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
    if (!_available) {
      return Scaffold(
        appBar: AppBar(title: const Text('In-App Purchases')),
        body: const Center(child: Text('IAP not available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('In-App Purchases'),
        actions: [IconButton(icon: const Icon(Icons.restore), onPressed: _restorePurchases)],
      ),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return ListTile(
            title: Text(product.title),
            subtitle: Text(product.description),
            trailing: TextButton(child: Text(product.price), onPressed: () => _buyProduct(product)),
          );
        },
      ),
    );
  }
}
