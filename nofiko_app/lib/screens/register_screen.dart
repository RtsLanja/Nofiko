import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import '../utils/color.dart';
import '../widgets/pill_field.dart';
import '../widgets/hexagonLogo.dart';
import '../widgets/loadingButton.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  late AnimationController _ac;
  late Animation<double> _logoScale;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _logoScale = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
    );
    _formFade = CurvedAnimation(
      parent: _ac,
      curve: const Interval(0.35, 0.9, curve: Curves.easeOut),
    );
    _formSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _ac,
            curve: const Interval(0.35, 0.9, curve: Curves.easeOut),
          ),
        );
    _ac.forward();
  }

  @override
  void dispose() {
    _ac.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorPalette.bg,
      body: Stack(
        children: [
          Positioned(
            top: size.height * 0.06,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ColorPalette.teal.withOpacity(0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.05),
                    ScaleTransition(
                      scale: _logoScale,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 76,
                            height: 76,
                            child: CustomPaint(painter: HexLogoPainter()),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            "Nofiko",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: ColorPalette.text,
                              letterSpacing: 4.0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.07),

                    FadeTransition(
                      opacity: _formFade,
                      child: SlideTransition(
                        position: _formSlide,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PillField(
                              controller: _usernameController,
                              hint: "Nom d'utilisateur",
                              prefixIcon: Icons.person_outline_rounded,
                              keyboardType: TextInputType.text,
                            ),

                            const SizedBox(height: 14),

                            PillField(
                              controller: _emailController,
                              hint: "E-mail",
                              prefixLabel: "@",
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 14),

                            PillField(
                              controller: _passwordController,
                              hint: "Mot de passe",
                              prefixIcon: Icons.star_outline_rounded,
                              keyboardType: TextInputType.visiblePassword,
                              obscure: _obscure,
                              suffix: GestureDetector(
                                onTap: () =>
                                    setState(() => _obscure = !_obscure),
                                child: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: ColorPalette.hint,
                                  size: 18,
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            LoadingButton(
                              text: "S'inscrire",
                              isLoading: auth.isLoading,
                              onTap: () async {
                                try {
                                  await auth.register(
                                    _usernameController.text.trim(),
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  );
                                  if (context.mounted && auth.token != null) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const HomeScreen(),
                                      ),
                                    );
                                  }
                                } catch (_) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.red.shade900,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        content: const Text(
                                          "Erreur lors de l'inscription",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),

                            const SizedBox(height: 22),
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "Vous avez déjà un compte ?",
                                    style: TextStyle(
                                      color: ColorPalette.hint,
                                      fontSize: 13,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginScreen(),
                                      ),
                                    ),
                                    child: const Text(
                                      "Se connecter",
                                      style: TextStyle(
                                        color: ColorPalette.tealLight,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
