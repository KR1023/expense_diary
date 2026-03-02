class FirebaseAuthConfig {
  // Web OAuth client ID from Firebase project's google-services.json (client_type = 3).
  // Used by google_sign_in for stable ID token retrieval on Android/iOS.
  static const String googleServerClientId =
      '703096841584-sdk8t1ang9r6lt9bng8dsr2b0g55kqgl.apps.googleusercontent.com';

  // iOS OAuth client ID from Firebase config (client_type = 2, ios_info.bundle_id matched).
  static const String googleIosClientId =
      '703096841584-u56b1ikdpgm9qqdovh67v7apgp1g8paj.apps.googleusercontent.com';
}
