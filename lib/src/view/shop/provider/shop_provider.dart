// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:rooktook/src/model/auth/bearer.dart';
import 'package:rooktook/src/model/auth/session_storage.dart';
import 'package:rooktook/src/network/http.dart';
import 'package:rooktook/src/widgets/success_failed_overlay.dart';

final shopProvider = StateNotifierProvider((ref) => ShopNotifier());

final fetchShopItems = FutureProvider((ref) => ref.read(shopProvider.notifier).fetchShopItems());
final fetchOrders = FutureProvider((ref) => ref.read(shopProvider.notifier).fetchOrders());

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

        state = state.copyWith(
          items:
              (decodedResponse['products'] as List<dynamic>)
                  .map((x) => ShopItemModel.fromMap(x as Map<String, dynamic>))
                  .toList(),
        );
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
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;
        if (decodedResponse['status'] == 'success') {
          showSuccessOverlay(context);
          return;
        }
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
