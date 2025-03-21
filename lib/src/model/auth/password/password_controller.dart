import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'password_controller.g.dart';

class PasswordState {
  final String password;
  final bool isPasswordVisible;

  PasswordState({
    this.password = '',
    this.isPasswordVisible = false,
  });

  PasswordState copyWith({
    String? password,
    bool? isPasswordVisible,
  }) {
    return PasswordState(
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
    );
  }
}

@riverpod
class PasswordController extends _$PasswordController {
  @override
  PasswordState build() {
    return PasswordState();
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  bool get isButtonEnabled => state.password.isNotEmpty;

  String getPasswordStrengthText() {
    final password = state.password;
    if (password.length < 4) {
      return 'Weak password';
    } else if (password.length < 8) {
      return 'Fair password';
    } else if (password.length < 12) {
      return 'Good password';
    } else {
      return 'Strong password';
    }
  }

  Color getPasswordStrengthColor() {
    final password = state.password;
    if (password.length < 4) {
      return Colors.red;
    } else if (password.length < 8) {
      return Colors.orange;
    } else if (password.length < 12) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }
}
