import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class AppleSignInUserInfo {
  final String identityToken;
  final String email;
  final String userId;

  AppleSignInUserInfo({
    required this.identityToken,
    required this.email,
    required this.userId,
  });
}

class AppleSignInService {
  String generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<AppleSignInUserInfo> signInWithApple() async {
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      // Request credential for the currently signed in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Debug logging
      debugPrint('Apple credential received - Identity Token available: ${appleCredential.identityToken != null}');

      if (appleCredential.identityToken == null) {
        throw Exception('No identity token received from Apple');
      }

      if (appleCredential.email == null && appleCredential.userIdentifier == null) {
        throw Exception('No email or user identifier received from Apple');
      }

      // Return user info
      return AppleSignInUserInfo(
        identityToken: appleCredential.identityToken!,
        email: appleCredential.email!,
        userId: appleCredential.userIdentifier!,
      );
    } catch (e) {
      debugPrint('Error signing in with Apple: $e');
      rethrow;
    }
  }
}
