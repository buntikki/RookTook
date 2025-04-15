import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rooktook/src/model/user/user_repository_providers.dart';

part 'login_controller.g.dart';

// Login states to represent different stages
enum LoginState {
  initial,
  userExists,
  userDoesNotExist,
}

// Result of username check with data
class UsernameCheckResult {
  final LoginState state;
  final String usernameOrEmail;
  final String? errorMessage;

  UsernameCheckResult({
    required this.state,
    required this.usernameOrEmail,
    this.errorMessage,
  });
}

@riverpod
class LoginController extends _$LoginController {


  @override
  AsyncValue<UsernameCheckResult?> build() {
    // Initialize with null result
    return const AsyncValue.data(null);
  }

  // Check if username exists
  Future<void> checkUsername(String usernameOrEmail) async {
    if (usernameOrEmail.isEmpty) {
      state = AsyncValue.error(
        'Please enter a username or email',
        StackTrace.current,
      );
      return;
    }

    // Set loading state
    state = const AsyncLoading();
    try {
      final exists = await ref.read(userExistsProvider(username: usernameOrEmail).future);

      final result = UsernameCheckResult(
        state: exists == true ? LoginState.userExists : LoginState.userDoesNotExist,
        usernameOrEmail: usernameOrEmail,
      );

      state = AsyncValue.data(result);
    } catch (e, st) {
      // Log the error with Crashlytics
      FirebaseCrashlytics.instance.recordError(e, st);

      // Set error state
      state = AsyncValue.error(
        e is Exception ? e.toString() : 'Failed to check username',
        st,
      );
    }
  }

  // Reset the controller state
  void reset() {
    state = const AsyncValue.data(null);
  }
}
