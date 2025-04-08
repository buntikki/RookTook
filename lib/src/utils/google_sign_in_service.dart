import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';


class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      // If user cancels sign-in, return null
      if (googleUser == null) return null;
      
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;



      void printLongString(String text) {
        const int chunkSize = 800;
        for (var i = 0; i < text.length; i += chunkSize) {
          final chunk = text.substring(i, i + chunkSize > text.length ? text.length : i + chunkSize);
          print(chunk);
        }
      }

      printLongString("--- ----- -Access Token: ${googleAuth.accessToken}");
      printLongString("--- ---- ----ID Token: ${googleAuth.idToken}");


      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in with the credential and return the user credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
