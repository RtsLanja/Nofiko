// widgets/custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../utils/color.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final bool showLogout;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack    = false,
    this.showLogout  = false,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return AppBar(
      backgroundColor:        ColorPalette.bg,
      elevation:              0,
      centerTitle:            true,
      automaticallyImplyLeading: false,

      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: ColorPalette.text),
              onPressed: () => Navigator.pop(context),
            )
          : null,

      title: Text(
        title,
        style: const TextStyle(
          color:         ColorPalette.text,
          fontSize:      18,
          fontWeight:    FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),

      actions: [
        // Actions personnalisées
        if (actions != null) ...actions!,

        // Bouton logout
        if (showLogout)
          IconButton(
            icon: const Icon(Icons.logout, color: ColorPalette.hint),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
      ],

      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: ColorPalette.border, height: 1),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}