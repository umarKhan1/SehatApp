import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;
  final FirebaseAuth _auth;

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Set flag to keep user logged in
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('stay_logged_in', true);
    return credential;
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Set flag to keep user logged in
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('stay_logged_in', true);
    return credential;
  }

  Future<void> signOut() async {
    // Clear the stay logged in flag
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('stay_logged_in', false);
    return _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
