import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'screens/splash_screen.dart';
import './core/network/api_client.dart';
import './core/network/dio_interceptor.dart';
import './services/auth_service.dart';
import './services/profile_service.dart';
import './services/job_matched_service.dart';
import './providers/job_matched_provider.dart';

const String env = String.fromEnvironment('ENV', defaultValue: 'dev');
void main() async {
  await dotenv.load(fileName: ".env.$env");
  final apiClient = ApiClient();
  final authService = AuthService();

  setupInterceptor(apiClient.dio, authService);
  runApp(MyApp(dio: apiClient.dio));
}

class MyApp extends StatelessWidget {
  final Dio dio;
  const MyApp({super.key, required this.dio});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(ProfileService(dio)),
        ),
        ChangeNotifierProvider(
          create: (_) => JobMatchedProvider(JobMatchedService(dio)),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
