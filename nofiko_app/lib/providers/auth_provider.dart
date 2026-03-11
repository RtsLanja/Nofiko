import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';
import '../core/utils/secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SecureStorage _storage = SecureStorage();

  bool isLoading = false;
  String? token;

  String? get getToken => token;

  static final String google_client_id = dotenv.env["GOOGLE_CLIENT_ID"] ?? "";
  final _googleSignIn = GoogleSignIn(clientId: google_client_id);

  // Vérifie si l’utilisateur a déjà un token
  Future<bool> checkLogin() async {
    token = await _storage.getAccessToken();
    return token != null;
  }

  // Login
  Future<void> login(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      await _authService.login(email, password);
      token = await _storage.getAccessToken();
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      isLoading = true;
      notifyListeners();
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      await _authService.loginWithGoogle(idToken!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    token = null;
    notifyListeners();
  }

  Future<void> register(String username, String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      await _authService.register(username, email, password);
      token = await _storage.getAccessToken();
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
