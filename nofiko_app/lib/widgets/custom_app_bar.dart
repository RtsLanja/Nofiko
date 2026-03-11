// widgets/custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../utils/color.dart';
import '../widgets/hexagonLogo.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String        title;
  final List<Widget>? actions;
  final bool          showBack;
  final bool          showLogout;
  final bool          showLogo; 
  final Widget?       leading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack   = false,
    this.showLogout = false,
    this.showLogo   = false,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<AuthProvider>(context, listen: false);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor:          Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness:     Brightness.dark,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: ColorPalette.bg,
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withOpacity(0.20),
              blurRadius: 12,
              offset:     const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: kToolbarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  // ── Gauche ────────────────────────────────────
                  SizedBox(
                    width: 44,
                    child: showBack
                        ? _NavButton(
                            icon:  Icons.arrow_back_ios_new_rounded,
                            onTap: () => Navigator.pop(context),
                          )
                        : leading,
                  ),

                  // ── Centre : logo + titre ─────────────────────
                  Expanded(
                    child: Center(
                      child: showLogo
                          ? _AppBarTitleWithLogo(title: title)
                          : _AppBarTitle(title: title),
                    ),
                  ),

                  // ── Droite : actions + logout ─────────────────
                  SizedBox(
                    width: 44,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (actions != null) ...actions!,
                        if (showLogout)
                          _LogoutButton(
                            onTap: () => _showLogoutDialog(
                                context, authProvider),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Dialog de confirmation logout ──────────────────────────────────
  Future<void> _showLogoutDialog(
      BuildContext context, AuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: ColorPalette.field,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent.withOpacity(0.10),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                  size:  26,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Se déconnecter ?",
                style: TextStyle(
                  color:      ColorPalette.text,
                  fontSize:   17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Tu devras te reconnecter\npour accéder à ton compte.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: ColorPalette.hint, fontSize: 13),
              ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx, false),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color:        ColorPalette.border.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text("Annuler",
                            style: TextStyle(
                              color:      ColorPalette.hint,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx, true),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color:        Colors.redAccent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.redAccent.withOpacity(0.4)),
                      ),
                      child: const Center(
                        child: Text("Quitter",
                            style: TextStyle(
                              color:      Colors.redAccent,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      await authProvider.logout();
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// ─── Titre seul (sans logo) ───────────────────────────────────────────────────
class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            color:         ColorPalette.text,
            fontSize:      18,
            fontWeight:    FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 5),
        Container(
          width: 6, height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: ColorPalette.teal,
          ),
        ),
      ],
    );
  }
}

// ─── Titre avec logo hexagonal ────────────────────────────────────────────────
class _AppBarTitleWithLogo extends StatelessWidget {
  const _AppBarTitleWithLogo({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo hexagonal miniature
        SizedBox(
          width: 28, height: 28,
          child: CustomPaint(painter: HexLogoPainter()),
        ),
        const SizedBox(width: 10),

        // Nom de l'app
        Text(
          title,
          style: const TextStyle(
            color:         ColorPalette.text,
            fontSize:      18,
            fontWeight:    FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(width: 5),

        // Point teal
        Container(
          width: 5, height: 5,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: ColorPalette.teal,
          ),
        ),
      ],
    );
  }
}

// ─── Bouton retour ────────────────────────────────────────────────────────────
class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});
  final IconData     icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color:        ColorPalette.field,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ColorPalette.border, width: 1.2),
        ),
        child: Icon(icon, color: ColorPalette.text, size: 18),
      ),
    );
  }
}

// ─── Bouton logout ────────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color:        Colors.redAccent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.redAccent.withOpacity(0.25),
            width: 1.2,
          ),
        ),
        child: const Icon(
          Icons.logout_rounded,
          color: Colors.redAccent,
          size:  18,
        ),
      ),
    );
  }
}