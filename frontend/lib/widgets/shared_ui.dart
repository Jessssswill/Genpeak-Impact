import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

/// Simple glass-style card — subtle frosted look
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = AppRadius.card,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppColors.cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle top edge gradient highlight
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.06),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Section title with simple left accent
class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? color;
  const SectionTitle({super.key, required this.title, this.subtitle, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return Row(
      children: [
        Container(
          width: 3, height: 20,
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        if (icon != null) ...[
          Icon(icon, size: 16, color: c),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: c, fontSize: 15, fontWeight: FontWeight.w600)),
              if (subtitle != null)
                Text(subtitle!, style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Mora (currency) display badge
class MoraBadge extends StatelessWidget {
  final String amount;
  final double fontSize;
  const MoraBadge({super.key, required this.amount, this.fontSize = 14});

  @override
  Widget build(BuildContext context) {
    // Make gold badge richer
    final goldColor = AppColors.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: goldColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.badge),
        border: Border.all(color: goldColor.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: goldColor.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Image.asset('assets/images/currency/Item_Mora.webp', width: 18, height: 18, fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Icon(Icons.monetization_on_rounded, size: 16, color: goldColor)),
        const SizedBox(width: 5),
        Text(amount, style: TextStyle(color: goldColor, fontSize: fontSize, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

/// Renders an enemy image from either a server URL or a base64 data URI.
class EnemyImageWidget extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget fallback;

  const EnemyImageWidget({
    super.key,
    required this.url,
    required this.fallback,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('data:')) {
      final comma = url.indexOf(',');
      if (comma == -1) return fallback;
      final bytes = base64Decode(url.substring(comma + 1));
      return Image.memory(bytes, width: width, height: height, fit: fit,
          errorBuilder: (_, _, _) => fallback);
    }
    return Image.network(
      ApiService.resolveImageUrl(url),
      width: width, height: height, fit: fit,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}
