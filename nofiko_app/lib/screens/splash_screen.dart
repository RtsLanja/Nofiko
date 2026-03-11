import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import '../providers/auth_provider.dart';
import '../utils/color.dart';
import '../widgets/hexagonLogo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final results = await Future.wait([
      authProvider.checkLogin(),
      Future.delayed(const Duration(milliseconds: 1500)), // délai minimum
    ]);

    final loggedIn = results[0] as bool;
    print("User logged in: $loggedIn");

    if (!mounted) return;

    if (loggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 76,
              height: 76,
              child: CustomPaint(painter: HexLogoPainter()),
            ),
            const SizedBox(height: 16),
            const Text(
              "Nofiko",
              style: TextStyle(
                color: ColorPalette.text,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 4.0,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ColorPalette.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
