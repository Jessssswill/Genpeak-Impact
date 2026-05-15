import 'package:flutter/material.dart';
import 'dart:ui' as ui;

enum GlassTier {
  subtle,    // blur 8 — cards, chips
  standard,  // blur 14 — search bars, containers
  prominent, // blur 22 — dialogs, overlays
}

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final GlassTier tier;
  final double borderRadius;
  final Color? tintColor;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.tier = GlassTier.standard,
    this.borderRadius = 14,
    this.tintColor,
    this.borderColor,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    double blur;
    double fillAlpha;
    double borderAlpha;

    switch (tier) {
      case GlassTier.subtle:
        blur = 8;
        fillAlpha = 0.05;
        borderAlpha = 0.10;
        break;
      case GlassTier.standard:
        blur = 14;
        fillAlpha = 0.08;
        borderAlpha = 0.16;
        break;
      case GlassTier.prominent:
        blur = 22;
        fillAlpha = 0.12;
        borderAlpha = 0.22;
        break;
    }

    final tint = tintColor ?? Colors.white;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint.withValues(alpha: fillAlpha),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? Colors.white.withValues(alpha: borderAlpha),
            ),
            boxShadow: boxShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}
