import 'dart:convert';

import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier();
});

class WalletNotifier extends StateNotifier<WalletState> {
  WalletNotifier() : super(WalletState.initial());
  Future<void> getOrderIdAndSessionId() async {
    final response = await http.post(
      Uri.parse('https://sandbox.cashfree.com/pg/orders'),
      headers: {
        'X-Client-Secret': '',
        'X-Client-Id': '',
        'x-api-version': '2023-08-01',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'order_amount': 100,
        'order_currency': 'INR',
        'customer_details': {
          'customer_id': 'USER123',
          'customer_name': 'joe',
          'customer_email': 'joe.s@cashfree.com',
          'customer_phone': '+919876543210',
        },
        'order_meta': {'return_url': 'https://b8af79f41056.eu.ngrok.io?order_id=order_123'},
      }),
    );
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      state = state.copyWith(
        orderId: decodedResponse['order_id'] as String,
        paymentSessionId: decodedResponse['payment_session_id'] as String,
      );
    }
  }

  CFSession? createSession() {
    try {
      final session =
          CFSessionBuilder()
              .setEnvironment(CFEnvironment.SANDBOX)
              .setOrderId('order_1733112xl4KFYufFHMsXp9FoSONZmOzHC')
              .setPaymentSessionId(
                'session_8nwCjiUzPxW6qS9aMIeXLGzXhVgvoztz50xB9n3593djflj72tZWNWx-z-va705_areJJKJj0g6ICLPYvTanBCTieT2IsHHv4D5xL3jwaalMR7JlB-irJjilO9kpayment',
              )
              .build();
      return session;
    } on CFException catch (e) {
      print(e.message);
    }
    return null;
  }

  CFWebCheckoutPayment createWebCheckout() {
    return CFWebCheckoutPaymentBuilder().setSession(createSession()!).build();
  }

  void verifyPayment(String orderId) {
    print('Verify Payment of order id $orderId');
  }

  void paymentError(CFErrorResponse errorResponse, String orderId) {
    print(errorResponse.getMessage());
    print('Error while making payment of order id $orderId');
  }

  void createPaymentGateway() {
    final cfPaymentGatewayService = CFPaymentGatewayService();
    cfPaymentGatewayService.setCallback(verifyPayment, paymentError);
    cfPaymentGatewayService.doPayment(createWebCheckout());
  }
}

class WalletState {
  String? orderId;
  String? paymentSessionId;
  WalletState({this.orderId, this.paymentSessionId});
  factory WalletState.initial() => WalletState();

  WalletState copyWith({String? orderId, String? paymentSessionId}) {
    return WalletState(
      orderId: orderId ?? this.orderId,
      paymentSessionId: paymentSessionId ?? this.paymentSessionId,
    );
  }
}
