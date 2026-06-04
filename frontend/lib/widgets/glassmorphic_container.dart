import 'package:flutter/material.dart';
import 'dart:ui' as ui;

enum GlassTier {
  subtle,    // blur 10 — cards, chips
  standard,  // blur 18 — search bars, containers
  prominent, // blur 28 — dialogs, overlays
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
        blur = 10;
        fillAlpha = 0.07;
        borderAlpha = 0.10;
        break;
      case GlassTier.standard:
        blur = 18;
        fillAlpha = 0.10;
        borderAlpha = 0.16;
        break;
      case GlassTier.prominent:
        blur = 28;
        fillAlpha = 0.14;
        borderAlpha = 0.22;
        break;
    }

    final tint = tintColor ?? Colors.white;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: tint.withOpacity(fillAlpha),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? Colors.white.withOpacity(borderAlpha),
            ),
            boxShadow: boxShadow,
          ),
          child: Stack(
            children: [
              // Top edge highlight gradient for depth
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.transparent,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: padding,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
