import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Color? color;

  const PrimaryButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: color != null
          ? ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            )
          : null,
      child: Text(title),
    );
  }
}
