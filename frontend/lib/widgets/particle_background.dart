import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public widget
// ─────────────────────────────────────────────────────────────────────────────

class ParticleBackground extends StatefulWidget {
  /// Number of particles. Reduce for lower-end devices.
  final int particleCount;

  /// Max frames per second. Defaults to 30 — halves GPU/CPU load vs 60 fps.
  final int targetFps;

  const ParticleBackground({
    super.key,
    this.particleCount = 28,
    this.targetFps = 30,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late final _ParticleSystem _system;
  late final Ticker _ticker;
  late final int _frameMs; // milliseconds between repaints

  double _lastMs = 0;
  Size _size = Size.zero;

  @override
  void initState() {
    super.initState();
    _frameMs = (1000 / widget.targetFps).round();
    _system = _ParticleSystem();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final ms = elapsed.inMilliseconds.toDouble();
    // FPS cap — skip frames that arrive too soon
    if (ms - _lastMs < _frameMs) return;
    _lastMs = ms;
    if (_size == Size.zero) return;
    _system.step(_size); // moves particles + notifies painter
  }

  @override
  void dispose() {
    _ticker.dispose();
    _system.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        _size = constraints.biggest;

        // Lazily seed particles once we know the canvas size
        _system.maybeInit(_size, widget.particleCount);

        // RepaintBoundary isolates canvas redraws from the rest of the tree
        return RepaintBoundary(
          child: CustomPaint(
            painter: _ParticlePainter(_system),
            // Fill the parent — important when used inside Positioned.fill
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Particle system  (ChangeNotifier drives CustomPainter via `repaint:`)
// ─────────────────────────────────────────────────────────────────────────────

class _ParticleSystem extends ChangeNotifier {
  final _rng = Random();
  final List<_Particle> particles = [];
  bool _ready = false;

  void maybeInit(Size size, int count) {
    if (_ready) return;
    _ready = true;
    for (int i = 0; i < count; i++) {
      particles.add(_Particle.random(_rng, size));
    }
  }

  void step(Size size) {
    for (final p in particles) {
      p.update(size);
    }
    notifyListeners(); // triggers only the CustomPaint to repaint
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Particle data
// ─────────────────────────────────────────────────────────────────────────────

class _Particle {
  double x, y, vx, vy;
  final double radius;
  final double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.opacity,
  });

  factory _Particle.random(Random rng, Size size) {
    // Speed: 0.15 – 0.55 px/frame (very gentle drift)
    final speed = 0.15 + rng.nextDouble() * 0.40;
    final angle = rng.nextDouble() * 2 * pi;
    return _Particle(
      x: rng.nextDouble() * size.width,
      y: rng.nextDouble() * size.height,
      vx: cos(angle) * speed,
      vy: sin(angle) * speed,
      // Vary size: smaller particles feel more distant → depth illusion
      radius: 1.2 + rng.nextDouble() * 2.2,
      opacity: 0.18 + rng.nextDouble() * 0.32,
    );
  }

  void update(Size size) {
    x += vx;
    y += vy;
    // Bounce off edges
    if (x < 0) {
      x = 0;
      vx = vx.abs();
    } else if (x > size.width) {
      x = size.width;
      vx = -vx.abs();
    }
    if (y < 0) {
      y = 0;
      vy = vy.abs();
    } else if (y > size.height) {
      y = size.height;
      vy = -vy.abs();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────────────────────────

class _ParticlePainter extends CustomPainter {
  final _ParticleSystem system;

  // Distance within which two particles are connected by a line
  static const double _linkDist = 140.0;
  static const double _linkDistSq = _linkDist * _linkDist;

  // Pre-alloc paint objects — avoids per-frame allocation
  final _dotPaint = Paint()..isAntiAlias = true;
  final _linePaint = Paint()
    ..isAntiAlias = false // lines don't need AA — faster
    ..strokeWidth = 0.7;

  _ParticlePainter(this.system) : super(repaint: system);

  @override
  void paint(Canvas canvas, Size size) {
    final pts = system.particles;
    if (pts.isEmpty) return;

    // ── Connection lines ─────────────────────────────────────────────────────
    // O(n²) but n ≤ 35, so ≤ 595 pairs — negligible
    for (int i = 0; i < pts.length - 1; i++) {
      final a = pts[i];
      for (int j = i + 1; j < pts.length; j++) {
        final b = pts[j];
        final dx = a.x - b.x;
        final dy = a.y - b.y;
        final distSq = dx * dx + dy * dy;
        if (distSq >= _linkDistSq) continue;

        // Fade line opacity with distance
        final t = 1.0 - distSq / _linkDistSq;
        _linePaint.color =
            AppColors.primary.withValues(alpha: t * t * 0.14);
        canvas.drawLine(Offset(a.x, a.y), Offset(b.x, b.y), _linePaint);
      }
    }

    // ── Dots ─────────────────────────────────────────────────────────────────
    for (final p in pts) {
      _dotPaint.color = AppColors.primary.withValues(alpha: p.opacity);
      canvas.drawCircle(Offset(p.x, p.y), p.radius, _dotPaint);
    }
  }

  @override
  // Repaint is driven by the ChangeNotifier — no need to compare old/new
  bool shouldRepaint(_ParticlePainter _) => false;
}
