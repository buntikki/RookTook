import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rooktook/src/model/auth/auth_repository.dart';
import 'package:rooktook/src/model/auth/auth_session.dart';
import 'package:rooktook/src/model/notifications/notification_service.dart';
import 'package:rooktook/src/network/http.dart';
import 'package:rooktook/src/network/socket.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> signIn() async {
    state = const AsyncLoading();

    final appAuth = ref.read(appAuthProvider);

    try {
      final session = await ref.withClient((client) => AuthRepository(client, appAuth).signIn());

      await ref.read(authSessionProvider.notifier).update(session);

      // register device and reconnect to the current socket once the session token is updated
      await Future.wait([
        ref.read(notificationServiceProvider).registerDevice(),
        // force reconnect to the current socket with the new token
        ref.read(socketPoolProvider).currentClient.connect(),
      ]);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUp(String email, String username, String password) async {
    state = const AsyncLoading();
    final appAuth = ref.read(appAuthProvider);
    try {
      final session = await ref.withClient((client) =>
          AuthRepository(client, appAuth).signUp(email, username, password)
      );
      await ref.read(authSessionProvider.notifier).update(session);
      await Future.wait([
        ref.read(notificationServiceProvider).registerDevice(),
        ref.read(socketPoolProvider).currentClient.connect(),
      ]);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithPassword(String username, String password) async {
    state = const AsyncLoading();

    final appAuth = ref.read(appAuthProvider);

    try {
      final session = await ref.withClient((client) => AuthRepository(client, appAuth).signInWithPassword(username, password));

      await ref.read(authSessionProvider.notifier).update(session);

      // register device and reconnect to the current socket once the session token is updated
      await Future.wait([
        ref.read(notificationServiceProvider).registerDevice(),
        // force reconnect to the current socket with the new token
        ref.read(socketPoolProvider).currentClient.connect(),
      ]);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<GoogleSignInResult> verifyGoogleSignIn(String idToken) async {
    state = const AsyncLoading();
    final appAuth = ref.read(appAuthProvider);

    try {
      final result = await ref.withClient((client) =>
          AuthRepository(client, appAuth).verifyGoogleSignIn(idToken));
      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<AuthSessionState?> signInWithGoogle(GoogleSignInResult verificationResult) async {
    state = const AsyncLoading();
    final appAuth = ref.read(appAuthProvider);

    try {
      final session = await ref.withClient((client) =>
          AuthRepository(client, appAuth).signInWithGoogle(verificationResult)
      );

      if (session != null) {
        await ref.read(authSessionProvider.notifier).update(session);

        // register device and reconnect to the current socket once the session token is updated
        await Future.wait([
          ref.read(notificationServiceProvider).registerDevice(),
          // force reconnect to the current socket with the new token
          ref.read(socketPoolProvider).currentClient.connect(),
        ]);
      }

      state = const AsyncValue.data(null);
      return session;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> signUpWithGoogle(String email, String username, String idToken) async {
    state = const AsyncLoading();
    final appAuth = ref.read(appAuthProvider);

    try {
      final session = await ref.withClient((client) =>
          AuthRepository(client, appAuth).signUpWithGoogle(email, username, idToken)
      );

      await ref.read(authSessionProvider.notifier).update(session);

      await Future.wait([
        ref.read(notificationServiceProvider).registerDevice(),
        ref.read(socketPoolProvider).currentClient.connect(),
      ]);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<AppleSignInResult> verifyAppleSignIn(String identityToken, String appleUserId) async {
    state = const AsyncLoading();
    final appAuth = ref.read(appAuthProvider);

    try {
      final result = await ref.withClient((client) =>
          AuthRepository(client, appAuth).verifyAppleSignIn(identityToken, appleUserId)
      );
      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<AuthSessionState?> signInWithApple(AppleSignInResult verificationResult) async {
    state = const AsyncLoading();
    final appAuth = ref.read(appAuthProvider);

    try {
      final session = await ref.withClient((client) =>
          AuthRepository(client, appAuth).signInWithApple(verificationResult)
      );

      if (session != null) {
        await ref.read(authSessionProvider.notifier).update(session);

        // register device and reconnect to the current socket once the session token is updated
        await Future.wait([
          ref.read(notificationServiceProvider).registerDevice(),
          // force reconnect to the current socket with the new token
          ref.read(socketPoolProvider).currentClient.connect(),
        ]);
      }

      state = const AsyncValue.data(null);
      return session;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }


  Future<void> signUpWithApple(String email, String username, String appleUserId) async {
    state = const AsyncLoading();
    final appAuth = ref.read(appAuthProvider);

    try {
      final session = await ref.withClient((client) =>
          AuthRepository(client, appAuth).signUpWithApple(email, username, appleUserId)
      );

      await ref.read(authSessionProvider.notifier).update(session);

      await Future.wait([
        ref.read(notificationServiceProvider).registerDevice(),
        ref.read(socketPoolProvider).currentClient.connect(),
      ]);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final appAuth = ref.read(appAuthProvider);

    try {
      await ref.read(notificationServiceProvider).unregister();
      await ref.withClient((client) => AuthRepository(client, appAuth).signOut());
      await ref.read(authSessionProvider.notifier).delete();
      // force reconnect to the current socket
      await ref.read(socketPoolProvider).currentClient.connect();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteAccount() async {
    state = const AsyncLoading();
    final appAuth = ref.read(appAuthProvider);

    try {
      await ref.withClient((client) => AuthRepository(client, appAuth).deleteAccount());
      await signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
