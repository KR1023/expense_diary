import 'package:expense_diary/const/firebase_auth_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthCancelledException implements Exception {
  const AuthCancelledException();
}

class AuthRepository {
  AuthRepository({FirebaseAuth? firebaseAuth, String? googleServerClientId})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleServerClientId = googleServerClientId;

  final FirebaseAuth _firebaseAuth;
  final String? _googleServerClientId;
  bool _googleInitialized = false;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signUp(String email, String password) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential;
  }

  Future<UserCredential> signIn(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential;
  }

  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      GoogleSignIn.instance.signOut(),
    ]);
  }

  Future<UserCredential> signInWithGoogle() async {
    if (!_googleInitialized) {
      await GoogleSignIn.instance.initialize(
        clientId: _googleClientIdForCurrentPlatform(),
        serverClientId: _googleServerClientId,
      );
      _googleInitialized = true;
    }

    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthCancelledException();
      }
      rethrow;
    }

    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-google-id-token',
        message: 'Google Sign-In did not return an ID token.',
      );
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final result = await _firebaseAuth.signInWithCredential(credential);
    return result;
  }

  String? _googleClientIdForCurrentPlatform() {
    if (kIsWeb) return null;
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => FirebaseAuthConfig.googleIosClientId,
      _ => null,
    };
  }
}
