import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:rooktook/src/constants.dart';
import 'package:rooktook/src/model/auth/bearer.dart';
import 'package:rooktook/src/model/auth/session_storage.dart';
import 'package:rooktook/src/utils/branch_repository.dart';
import 'package:rooktook/src/view/home/home_provider.dart';
import 'package:url_launcher/url_launcher.dart';

final iapProvider = StateNotifierProvider<IapProvider, IapState>((ref) => IapProvider());
final iapLoadingProvider = StateProvider<bool>((ref) => false);
final submitPurchase = FutureProvider.family(
  (ref, SubmitPurchaseParams params) =>
      ref.read(iapProvider.notifier).submitPurchase(params: params),
);

class IapProvider extends StateNotifier<IapState> {
  IapProvider() : super(IapState.initial());
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _subscription.cancel();
    super.dispose();
  }

  Future<void> init() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(minutes: 1),
        ),
      );
      await _remoteConfig.fetchAndActivate().onError((error, stackTrace) {
        log(error.toString());
        return false;
      });
      final value = _remoteConfig.getBool('iapAvailable');
      state = state.copyWith(isAvailableRemote: value);

      // poll every 2 minutes
      _timer = Timer.periodic(const Duration(minutes: 1), (_) async {
        await _remoteConfig.fetchAndActivate().onError((error, stackTrace) {
          log(error.toString());
          return false;
        });
        final value = _remoteConfig.getBool('iapAvailable');

        if (value != state.isAvailableRemote) {
          state = state.copyWith(isAvailableRemote: value);
        }
      });
    } catch (e) {
      log(e.toString());
    }
  }

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final Set<String> _kProductIds = {'rooktook_battlepass'};

  Future<void> initializeIAP(WidgetRef ref) async {
    final available = await _iap.isAvailable();
    print('available: $available');
    state = state.copyWith(isAvailable: available);
    if (available) {
      print('IAP is available');
      final response = await _iap.queryProductDetails(_kProductIds);
      if (response.error != null) {
        print('Error fetching products: ${response.error}');
        state = state.copyWith(isAvailable: false);
        return;
      } else {
        print('products: ${response.productDetails}');
        state = state.copyWith(
          products: response.productDetails,
          isAvailable: response.productDetails.isNotEmpty,
        );
      }
      _subscription = _iap.purchaseStream.listen(
        (purchases) {
          _handlePurchaseUpdates(purchases, ref);
          print('Purchase Stream purchases: ${purchases.length}');
        },
        onDone: () {
          print('Purchase Stream done');
          ref.read(iapLoadingProvider.notifier).state = false;
          _subscription.cancel();
        },
        onError: (Object? error) {
          ref.read(iapLoadingProvider.notifier).state = false;
          print('Purchase Stream Error: $error');
          // ref.read(iapLoadingProvider.notifier).state = false;
        },
      );
    }
  }

  Future<void> manageSubscription() async {
    if (Platform.isIOS) {
      final url = Uri.parse('https://apps.apple.com/account/subscriptions');
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      final url = Uri.parse(
        'https://play.google.com/store/account/subscriptions?sku=rooktook_battlepass&package=com.rooktook',
      );
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> buyProduct(String userId, WidgetRef ref) async {
    print('buyProduct');

    print('userId: $userId');
    print('products: ${state.products}');
    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: state.products.first,
        applicationUserName: userId,
      );

      // _iap.buyConsumable(purchaseParam: purchaseParam);
      // } else {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } on PlatformException catch (e) {
      if (_isUserCancelled(e)) {
        // user dismissed — do nothing (or show a lightweight toast)
        ref.read(iapLoadingProvider.notifier).state = false;
        debugPrint('Purchase cancelled by user.');
        return;
      }
      // real error
      _showError('Purchase failed: ${e.message ?? e.code}');
    } catch (e) {
      print('buyProduct error: $e');
    }
    ref.read(iapLoadingProvider.notifier).state = false;
    // }
    print('buyProduct done');
  }

  bool _isUserCancelled(PlatformException e) {
    final msg = (e.message ?? '').toLowerCase();
    return e.code == 'storekit2_purchase_cancelled' || // iOS StoreKit 2
        e.code == 'storekit_purchase_cancelled' || // older iOS codes
        e.code == 'purchase_cancelled' || // generic
        msg.contains('cancelled by the user') || // your example string
        msg.contains('user cancelled') ||
        msg.contains('user canceled');
  }

  void _showError(String msg) {
    // e.g., ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    debugPrint(msg);
  }

  Future<void> submitPurchase({required SubmitPurchaseParams params}) async {
    const storage = SessionStorage();

    final data = await storage.read();
    final headers = {
      'Access-Control-Allow-Origin': '*',
      'Origin': 'https://lichess.dev',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${signBearerToken(data!.token)}',
      'X-API-Key':
          '00033dbbd7e3c2388d922359abe33193012c6fb36f3854706c2a6b1c7187b5154292acc867fb4e54db67635b5d8ef3ce2d58403ac51e15c95cba3e81e48f01b9',
    };
    try {
      await http.post(
        Uri.parse(
          releaseMode
              ? 'https://api.rooktook.com/api/v1/subscription'
              : 'https://dev-api.rooktook.com/api/v1/subscription',
        ),
        headers: headers,
        body: jsonEncode({
          'userId': data.user.id.value,
          'productId': params.productId,
          'status': params.status,
          'transactionDate': params.transactionDate,
          'purchaseId': params.purchaseId,
          'purchaseToken': params.purchaseToken,
          'source': params.source,
          'autoRenewing': true,
        }),
      );
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> _deliverProduct(PurchaseDetails purchase, WidgetRef ref) async {
    // Unlock features or credit coins

    BranchRepository.trackCustomEvent(
      'user_purchase_pass_completed',
      ref: ref,
      data: {'productId': purchase.purchaseID ?? '', 'status': purchase.status.name},
    );
    await submitPurchase(
      params: SubmitPurchaseParams(
        productId: purchase.productID,
        userId: '',
        status: purchase.status.toString(),
        transactionDate: purchase.transactionDate.toString(),
        purchaseId: purchase.purchaseID ?? '',
        purchaseToken: purchase.verificationData.serverVerificationData,
        source: purchase.verificationData.source,
      ),
    );
    debugPrint(
      'Purchase delivered: ${purchase.productID}, ${purchase.status} , ${purchase.pendingCompletePurchase}, ${purchase.error}, ${purchase.transactionDate}, ${purchase.purchaseID}',
    );
    debugPrint('Local Verification Data: ${purchase.verificationData.localVerificationData}');
    debugPrint('Server Verification Data: ${purchase.verificationData.serverVerificationData}');
    debugPrint('Source Data: ${purchase.verificationData.source}');
    ref.read(homeProvider.notifier).updateIsPremium(true);
  }

  Future<void> restorePurchases(String userId) async {
    await _iap.restorePurchases(applicationUserName: userId);
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases, WidgetRef ref) async {
    print('handlePurchaseUpdates: ${purchases.length}');
    try {
      for (final purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          print('purchase: ${purchase.status}');
          _deliverProduct(purchase, ref);
          if (purchase.pendingCompletePurchase) {
            print('purchase pendingCompletePurchase: ${purchase.status}');
            await _iap.completePurchase(purchase);
          }
          ref.read(iapLoadingProvider.notifier).state = false;
        } else if (purchase.status == PurchaseStatus.error) {
          print('purchase error: ${purchase.status}');
          final errMsg = (purchase.error?.message ?? '').toLowerCase();
          final errCode = (purchase.error?.code ?? '').toLowerCase();
          final userCancelled = errCode.contains('cancel') || errMsg.contains('cancel');
          if (userCancelled) {
            debugPrint('Purchase cancelled by user.');
            ref.read(iapLoadingProvider.notifier).state = false;
            continue;
          }
          _showError('Purchase error: ${purchase.error}');
          submitPurchase(
            params: SubmitPurchaseParams(
              productId: purchase.productID.isEmpty ? 'rooktook_battlepass' : purchase.productID,
              userId: '',
              status: purchase.status.name,
              transactionDate:
                  purchase.transactionDate != null
                      ? purchase.transactionDate!
                      : DateTime.now().toIso8601String(),
              purchaseId: purchase.purchaseID ?? '',
              purchaseToken: purchase.verificationData.serverVerificationData,
              source: purchase.verificationData.source,
            ),
          );
          ref.read(homeProvider.notifier).updateIsPremium(false);
        } else {
          print('purchase: ${purchase.status}');
        }
      }
      ref.read(homeProvider.notifier).updateIsPremium(false);
    } on PlatformException catch (e) {
      if (_isUserCancelled(e)) {
        // user dismissed — do nothing (or show a lightweight toast)
        debugPrint('Purchase cancelled by user.');
        ref.read(iapLoadingProvider.notifier).state = false;
        ref.read(homeProvider.notifier).updateIsPremium(false);
        return;
      }
      // real error
      _showError('Purchase failed: ${e.message ?? e.code}');
    } catch (e) {
      print('handlePurchaseUpdates error: $e');
    }
    ref.read(iapLoadingProvider.notifier).state = false;
  }
}

class IapState {
  final bool isPremium;
  final bool isAvailable;
  final bool isAvailableRemote;
  final List<ProductDetails> products;
  IapState({
    required this.isPremium,
    required this.isAvailable,
    required this.isAvailableRemote,
    required this.products,
  });
  factory IapState.initial() {
    return IapState(isPremium: false, isAvailable: false, isAvailableRemote: false, products: []);
  }

  IapState copyWith({
    bool? isPremium,
    bool? isAvailable,
    bool? isAvailableRemote,
    List<ProductDetails>? products,
  }) {
    return IapState(
      isPremium: isPremium ?? this.isPremium,
      isAvailable: isAvailable ?? this.isAvailable,
      isAvailableRemote: isAvailableRemote ?? this.isAvailableRemote,
      products: products ?? this.products,
    );
  }
}

class SubmitPurchaseParams {
  final String productId;
  final String userId;
  final String status;
  final String transactionDate;
  final String purchaseId;
  final String purchaseToken;
  final String source;

  SubmitPurchaseParams({
    required this.productId,
    required this.userId,
    required this.status,
    required this.transactionDate,
    required this.purchaseId,
    required this.purchaseToken,
    required this.source,
  });
}
