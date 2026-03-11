import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import '../utils/color.dart';
import '../widgets/pill_field.dart';
import '../widgets/hexagonLogo.dart';
import '../widgets/loadingButton.dart';
import '../widgets/GoogleAuthButton.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
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
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
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
          // Halo teal derrière le logo
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

          // Contenu principal
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.05),

                    // ── Logo + nom ────────────────────────────────────
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
                              color: ColorPalette.text,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4.0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.07),

                    // ── Formulaire ────────────────────────────────────
                    FadeTransition(
                      opacity: _formFade,
                      child: SlideTransition(
                        position: _formSlide,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email
                            PillField(
                              controller: _emailCtrl,
                              hint: "E-mail",
                              prefixLabel: "@",
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 14),

                            // Password
                            PillField(
                              controller: _passwordCtrl,
                              hint: "Password",
                              prefixIcon: Icons.star_outline_rounded,
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

                            const SizedBox(height: 22),
                            Center(
                              child: TextButton(
                                onPressed: () {},
                                child: const Text(
                                  "Mot de passe oublié ?",
                                  style: TextStyle(
                                    color: ColorPalette.hint,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Bouton Login
                            LoadingButton(
                              text: "Se connecter",
                              isLoading: auth.isLoading,
                              onTap: () async {
                                try {
                                  await auth.login(
                                    _emailCtrl.text,
                                    _passwordCtrl.text,
                                  );
                                  if (auth.token != null && context.mounted) {
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
                                          "Identifiants incorrects",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),

                            const SizedBox(height: 14),

                            Center(
                              child: Text(
                                "------------- ou  -------------",
                                style: TextStyle(
                                  color: ColorPalette.hint,
                                  fontSize: 13,
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            GoogleSignInButton(
                              onTap: () async {
                                try {
                                  await auth.loginWithGoogle();
                                  print('eto zao');
                                  if (auth.token != null && context.mounted) {
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
                                          "Echec d'authentification",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),

                            const SizedBox(height: 14),
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "Vous n'avez pas de compte ?",
                                    style: TextStyle(
                                      color: ColorPalette.hint,
                                      fontSize: 13,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterScreen(),
                                      ),
                                    ),
                                    child: const Text(
                                      "S'inscrire",
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

                    SizedBox(height: size.height * 0.04),
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
