import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/auth/username_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'username_controller.g.dart';


@riverpod
class UsernameController extends _$UsernameController {
  @override
  UsernameState build() {
    return UsernameState();
  }

  void updateUsername(String value) {
    // Trim the value if it exceeds max length
    String newUsername = value;
    if (value.length > state.maxLength) {
      newUsername = value.substring(0, state.maxLength);
    }

    // Check if username is valid (not empty and not just whitespace)
    bool isValid = newUsername.trim().isNotEmpty;

    state = state.copyWith(
      username: newUsername,
      isValid: isValid,
    );
  }

  void clearUsername() {
    state = state.copyWith(
      username: '',
      isValid: false,
    );
  }
}
