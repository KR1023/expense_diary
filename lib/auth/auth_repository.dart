import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_diary/core/subscription/subscription_service.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthCancelledException implements Exception {
  const AuthCancelledException();
}

class AuthRepository {
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    String? googleServerClientId,
    SubscriptionService? subscriptionService,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleServerClientId = googleServerClientId,
       _subscriptionService = subscriptionService {
    _bindSubscriptionSync();
  }

  final FirebaseAuth _firebaseAuth;
  final String? _googleServerClientId;
  final SubscriptionService? _subscriptionService;
  bool _googleInitialized = false;
  String? _lastSyncedUid;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signUp(String email, String password) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _syncRevenueCatOnSignIn(credential.user);
    return credential;
  }

  Future<UserCredential> signIn(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _syncRevenueCatOnSignIn(credential.user);
    return credential;
  }

  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      GoogleSignIn.instance.signOut(),
    ]);
    await _syncRevenueCatOnSignOut();
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
    final result = await _firebaseAuth.signInWithCredential(credential);
    await _syncRevenueCatOnSignIn(result.user);
    return result;
  }

  Future<void> _syncRevenueCatOnSignIn(User? user) async {
    await _syncRevenueCatForUser(user, force: true);
  }

  Future<void> _syncRevenueCatOnSignOut() async {
    await _syncRevenueCatForUser(null, force: true);
  }

  void _bindSubscriptionSync() {
    if (_subscriptionService == null) return;

    _firebaseAuth.authStateChanges().listen((user) {
      unawaited(_syncRevenueCatForUser(user));
    });

    unawaited(_syncRevenueCatForUser(_firebaseAuth.currentUser));
  }

  Future<void> _syncRevenueCatForUser(User? user, {bool force = false}) async {
    final subscription = _subscriptionService;
    if (subscription == null) return;

    final uid = user?.uid;
    final normalizedUid =
        uid != null && uid.isNotEmpty
            ? uid
            : null;

    if (!force && normalizedUid == _lastSyncedUid) {
      return;
    }

    try {
      if (normalizedUid == null) {
        await subscription.onUserSignedOut();
      } else {
        await subscription.onUserSignedIn(normalizedUid);
      }
      _lastSyncedUid = normalizedUid;
    } catch (e) {
      debugPrint('AuthRepository RevenueCat sync failed: $e');
      // RevenueCat sync failures must not break auth flows.
    }
  }
}
