// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:rooktook/src/constants.dart';

import 'package:rooktook/src/model/auth/bearer.dart';
import 'package:rooktook/src/model/auth/session_storage.dart';
import 'package:rooktook/src/network/http.dart';
import 'package:rooktook/src/view/shop/presentation/shop_orders_screen.dart';
import 'package:rooktook/src/view/shop/presentation/xoxo_webview.dart';
import 'package:rooktook/src/widgets/success_failed_overlay.dart';

final shopProvider = StateNotifierProvider((ref) => ShopNotifier());
final openXoxoLoadingProvider = StateProvider<bool>((ref) => false);

final fetchShopItems = FutureProvider((ref) => ref.read(shopProvider.notifier).fetchShopItems());
final fetchOrders = FutureProvider((ref) => ref.read(shopProvider.notifier).fetchOrders());

final openXOXO = FutureProvider.family(
  (ref, OpenXOXOParams params) => ref.read(shopProvider.notifier).openXOXO(params: params),
);

class ShopNotifier extends StateNotifier<ShopState> {
  ShopNotifier() : super(ShopState.initial());

  Future<void> fetchShopItems() async {
    const storage = SessionStorage();
    final data = await storage.read();
    final headers = {
      'Access-Control-Allow-Origin': '*',
      'Origin': 'https://lichess.dev',
      'Authorization': 'Bearer ${signBearerToken(data!.token)}',
    };
    try {
      final response = await http.get(lichessUri('/api/rt-store/product/active'), headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;
        final list =
            (decodedResponse['products'] as List<dynamic>)
                .map((x) => ShopItemModel.fromMap(x as Map<String, dynamic>))
                .toList();
        list.sort((a, b) => a.coinRequired.compareTo(b.coinRequired));
        state = state.copyWith(items: list);
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> fetchOrders() async {
    const storage = SessionStorage();
    final data = await storage.read();
    final headers = {
      'Access-Control-Allow-Origin': '*',
      'Origin': 'https://lichess.dev',
      'Authorization': 'Bearer ${signBearerToken(data!.token)}',
    };
    try {
      final response = await http.get(lichessUri('/api/rt-store/order/all'), headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;

        state = state.copyWith(
          orders:
              (decodedResponse['orders'] as List<dynamic>)
                  .map((x) => OrderModel.fromMap(x as Map<String, dynamic>))
                  .toList(),
        );
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> openXOXO({required OpenXOXOParams params}) async {
    const storage = SessionStorage();
    final data = await storage.read();
    final headers = {
      'Access-Control-Allow-Origin': '*',
      'Origin': 'https://lichess.dev',
      'Authorization': 'Bearer ${signBearerToken(data!.token)}',
      'Content-Type': 'application/json',
      'X-API-Key':
          '00033dbbd7e3c2388d922359abe33193012c6fb36f3854706c2a6b1c7187b5154292acc867fb4e54db67635b5d8ef3ce2d58403ac51e15c95cba3e81e48f01b9',
    };
    try {
      final response = await http.post(
        Uri.parse(
          releaseMode
              ? 'https://api.rooktook.com/api/v1/xoxoday/sso/token'
              : 'https://dev-api.rooktook.com/api/v1/xoxoday/sso/token',
        ),
        headers: headers,
        body: jsonEncode({'userId': params.uniqueId}),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;
        Navigator.push(
          params.context,
          XoxoWebview.route(decodedResponse['data']['redirectUrl'] as String),
        );
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> createOrder({
    required String name,
    required String email,
    required String address,
    required String number,
    required String productId,
    required BuildContext context,
  }) async {
    const storage = SessionStorage();
    final data = await storage.read();
    final headers = {
      'Access-Control-Allow-Origin': '*',
      'Origin': 'https://lichess.dev',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${signBearerToken(data!.token)}',
    };
    try {
      final response = await http.post(
        lichessUri('/api/rt-store/order/create'),
        headers: headers,
        body: jsonEncode({
          'fullName': name,
          'email': email,
          'mobile': '+91$number',
          'address': address,
          'productId': productId,
        }),
      );
      final Map<String, dynamic> decodedResponse =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        if (decodedResponse['status'] == 'success') {
          showSuccessOverlay(context);
          await Future.delayed(const Duration(seconds: 1), () async {
            Navigator.pop(context);
            await fetchOrders();
          });
          return;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              decodedResponse['error'] as String? ?? 'An error occured',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
        return;
      }
    } catch (e) {
      log(e.toString());
    }
    showFailedOverlay(context);
    return;
  }
}

class ShopState {
  final List<ShopItemModel> items;
  final List<OrderModel> orders;
  ShopState({required this.items, required this.orders});

  factory ShopState.initial() {
    return ShopState(items: [], orders: []);
  }
  ShopState copyWith({List<ShopItemModel>? items, List<OrderModel>? orders}) {
    return ShopState(items: items ?? this.items, orders: orders ?? this.orders);
  }
}

class ShopItemModel {
  final String id;
  final String name;
  final String coinType;
  final int coinRequired;
  final String imageUrl;
  final String imageKey;
  final String description;
  final String brandName;
  final bool status;
  final int createdAt;
  final int updatedAt;

  ShopItemModel({
    required this.id,
    required this.name,
    required this.coinType,
    required this.coinRequired,
    required this.imageUrl,
    required this.imageKey,
    required this.description,
    required this.brandName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShopItemModel.initial() {
    return ShopItemModel(
      id: '',
      name: '',
      coinType: '',
      coinRequired: 0,
      imageUrl: '',
      imageKey: '',
      description: '',
      brandName: '',
      status: false,
      createdAt: 0,
      updatedAt: 0,
    );
  }

  factory ShopItemModel.fromMap(Map<String, dynamic> map) {
    return ShopItemModel(
      id: map['id'] as String,
      name: map['name'] as String,
      coinType: map['coinType'] as String,
      coinRequired: map['coinRequired'] as int,
      imageUrl: map['image']['url'] as String,
      imageKey: map['image']['key'] as String,
      description: map['description'] as String,
      brandName: map['brandName'] as String,
      status: map['status'] as bool,
      createdAt: map['createdAt'] as int,
      updatedAt: map['updatedAt'] as int,
    );
  }
}

class OrderModel {
  final String id;
  final String fullName;
  final String productName;
  final String productUrl;
  final String brandName;
  final String email;
  final String mobile;
  final String address;
  final String rtProductId;
  final String status;
  final int createdAt;
  final int updatedAt;

  OrderModel({
    required this.id,
    required this.fullName,
    required this.productName,
    required this.productUrl,
    required this.brandName,
    required this.email,
    required this.mobile,
    required this.address,
    required this.rtProductId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as String,
      fullName: map['fullName'] as String,
      productName: map['productInfo']['name'] as String,
      email: map['email'] as String,
      mobile: map['mobile'] as String,
      address: map['address'] as String,
      rtProductId: map['rtProductId'] as String,
      productUrl: map['productInfo']['image']['url'] as String,
      brandName: map['productInfo']['brandName'] as String,
      status: map['status'] as String,
      createdAt: map['createdAt'] as int,
      updatedAt: map['updatedAt'] as int,
    );
  }
}

class OpenXOXOParams {
  final String uniqueId;
  final BuildContext context;

  OpenXOXOParams({required this.uniqueId, required this.context});
}
