// widgets/google_sign_in_button.dart

import 'package:flutter/material.dart';
import '../utils/color.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color:        ColorPalette.field,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: ColorPalette.border, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Google SVG inline
            isLoading
                ? SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ColorPalette.teal,
                    ),
                  )
                : _GoogleLogo(),
            const SizedBox(width: 12),
            Text(
              "Continuer avec Google",
              style: TextStyle(
                color:         ColorPalette.text,
                fontSize:      15,
                fontWeight:    FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Logo Google dessiné via CustomPaint (pas besoin d'asset image)
class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22, height: 22,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final r  = size.width  / 2;

    // ── Angles des 4 secteurs Google ──────────────────────────────────────
    // Rouge  : -25° → 65°
    // Jaune  :  65° → 130°
    // Vert   : 130° → 245°
    // Bleu   : 245° → 335° (avec encoche blanche pour le "G")

    const toRad = 3.14159265 / 180;

    final sectors = [
      // [startDeg, sweepDeg, color]
      [-25.0,  90.0, Color(0xFFEA4335)], // rouge
      [ 65.0,  65.0, Color(0xFFFBBC05)], // jaune
      [130.0, 115.0, Color(0xFF34A853)], // vert
      [245.0,  90.0, Color(0xFF4285F4)], // bleu
    ];

    for (final s in sectors) {
      final paint = Paint()
        ..color = s[2] as Color
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(cx, cy)
        ..arcTo(
          Rect.fromCircle(center: Offset(cx, cy), radius: r),
          (s[0] as double) * toRad,
          (s[1] as double) * toRad,
          false,
        )
        ..close();

      canvas.drawPath(path, paint);
    }

    // Trou blanc central (forme le "G")
    canvas.drawCircle(
      Offset(cx, cy), r * 0.58,
      Paint()..color = Colors.white,
    );

    // Barre horizontale bleue du "G"
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - r * 0.13, r * 0.95, r * 0.26),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}