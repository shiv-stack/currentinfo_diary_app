import 'package:flutter/material.dart';

class AppLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double strokeWidth;
  final bool centered;
  final double? value;

  const AppLoadingIndicator({
    super.key,
    this.color,
    this.strokeWidth = 4.0,
    this.centered = true,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final indicator = CircularProgressIndicator.adaptive(
      value: value,
      valueColor: color != null ? AlwaysStoppedAnimation<Color>(color!) : null,
      strokeWidth: strokeWidth,
    );

    if (centered) {
      return Center(child: indicator);
    }
    return indicator;
  }
}
