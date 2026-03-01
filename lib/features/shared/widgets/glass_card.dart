import 'dart:ui';
import 'package:flutter/material.dart';

/// A frosted glass card for premium UI effect
class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final Border? border;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 10,
    this.opacity = 0.15,
    this.borderRadius,
    this.padding,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(16);
    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
            borderRadius: br,
            border: border ??
                Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
          ),
          child: child,
        ),
      ),
    );
  }
}
