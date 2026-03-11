import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/utils/secure_storage.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;
  final SecureStorage _storage = SecureStorage();

  Future<void> login(String email, String password) async {
    final response = await _dio.post(
      "/auth/login",
      data: {"username": email, "password": password},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    print("Réponse du serveur : ${response.data}");

    final accessToken = response.data['tokens']['access_token'];
    final refreshToken = response.data['tokens']['refresh_token'];

    print("Access token reçu : $accessToken");
    print("Refresh token reçu : $refreshToken");

    await _storage.saveAccessToken(accessToken);
    await _storage.saveRefreshToken(refreshToken);
  }

  Future<void> register(String username,String email, String password) async {
    final response = await _dio.post(
      "/auth/register",
      data: {"user_name": username, "email": email, "password": password},
    );

    if (response.statusCode == 201) {
      print("Utilisateur créé avec succès");
      final accessToken = response.data['tokens']['access_token'];
      final refreshToken = response.data['tokens']['refresh_token'];

      print("Access token reçu : $accessToken");
      print("Refresh token reçu : $refreshToken");

      await _storage.saveAccessToken(accessToken);
      await _storage.saveRefreshToken(refreshToken);
    } else {
      print("Erreur lors de la création de l'utilisateur");
    }
  }
  
  Future<void> loginWithGoogle(String idToken) async {
    final response = await _dio.post(
      "/auth/login/google/mobile",
      data: {'id_token': idToken},
      options: Options(
        headers: {'Content-Type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
        final accessToken = response.data['tokens']['access_token'];
        final refreshToken = response.data['tokens']['refresh_token'];

        // 4. Sauvegarde comme un login normal
        await _storage.saveAccessToken(accessToken);
        await _storage.saveRefreshToken(refreshToken);
      } else {
        throw Exception("Erreur serveur");
      }
  }

  Future<String?> refreshToken() async {
    final refreshToken = await _storage.getRefreshToken();

    if (refreshToken == null) return null;

    try {
      final response = await _dio.post(
        "/auth/refresh",
        data: {"refresher": refreshToken},
      );

      final newAccessToken = response.data["access_token"];
      final newRefreshToken = response.data["refresh_token"];

      await _storage.saveAccessToken(newAccessToken);
      await _storage.saveRefreshToken(newRefreshToken);

      return newAccessToken;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    final refreshToken = await _storage.getRefreshToken();
    print("refresh token : ${refreshToken}");
    final response = await _dio.post(
      "/auth/logout",
      queryParameters: {"refresh_token": refreshToken},
    );

    print("Réponse du serveur lors du logout : ${response.data}");

    await _storage.deleteAccessToken();
    await _storage.deleteRefreshToken();
  }
}
