import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../services/auth_service.dart';
import './dio_interceptor.dart';

class ApiClient {
  late Dio dio;
  static final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }
}
