import 'package:dio/dio.dart';
import '../../services/auth_service.dart';
import '../utils/secure_storage.dart';

void setupInterceptor(Dio dio, AuthService authService) {
  final storage = SecureStorage();

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.getAccessToken();
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
          print("Headers envoyés: ${options.headers}");
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        final options = error.requestOptions;
        if (error.response?.statusCode == 401 &&
            options.extra["retried"] != true) {
          options.extra["retried"] = true;

          final newToken = await authService.refreshToken();
          if (newToken != null) {
            options.headers["Authorization"] = "Bearer $newToken";
            final cloneReq = await dio.fetch(options);
            return handler.resolve(cloneReq);
          }
        }
        return handler.next(error);
      },
    ),
  );
}
