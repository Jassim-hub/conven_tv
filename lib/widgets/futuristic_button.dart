/// FuturisticButton Widget for Conven TV
/// -------------------------------------------------------------
/// A reusable, animated button styled for the futuristic orange theme.
/// Use for primary actions throughout the app for consistent UX.
/// -------------------------------------------------------------

import 'package:flutter/material.dart';

class FuturisticButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const FuturisticButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 8,
        shadowColor: Colors.orangeAccent,
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
