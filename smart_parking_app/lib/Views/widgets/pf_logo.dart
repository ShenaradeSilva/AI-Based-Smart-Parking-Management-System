import 'package:flutter/material.dart';

class PFLogo extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? textColor;

  const PFLogo({
    super.key,
    this.size = 50,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF2E5AAC),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: Text(
          'PF',
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
