import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial());

  Future<void> signInWithEmail(String email) async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('email', email);
      state = state.copyWith(isLoading: false, email: email);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: Implement Google sign in logic
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: Implement Apple sign in logic
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

class AuthState {
  final bool isLoading;
  final String? error;
  final String? email;

  AuthState({required this.isLoading, this.error, this.email});

  factory AuthState.initial() {
    return AuthState(isLoading: false);
  }

  AuthState copyWith({bool? isLoading, String? error, String? email}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      email: email ?? this.email,
    );
  }
}
