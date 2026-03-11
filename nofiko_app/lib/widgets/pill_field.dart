import 'package:flutter/material.dart';
import '../utils/color.dart';

class PillField extends StatelessWidget {
  const PillField({
    super.key,
    required this.controller,
    required this.hint,
    this.prefixLabel,
    this.prefixIcon,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
  });

  final TextEditingController  controller;
  final String                 hint;
  final String?                prefixLabel;
  final IconData?              prefixIcon;
  final bool                   obscure;
  final Widget?                suffix;
  final TextInputType?         keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color:        ColorPalette.field,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: ColorPalette.border, width: 1.2),
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          SizedBox(
            width: 26,
            child: prefixLabel != null
                ? Text(
                    prefixLabel!,
                    style: const TextStyle(
                        color: ColorPalette.teal,
                        fontSize: 18,
                        fontWeight: FontWeight.w400),
                  )
                : Icon(prefixIcon, color: ColorPalette.teal, size: 18),
          ),
          Container(width: 1, height: 22, color: ColorPalette.border),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller:   controller,
              obscureText:  obscure,
              keyboardType: keyboardType,
              style: const TextStyle(color: ColorPalette.text, fontSize: 15),
              cursorColor:  ColorPalette.teal,
              decoration: InputDecoration(
                border:         InputBorder.none,
                hintText:       hint,
                hintStyle:      const TextStyle(color: ColorPalette.hint, fontSize: 15),
                isDense:        true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (suffix != null) ...[suffix!, const SizedBox(width: 16)],
        ],
      ),
    );
  }
}