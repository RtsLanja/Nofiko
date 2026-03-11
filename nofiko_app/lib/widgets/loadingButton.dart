import 'package:flutter/material.dart';
import '../utils/color.dart';

class LoadingButton extends StatelessWidget {
  const LoadingButton({ super.key ,required this.text,required this.isLoading, required this.onTap});
  final String       text;
  final bool          isLoading;
  final VoidCallback  onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [ColorPalette.tealDark, ColorPalette.teal, ColorPalette.tealLight],
            begin:  Alignment.centerLeft,
            end:    Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color:      ColorPalette.teal.withOpacity(0.40),
              blurRadius: 22,
              offset:     const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white))
              : Text(
                  text,
                  style: TextStyle(
                    color:         Colors.white,
                    fontSize:      17,
                    fontWeight:    FontWeight.w600,
                    letterSpacing: 1.4,
                  ),
                ),
        ),
      ),
    );
  }
}
