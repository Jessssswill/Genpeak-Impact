import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Primary action button
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isExpanded;
  final IconData? icon;
  final Color? color;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final btnColor = color ?? AppColors.primary;
    return SizedBox(
      width: isExpanded ? double.infinity : null,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : () {
          if (onPressed != null) {
            HapticFeedback.lightImpact();
            onPressed!();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: btnColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: btnColor.withOpacity(0.4),
          elevation: 0,
          shadowColor: btnColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ).copyWith(
          elevation: WidgetStateProperty.resolveWith<double>((states) {
            if (states.contains(WidgetState.disabled)) return 0;
            if (states.contains(WidgetState.pressed)) return 2;
            return 8; // subtle default shadow
          }),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20, width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Row(
                mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
      ),
    );
  }
}

/// Secondary outlined button
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isExpanded;
  final IconData? icon;
  final Color? color;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isExpanded = true,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final btnColor = color ?? AppColors.primary;
    return SizedBox(
      width: isExpanded ? double.infinity : null,
      child: OutlinedButton(
        onPressed: onPressed != null ? () {
          HapticFeedback.lightImpact();
          onPressed!();
        } : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: btnColor,
          side: BorderSide(color: btnColor.withOpacity(0.5)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
        child: Row(
          mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(text, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: btnColor)),
          ],
        ),
      ),
    );
  }
}

/// Purchase CTA — gradient fill with breathing glow + press spring
class GoldButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const GoldButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<GoldButton> with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late AnimationController _glowCtrl;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _enabled ? () {
        HapticFeedback.lightImpact();
        widget.onPressed!();
      } : null,
      onTapDown: (_) { if (_enabled) setState(() => _pressed = true); },
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedBuilder(
          animation: _glowCtrl,
          builder: (context, child) {
            final glow = Curves.easeInOut.transform(_glowCtrl.value);
            return Container(
              height: 54,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: _enabled
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.primaryDark],
                      )
                    : null,
                color: _enabled ? null : AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(AppRadius.button),
                border: Border.all(
                  color: _enabled
                      ? AppColors.primary.withOpacity(0.5)
                      : AppColors.cardBorder,
                  width: _enabled ? 1 : 1.5,
                ),
                boxShadow: _enabled && !_pressed
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.25 + glow * 0.35),
                          blurRadius: 16 + glow * 24,
                          offset: Offset(0, 4 + glow * 4),
                          spreadRadius: glow * 4,
                        ),
                      ]
                    : [],
              ),
              child: child,
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Subtle bevel highlight
              if (_enabled)
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.button)),
                      gradient: LinearGradient(colors: [
                        Colors.white.withOpacity(0.22),
                        Colors.white.withOpacity(0.05),
                      ]),
                    ),
                  ),
                ),

              widget.isLoading
                  ? SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: 17,
                              color: _enabled ? Colors.white : AppColors.textMuted),
                          const SizedBox(width: 9),
                        ],
                        Text(
                          widget.text,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: 0.4,
                            color: _enabled ? Colors.white : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Glassmorphism CTA button — frosted glass with animated glow + press spring
class GlassButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? color;

  const GlassButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.color,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late AnimationController _glowCtrl;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final btnColor = widget.color ?? AppColors.primary;

    return GestureDetector(
      onTap: _enabled ? () {
        HapticFeedback.lightImpact();
        widget.onPressed!();
      } : null,
      onTapDown: (_) { if (_enabled) setState(() => _pressed = true); },
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: AnimatedBuilder(
          animation: _glowCtrl,
          builder: (context, child) {
            final glow = Curves.easeInOut.transform(_glowCtrl.value);
            return ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.button),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  height: 54,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _enabled
                          ? [
                              btnColor.withOpacity(0.28 + glow * 0.08),
                              btnColor.withOpacity(0.10 + glow * 0.04),
                            ]
                          : [
                              AppColors.surfaceCard.withOpacity(0.6),
                              AppColors.surfaceCard.withOpacity(0.4),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.button),
                    border: Border.all(
                      color: _enabled
                          ? btnColor.withOpacity(0.45 + glow * 0.2)
                          : AppColors.cardBorder,
                      width: 1.2,
                    ),
                    boxShadow: _enabled && !_pressed
                        ? [
                            BoxShadow(
                              color: btnColor.withOpacity(0.25 + glow * 0.30),
                              blurRadius: 20 + glow * 20,
                              spreadRadius: glow * 4,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: btnColor.withOpacity(0.10),
                              blurRadius: 40,
                              spreadRadius: 6,
                            ),
                          ]
                        : [],
                  ),
                  child: child,
                ),
              ),
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_enabled)
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.button)),
                      gradient: LinearGradient(colors: [
                        Colors.white.withOpacity(0.35),
                        Colors.white.withOpacity(0.05),
                      ]),
                    ),
                  ),
                ),
              if (_enabled)
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadius.button)),
                      gradient: LinearGradient(colors: [
                        Colors.black.withOpacity(0.08),
                        Colors.black.withOpacity(0.02),
                      ]),
                    ),
                  ),
                ),
              widget.isLoading
                  ? SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _enabled ? Colors.white.withOpacity(0.9) : AppColors.textMuted,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: 17,
                              color: _enabled ? Colors.white : AppColors.textMuted),
                          const SizedBox(width: 9),
                        ],
                        Text(
                          widget.text,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: 0.5,
                            color: _enabled ? Colors.white : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
