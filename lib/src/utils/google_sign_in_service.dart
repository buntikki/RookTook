import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInUserInfo {
  final String idToken;
  final String email;

  GoogleSignInUserInfo({
    required this.idToken,
    required this.email,
  });
}

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Sign in with Google using Firebase Authentication
  Future<GoogleSignInUserInfo> signInWithGoogle() async {
    try {
      // Start the Google sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception('Failed to get ID token from Google');
      }
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      return GoogleSignInUserInfo(
        idToken: idToken,
        email: googleUser.email
      );
    } catch (error) {
      throw Exception('Google sign in failed: $error');
    }
  }
}
