// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:rooktook/src/model/auth/bearer.dart';
import 'package:rooktook/src/model/auth/session_storage.dart';
import 'package:rooktook/src/network/http.dart';
import 'package:rooktook/src/view/wallet/presentation/wallet_add_coins_page.dart';

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier();
});
final fetchWalletPageDetails = FutureProvider((ref) async {
  await ref.read(walletProvider.notifier).getUserLedger();
});

class WalletNotifier extends StateNotifier<WalletState> {
  WalletNotifier() : super(WalletState.initial());

  Future<void> verifyPayment(String orderId, BuildContext context) async {
    print('Verify Payment of order id $orderId');
    showSuccessOverlay(context);
    await verifyPaymentStatus(orderId: orderId);
  }

  void paymentError(CFErrorResponse errorResponse, String orderId, BuildContext context) {
    // state = state.copyWith(showFailedAnimation: true);
    print(errorResponse.getMessage());
    showFailedOverlay(context);
    print('Error while making payment of order id $orderId');
  }

  Future<void> createPaymentGateway({required int amount, required BuildContext context}) async {
    try {
      final result = await createPaymentOrder(amount: amount);
      if (result != null) {
        final session =
            CFSessionBuilder()
                .setEnvironment(CFEnvironment.SANDBOX)
                .setOrderId(result.$1)
                .setPaymentSessionId(result.$2)
                .build();
        final cfWebCheckout = CFWebCheckoutPaymentBuilder().setSession(session).build();
        final cfPaymentGatewayService = CFPaymentGatewayService();
        cfPaymentGatewayService.setCallback(
          (id) => verifyPayment(id, context),
          (error, id) => paymentError(error, id, context),
        );
        cfPaymentGatewayService.doPayment(cfWebCheckout);
      } else {
        Exception('An error occured!');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getUserWalletInfo() async {
    const storage = SessionStorage();
    final data = await storage.read();
    final headers = {
      'Access-Control-Allow-Origin': '*',
      'Origin': 'https://lichess.dev',
      'Authorization': 'Bearer ${signBearerToken(data!.token)}',
    };
    try {
      final response = await http.get(lichessUri('/api/rt-wallet/info'), headers: headers);
      log(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;

        state = state.copyWith(
          walletInfo: WalletInfoModel.fromMap(
            decodedResponse['walletInfo'] as Map<String, dynamic>,
          ),
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getUserLedger() async {
    const storage = SessionStorage();
    final data = await storage.read();
    final headers = {
      'Access-Control-Allow-Origin': '*',
      'Origin': 'https://lichess.dev',
      'Authorization': 'Bearer ${signBearerToken(data!.token)}',
    };
    try {
      final response = await http.get(lichessUri('/api/rt-wallet/coin-ledger'), headers: headers);
      log(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;

        state = state.copyWith(
          walletInfo: WalletInfoModel.fromMap(
            decodedResponse['walletInfo'] as Map<String, dynamic>,
          ),
          ledgerList: List.from(
            (decodedResponse['coinLedger'] as List<dynamic>)
                .map((e) => LedgerModel.fromMap(e as Map<String, dynamic>))
                .toList(),
          ),
          goldToSilverConversion: GoldToSilverConversion.fromMap(
            decodedResponse['conversionSettings']['goldToSilverRate'] as Map<String, dynamic>,
          ),
          rechargeConversionRate: RechargeConversion.fromMap(
            decodedResponse['conversionSettings']['rechargeConversionRate'] as Map<String, dynamic>,
          ),
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> convertGoldToSilver({required int goldCoins}) async {
    const storage = SessionStorage();
    final data = await storage.read();
    final headers = {
      'Access-Control-Allow-Origin': '*',
      'Origin': 'https://lichess.dev',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${signBearerToken(data!.token)}',
    };
    try {
      final response = await http.put(
        lichessUri('/api/rt-wallet/convert-gold-to-silver'),
        headers: headers,
        body: jsonEncode({'goldCoins': goldCoins}),
      );
      log(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;

        print(decodedResponse);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verifyPaymentStatus({required String orderId}) async {
    const storage = SessionStorage();
    final data = await storage.read();
    final headers = {
      'Access-Control-Allow-Origin': '*',
      'Origin': 'https://lichess.dev',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${signBearerToken(data!.token)}',
    };
    try {
      final response = await http.put(
        lichessUri('/api/rt-wallet/verify-payment-status'),
        headers: headers,
        body: jsonEncode({'orderId': orderId.trim()}),
      );
      log(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;

        state = state.copyWith(
          walletInfo: WalletInfoModel.fromMap(
            decodedResponse['walletInfo'] as Map<String, dynamic>,
          ),
        );
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<(String, String)?> createPaymentOrder({required int amount}) async {
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
        lichessUri('/api/rt-wallet/create-payment-order'),
        headers: headers,
        body: jsonEncode({
          'orderAmount': amount,
          'orderCurrency': 'INR',
          'customerPhone': '+919313096065',
          'note': 'Buying silver coins for rooktook chess app',
        }),
      );
      log(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;

        print(decodedResponse);
        return (
          decodedResponse['orderId'] as String,
          decodedResponse['paymentSessionId'] as String,
        );
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }
}

class WalletState {
  final WalletInfoModel walletInfo;
  final GoldToSilverConversion goldToSilverConversion;
  final RechargeConversion rechargeConversionRate;
  final List<LedgerModel> ledgerList;

  factory WalletState.initial() => WalletState(
    walletInfo: WalletInfoModel.initial(),
    ledgerList: [],
    goldToSilverConversion: GoldToSilverConversion.initial(),
    rechargeConversionRate: RechargeConversion.initial(),
  );

  WalletState({
    required this.walletInfo,
    required this.ledgerList,
    required this.goldToSilverConversion,
    required this.rechargeConversionRate,
  });

  WalletState copyWith({
    WalletInfoModel? walletInfo,
    List<LedgerModel>? ledgerList,
    GoldToSilverConversion? goldToSilverConversion,
    RechargeConversion? rechargeConversionRate,
  }) {
    return WalletState(
      walletInfo: walletInfo ?? this.walletInfo,
      ledgerList: ledgerList ?? this.ledgerList,
      goldToSilverConversion: goldToSilverConversion ?? this.goldToSilverConversion,
      rechargeConversionRate: rechargeConversionRate ?? this.rechargeConversionRate,
    );
  }
}

class LedgerModel {
  final String id;
  final String userId;
  final String coinType;
  final String transactionType;
  final String reason;
  final int createdAt;
  final int updatedAt;
  final int amount;
  final int balanceBefore;
  final int balanceAfter;
  final WalletUserModel user;

  LedgerModel({
    required this.id,
    required this.userId,
    required this.coinType,
    required this.transactionType,
    required this.reason,
    required this.createdAt,
    required this.updatedAt,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.user,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'coinType': coinType,
      'transactionType': transactionType,
      'reason': reason,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'amount': amount,
      'balanceBefore': balanceBefore,
      'balanceAfter': balanceAfter,
      'user': user.toMap(),
    };
  }

  factory LedgerModel.fromMap(Map<String, dynamic> map) {
    return LedgerModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      coinType: map['coinType'] as String,
      transactionType: map['transactionType'] as String,
      reason: map['reason'] as String,
      createdAt: map['createdAt'] as int,
      updatedAt: map['updatedAt'] as int,
      amount: map['amount'] as int,
      balanceBefore: map['balanceBefore'] as int,
      balanceAfter: map['balanceAfter'] as int,
      user: WalletUserModel.fromMap(map['user'] as Map<String, dynamic>),
    );
  }
}

class WalletInfoModel {
  final String id;
  final String userId;
  final int silverCoins;
  final int goldCoins;
  final WalletUserModel user;

  WalletInfoModel({
    required this.id,
    required this.userId,
    required this.silverCoins,
    required this.goldCoins,
    required this.user,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'silverCoins': silverCoins,
      'goldCoins': goldCoins,
      'user': user.toMap(),
    };
  }

  factory WalletInfoModel.initial() {
    return WalletInfoModel(
      id: '',
      userId: '',
      silverCoins: 0,
      goldCoins: 0,
      user: WalletUserModel(id: '', name: ''),
    );
  }
  factory WalletInfoModel.fromMap(Map<String, dynamic> map) {
    return WalletInfoModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      silverCoins: map['silverCoins'] as int,
      goldCoins: map['goldCoins'] as int,
      user: WalletUserModel.fromMap(map['user'] as Map<String, dynamic>),
    );
  }
}

class WalletUserModel {
  final String id;
  final String name;

  WalletUserModel({required this.id, required this.name});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'name': name};
  }

  factory WalletUserModel.fromMap(Map<String, dynamic> map) {
    return WalletUserModel(id: map['id'] as String, name: map['name'] as String);
  }
}

class GoldToSilverConversion {
  final String id;
  final String coinType;
  final int value;
  final bool isActive;

  GoldToSilverConversion({
    required this.id,
    required this.coinType,
    required this.value,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'coinType': coinType, 'value': value, 'isActive': isActive};
  }

  factory GoldToSilverConversion.initial() {
    return GoldToSilverConversion(id: '', coinType: '', value: 0, isActive: false);
  }

  factory GoldToSilverConversion.fromMap(Map<String, dynamic> map) {
    return GoldToSilverConversion(
      id: map['id'] as String,
      coinType: map['coinType'] as String,
      value: map['value'] as int,
      isActive: map['isActive'] as bool,
    );
  }
}

class RechargeConversion {
  final String id;
  final String coinType;
  final int value;
  final bool isActive;

  RechargeConversion({
    required this.id,
    required this.coinType,
    required this.value,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'coinType': coinType, 'value': value, 'isActive': isActive};
  }

  factory RechargeConversion.initial() {
    return RechargeConversion(id: '', coinType: '', value: 0, isActive: false);
  }

  factory RechargeConversion.fromMap(Map<String, dynamic> map) {
    return RechargeConversion(
      id: map['id'] as String,
      coinType: map['coinType'] as String,
      value: map['value'] as int,
      isActive: map['isActive'] as bool,
    );
  }
}
