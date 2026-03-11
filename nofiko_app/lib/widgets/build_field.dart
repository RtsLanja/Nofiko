  import 'package:flutter/material.dart';

// ─── Palette bleu marine ────────────────────────────────────────────────────
class _Colors {
static const bg          = Color(0xFFF0F6FF); // fond blanc bleuté
  static const surface     = Color(0xFFFFFFFF); // carte blanche
  static const primary     = Color(0xFFD6E8F7); // bleu pâle moyen
  static const accent      = Color(0xFF1A6FAD); // bleu marine (accent)
  static const accentGlow  = Color(0x331A6FAD); // lueur accent
  static const border      = Color(0xFFB8D4ED); // bordure champ
  static const textPrimary = Color(0xFF0A1E35); // texte principal
  static const textMuted   = Color(0xFF4E7A9B); // texte discret
  static const gold        = Color(0xFFB8892A);// touche dorée
}
  
  Widget buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _Colors.textMuted,
            fontSize: 12,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _Colors.primary.withOpacity(0.35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _Colors.border, width: 1.2),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: const TextStyle(color: _Colors.textPrimary, fontSize: 15),
            cursorColor: _Colors.accent,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: _Colors.textMuted, size: 20),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }