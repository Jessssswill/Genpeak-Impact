import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/particle_background.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _initApp());
  }

  Future<void> _initApp() async {
    final auth = context.read<AuthProvider>();
    await auth.initialize();
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    if (auth.isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.background,
        child: Stack(
          children: [
            // ── Particle network (Three.js-style, 30 fps capped) ─────────
            const Positioned.fill(
              child: ParticleBackground(particleCount: 28, targetFps: 30),
            ),

            // ── Background glow orbs ──────────────────────────────────────
            _GlowOrb(
              color: AppColors.primary,
              size: 340,
              top: -80,
              right: -90,
              pulseDuration: 3200,
              initialDelay: 0,
            ),
            _GlowOrb(
              color: AppColors.secondary,
              size: 280,
              bottom: -90,
              left: -70,
              pulseDuration: 3800,
              initialDelay: 600,
            ),
            _GlowOrb(
              color: AppColors.electro,
              size: 200,
              bottom: 110,
              right: -50,
              pulseDuration: 2900,
              initialDelay: 1200,
            ),

            // ── Main content ──────────────────────────────────────────────
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo — scale bounce in
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.22),
                          AppColors.primary.withValues(alpha: 0.07),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.38),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.18),
                          blurRadius: 32,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.diamond_rounded,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  )
                      .animate()
                      .scaleXY(
                        begin: 0.35,
                        duration: 700.ms,
                        curve: Curves.easeOutBack,
                      )
                      .fadeIn(duration: 500.ms),

                  const SizedBox(height: 36),

                  // Title
                  Text(
                    'GENSHIN IMPORT',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 5,
                    ),
                  )
                      .animate(delay: 380.ms)
                      .fadeIn(duration: 600.ms)
                      .slideY(
                        begin: 0.35,
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .then()
                      .shimmer(
                        delay: 200.ms,
                        duration: 1200.ms,
                        color: AppColors.primaryLight.withValues(alpha: 0.55),
                      ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Marketplace',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      letterSpacing: 3,
                    ),
                  )
                      .animate(delay: 580.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(
                        begin: 0.35,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      ),

                  const SizedBox(height: 60),

                  // Bouncing dots
                  const _BouncingDots()
                      .animate(delay: 900.ms)
                      .fadeIn(duration: 400.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Animated background glow orb ─────────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  final double? top, bottom, left, right;
  final int pulseDuration;
  final int initialDelay;

  const _GlowOrb({
    required this.color,
    required this.size,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.pulseDuration,
    required this.initialDelay,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.13),
              color.withValues(alpha: 0.04),
              Colors.transparent,
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
      )
          .animate(
            onPlay: (c) => c.repeat(reverse: true),
            delay: Duration(milliseconds: initialDelay),
          )
          .scaleXY(
            begin: 0.82,
            end: 1.16,
            duration: Duration(milliseconds: pulseDuration),
            curve: Curves.easeInOut,
          )
          .fadeIn(
            begin: 0.45,
            duration: Duration(milliseconds: pulseDuration),
            curve: Curves.easeInOut,
          ),
    );
  }
}

// ── 3 staggered bouncing dots ─────────────────────────────────────────────────

class _BouncingDots extends StatelessWidget {
  const _BouncingDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.65),
            shape: BoxShape.circle,
          ),
        )
            .animate(
              onPlay: (c) => c.repeat(reverse: true),
              delay: Duration(milliseconds: 180 * i),
            )
            .slideY(
              begin: 0.0,
              end: -1.2,
              duration: 480.ms,
              curve: Curves.easeInOut,
            )
            .fadeIn(begin: 0.45, duration: 480.ms, curve: Curves.easeInOut);
      }),
    );
  }
}
