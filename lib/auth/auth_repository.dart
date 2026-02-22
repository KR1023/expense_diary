import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthCancelledException implements Exception {
  const AuthCancelledException();
}

class AuthRepository {
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    String? googleServerClientId,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleServerClientId = googleServerClientId;

  final FirebaseAuth _firebaseAuth;
  final String? _googleServerClientId;
  bool _googleInitialized = false;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signUp(String email, String password) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signIn(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() {
    return Future.wait([
      _firebaseAuth.signOut(),
      GoogleSignIn.instance.signOut(),
    ]).then((_) {});
  }

  Future<UserCredential> signInWithGoogle() async {
    if (!_googleInitialized) {
      await GoogleSignIn.instance.initialize(
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
    return _firebaseAuth.signInWithCredential(credential);
  }
}
