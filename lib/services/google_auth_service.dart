import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import '../core/constants/google_constants.dart';

class GoogleAuthService {
  GoogleAuthService._();

  static final GoogleAuthService instance = GoogleAuthService._();

  Future<void>? _ready;

  Future<void> init() {
    return _ready ??= GoogleSignIn.instance.initialize(
      clientId: kIsWeb ? GoogleConstants.webClientId : null,
      serverClientId: kIsWeb ? null : GoogleConstants.webClientId,
    );
  }

  Stream<GoogleSignInAuthenticationEvent> get events =>
      GoogleSignIn.instance.authenticationEvents;


  Future<String?> signInWithPicker() async {
    await init();
    try {
      final account = await GoogleSignIn.instance.authenticate();
      return account.authentication.idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }
}