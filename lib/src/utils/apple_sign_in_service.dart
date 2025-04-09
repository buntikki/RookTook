import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class AppleSignInService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  Future<UserCredential?> signInWithApple() async {
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      void printLongString(String text) {
        const int chunkSize = 800;
        for (var i = 0; i < text.length; i += chunkSize) {
          final chunk = text.substring(i, i + chunkSize > text.length ? text.length : i + chunkSize);
          print(chunk);
        }
      }

      printLongString('--- ----- -IDENTITY Token: ${appleCredential.identityToken}');
      //printLongString("--- ---- ----RAW NONCE: ${appleCredential.}");

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in the user with Firebase.
      final authResult = await _auth.signInWithCredential(oauthCredential);
      final User? user = authResult.user;
      if (user != null &&
          user.displayName == null &&
          appleCredential.givenName != null &&
          appleCredential.familyName != null) {
        await user.updateDisplayName('${appleCredential.givenName} ${appleCredential.familyName}');
      }

      return authResult;
    } catch (e) {
      print('Error signing in with Apple: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
