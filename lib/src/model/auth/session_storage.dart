import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rooktook/src/constants.dart';
import 'package:rooktook/src/db/secure_storage.dart';
import 'package:rooktook/src/model/auth/auth_session.dart';

part 'session_storage.g.dart';

const kSessionStorageKey = '$kLichessHost.userSession';

@Riverpod(keepAlive: true)
SessionStorage sessionStorage(Ref ref) {
  return const SessionStorage();
}

class SessionStorage {
  const SessionStorage();

  Future<AuthSessionState?> read() async {
    final string = await SecureStorage.instance.read(key: kSessionStorageKey);
    if (string != null) {
      return AuthSessionState.fromJson(jsonDecode(string) as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> write(AuthSessionState session) async {
    await SecureStorage.instance.write(
      key: kSessionStorageKey,
      value: jsonEncode(session.toJson()),
    );
  }

  Future<void> delete() async {
    await SecureStorage.instance.delete(key: kSessionStorageKey);
  }
}
