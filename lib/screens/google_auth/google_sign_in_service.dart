import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final GoogleSignInService _googleSignInService = GoogleSignInService._();

  GoogleSignInService._();

  factory GoogleSignInService() => _googleSignInService;

  /* ***************** */

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late final FirebaseAuth _auth = FirebaseAuth.instanceFor(app: Firebase.app("pass_mngr"));

  /// current signed-in user
  GoogleSignInAccount? _user;

  User? get currentUser => _auth.currentUser;

  GoogleSignInAccount? get currentAccount => _user;

  Future<bool> signIn({bool silent = false}) async {
    try {
      final GoogleSignInAccount? googleUser =
          silent ? await _googleSignIn.signInSilently() : await _googleSignIn.signIn();

      if (googleUser == null) return false;
      _user = googleUser;

      // if (silent) return true;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (e) {
      print("google sign in error: $e");
      return false;
    }

    return true;
  }

  Future<void> singOut() async {
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.disconnect();
      _auth.signOut();
      _user = null;
    }
  }
}
