import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomOutlinedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double borderWidth;
  final Color borderColor;
  final double borderRadius;

  const CustomOutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.borderWidth = 1.5,
    this.borderColor = const Color(0xFF008080),
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        HapticFeedback.mediumImpact();
        onPressed();
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: borderColor, width: borderWidth),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: child,
    );
  }
}
