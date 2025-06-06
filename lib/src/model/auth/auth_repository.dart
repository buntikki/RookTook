import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rooktook/src/constants.dart';
import 'package:rooktook/src/model/auth/auth_session.dart';
import 'package:rooktook/src/model/auth/bearer.dart';
import 'package:rooktook/src/model/auth/login/login_response.dart';
import 'package:rooktook/src/model/user/user.dart';
import 'package:rooktook/src/network/http.dart';

part 'auth_repository.g.dart';

const redirectUri = 'org.lichess.mobile://login-callback';
const oauthScopes = ['web:mobile'];

@Riverpod(keepAlive: true)
FlutterAppAuth appAuth(Ref ref) {
  return const FlutterAppAuth();
}

class AuthRepository {
  AuthRepository(LichessClient client, FlutterAppAuth appAuth)
    : _client = client,
      _appAuth = appAuth;

  final LichessClient _client;
  final Logger _log = Logger('AuthRepository');
  final FlutterAppAuth _appAuth;

  /// Sign in with Lichess.
  ///
  /// This method uses the [FlutterAppAuth] package to sign in with Lichess using
  /// OAuth 2.0. It first calls [FlutterAppAuth.authorizeAndExchangeCode] to
  /// get an access token, and then calls the Lichess API to get the user's
  /// account information.
  Future<AuthSessionState> signIn() async {
    final authResp = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        kLichessClientId,
        redirectUri,
        allowInsecureConnections: kDebugMode,
        serviceConfiguration: AuthorizationServiceConfiguration(
          authorizationEndpoint: lichessUri('/oauth').toString(),
          tokenEndpoint: lichessUri('/api/token').toString(),
        ),
        scopes: oauthScopes,
      ),
    );

    _log.fine('Got oAuth response $authResp');

    final token = authResp.accessToken;


    if (token == null) {
      throw Exception('Access token not found.');
    }

    final user = await _client.readJson(
      Uri(path: '/api/account'),
      headers: {'Authorization': 'Bearer ${signBearerToken(token)}'},
      mapper: User.fromServerJson,
    );
    debugPrint('==================== $token ${user.lightUser}');
    return AuthSessionState(token: token, user: user.lightUser);
  }

  Future<AuthSessionState> signUp(String email, String username, String password) async {
    final body = {
      'username': username,
      'password': password,
      'email': email
    };

    final authResp = await _client.postReadJson(
      Uri(path: '/api/sign-up'),
      body: json.encode(body),
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      mapper: (json) => LoginResponse.fromJson(json),
    );

    final token = authResp.accessToken;

    if (token == null) {
      throw Exception('Access token not found.');
    }

    final user = await _client.readJson(
      Uri(path: '/api/account'),
      headers: {'Authorization': 'Bearer ${signBearerToken(token)}'},
      mapper: User.fromServerJson,
    );
    debugPrint('==================== $token ${user.lightUser}');
    return AuthSessionState(token: token, user: user.lightUser);
  }


  Future<AuthSessionState> signInWithPassword(String username, String password) async {
    final body = {
      'username': username,
      'password': password
    };

    // Make the login API call
    final authResp = await _client.postReadJson(
      Uri(path: '/api/login'),
      body: json.encode(body),
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      mapper: (json) => LoginResponse.fromJson(json),
    );

    final token = authResp.accessToken;

    if (token == null) {
      throw Exception('Access token not found.');
    }

    final user = await _client.readJson(
      Uri(path: '/api/account'),
      headers: {'Authorization': 'Bearer ${signBearerToken(token)}'},
      mapper: User.fromServerJson,
    );
    debugPrint('==================== $token ${user.lightUser}');
    return AuthSessionState(token: token, user: user.lightUser);
  }

  Future<GoogleSignInResult> verifyGoogleSignIn(String idToken) async {
    final body = {
      'idToken': idToken,
    };
    // Make the verification request
    final response = await _client.postReadJson(
      Uri(path: '/api/auth/google/verify'),
      body: json.encode(body),
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Cookie': 'lila2=6ef19f22350c0866429ba528222d6dcf61604d47-sid=D4Tde5f5NQISuDLoavepMU&access_uri=%2Faccount%2Femail'
      },
      mapper: (json) => json,
    );

    // Check if response contains token fields which indicates successful login
    final bool isLoginResponse = response.containsKey('access_token') &&
        response.containsKey('token') &&
        response.containsKey('token_type');

    if (isLoginResponse) {
      // User already exists, we received login credentials
      final loginResponse = LoginResponse.fromJson(response);

      return GoogleSignInResult(
        userAlreadyRegistered: true,
        idToken: idToken,
        loginResponse: loginResponse,
      );
    } else {
      // We received a verification response
      final bool userAlreadyRegistered = response['user_already_registered'] as bool? ?? false;

      return GoogleSignInResult(
        userAlreadyRegistered: userAlreadyRegistered,
        idToken: idToken,
      );
    }
  }

  Future<AuthSessionState?> signInWithGoogle(GoogleSignInResult verificationResult) async {
      // User already exists, complete the sign-in
      final loginResponse = verificationResult.loginResponse;
      if (loginResponse == null || loginResponse.accessToken == null) {
        throw Exception('Login failed: Invalid response from server');
      }

      final token = loginResponse.accessToken!;

      final user = await _client.readJson(
        Uri(path: '/api/account'),
        headers: {'Authorization': 'Bearer ${signBearerToken(token)}'},
        mapper: User.fromServerJson,
      );
      return AuthSessionState(token: token, user: user.lightUser);
  }


  Future<AuthSessionState> signUpWithGoogle(String email, String username, String idToken) async {
    final body = {
      'username': username,
      'email': email,
      'idToken': idToken
    };

    final authResp = await _client.postReadJson(
      Uri(path: '/api/sign-up'),
      body: json.encode(body),
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      mapper: (json) => LoginResponse.fromJson(json),
    );

    final token = authResp.accessToken;

    if (token == null) {
      throw Exception('Access token not found.');
    }

    final user = await _client.readJson(
      Uri(path: '/api/account'),
      headers: {'Authorization': 'Bearer ${signBearerToken(token)}'},
      mapper: User.fromServerJson,
    );
    debugPrint('==================== $token ${user.lightUser}');
    return AuthSessionState(token: token, user: user.lightUser);
  }

  Future<AppleSignInResult> verifyAppleSignIn(String identityToken, String appleUserId) async {
    final body = {
      'idToken': identityToken,
    };

    // Make the verification request
    final response = await _client.postReadJson(
      Uri(path: '/api/auth/apple/verify'),
      body: json.encode(body),
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      mapper: (json) => json,
    );

    // Check if response contains token fields which indicates successful login
    final bool isLoginResponse = response.containsKey('access_token') &&
        response.containsKey('token') &&
        response.containsKey('token_type');

    if (isLoginResponse) {
      final loginResponse = LoginResponse.fromJson(response);

      return AppleSignInResult(
        userAlreadyRegistered: true,
        appleUserId: appleUserId,
        loginResponse: loginResponse,
      );
    } else {
      // We received a verification response
      final bool userAlreadyRegistered = response['user_already_registered'] as bool? ?? false;
      return AppleSignInResult(
        userAlreadyRegistered: userAlreadyRegistered,
        appleUserId: appleUserId,
      );
    }
  }

  Future<AuthSessionState?> signInWithApple(AppleSignInResult verificationResult) async {
    if (!verificationResult.userAlreadyRegistered) {
      // User doesn't exist, cannot sign in
      return null;
    }

    // User exists, use the login response if available
    if (verificationResult.loginResponse != null) {
      final loginResponse = verificationResult.loginResponse!;
      final token = loginResponse.accessToken;

      if (token == null) {
        throw Exception('Login failed: No access token received');
      }

      final user = await _client.readJson(
        Uri(path: '/api/account'),
        headers: {'Authorization': 'Bearer ${signBearerToken(token)}'},
        mapper: User.fromServerJson,
      );

      return AuthSessionState(token: token, user: user.lightUser);
    } else {
      // This should not typically happen if the server is configured correctly,
      // but included for completeness
      throw Exception('Login failed: Invalid server response');
    }
  }

  Future<AuthSessionState> signUpWithApple(String email, String username, String appleUserId) async {
    final body = {
      'username': username,
      'email': email,
      'appleUserId': appleUserId
    };

    final authResp = await _client.postReadJson(
      Uri(path: '/api/sign-up'),
      body: json.encode(body),
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      mapper: (json) => LoginResponse.fromJson(json),
    );

    final token = authResp.accessToken;

    if (token == null) {
      throw Exception('Access token not found.');
    }

    final user = await _client.readJson(
      Uri(path: '/api/account'),
      headers: {'Authorization': 'Bearer ${signBearerToken(token)}'},
      mapper: User.fromServerJson,
    );

    return AuthSessionState(token: token, user: user.lightUser);
  }

  Future<void> signOut() async {
    final url = Uri(path: '/api/token');
    final response = await _client.delete(Uri(path: '/api/token'));
    if (response.statusCode >= 400) {
      throw http.ClientException('Failed to delete token: ${response.statusCode}', url);
    }
  }

  Future<void> deleteAccount() async {
    final url = Uri(path: '/api/account/delete');
    final response = await _client.delete(url);
    if (response.statusCode >= 400) {
      throw http.ClientException('Failed to delete account: ${response.statusCode}', url);
    }
  }
}


class AppleSignInResult {
  final bool userAlreadyRegistered;
  final String? appleUserId;
  final LoginResponse? loginResponse;

  AppleSignInResult({
    required this.userAlreadyRegistered,
    this.appleUserId,
    this.loginResponse,
  });
}

class GoogleSignInResult {
  final bool userAlreadyRegistered;
  final String? idToken;
  final LoginResponse? loginResponse;

  GoogleSignInResult({
    required this.userAlreadyRegistered,
    this.idToken,
    this.loginResponse,
  });
}
