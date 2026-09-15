import 'package:bibomarketmobile/config/env/app_env.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthResult {
  const GoogleAuthResult({required this.idToken, this.email});

  final String idToken;
  final String? email;
}

class GoogleAuthService {
  GoogleAuthService({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              serverClientId: AppEnv.googleServerClientId.isEmpty
                  ? null
                  : AppEnv.googleServerClientId,
              scopes: const ['email', 'profile'],
            );

  final GoogleSignIn _googleSignIn;

  Future<GoogleAuthResult?> signIn() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null;

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw StateError('Token Google introuvable.');
    }

    return GoogleAuthResult(idToken: idToken, email: account.email);
  }

  Future<void> signOut() => _googleSignIn.signOut();
}
