import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/app_theme.dart';

/// Particle data model
class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double opacity;
  Color color;
  double life;
  double maxLife;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.opacity,
    required this.color,
    required this.life,
    required this.maxLife,
  });
}

/// Animated particle effect background
/// Creates floating particles that drift across the screen
class ParticleBackground extends StatefulWidget {
  final int particleCount;
  final List<Color> colors;
  final double minSize;
  final double maxSize;
  final double speed;

  const ParticleBackground({
    super.key,
    this.particleCount = 50,
    this.colors = const [
      AppTheme.desertGold,
      AppTheme.turquoise,
      AppTheme.neonGold,
    ],
    this.minSize = 2.0,
    this.maxSize = 6.0,
    this.speed = 1.0,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Particle> particles = [];
  final math.Random random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 16), // ~60 FPS
      vsync: this,
    )..addListener(_updateParticles);

    _controller.repeat();
  }

  void _initializeParticles(Size size) {
    if (particles.isEmpty) {
      for (int i = 0; i < widget.particleCount; i++) {
        particles.add(_createParticle(size));
      }
    }
  }

  Particle _createParticle(Size size) {
    return Particle(
      x: random.nextDouble() * size.width,
      y: random.nextDouble() * size.height,
      vx: (random.nextDouble() - 0.5) * widget.speed * 0.5,
      vy: (random.nextDouble() - 0.5) * widget.speed * 0.3,
      size: widget.minSize +
          random.nextDouble() * (widget.maxSize - widget.minSize),
      opacity: 0.2 + random.nextDouble() * 0.3,
      color: widget.colors[random.nextInt(widget.colors.length)],
      life: 1.0,
      maxLife: 1.0,
    );
  }

  void _updateParticles() {
    if (!mounted) return;

    setState(() {
      for (var particle in particles) {
        particle.x += particle.vx;
        particle.y += particle.vy;

        // Wrap around edges
        if (particle.x < 0) particle.x = MediaQuery.of(context).size.width;
        if (particle.x > MediaQuery.of(context).size.width) particle.x = 0;
        if (particle.y < 0) particle.y = MediaQuery.of(context).size.height;
        if (particle.y > MediaQuery.of(context).size.height) particle.y = 0;

        // Subtle pulsing effect
        particle.opacity = 0.2 +
            (math.sin(_controller.value * 2 * math.pi + particle.x) * 0.1);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _initializeParticles(constraints.biggest);
        return CustomPaint(
          size: constraints.biggest,
          painter: ParticlePainter(particles: particles),
        );
      },
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size * 0.5);

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

/// Shimmer effect for sand-like animation
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2000),
    this.baseColor = AppTheme.deepMidnight,
    this.highlightColor = AppTheme.desertGold,
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
    );
  }
}

/// Glowing trail effect
class GlowTrail extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double intensity;

  const GlowTrail({
    super.key,
    required this.child,
    this.glowColor = AppTheme.neonGold,
    this.intensity = 1.0,
  });

  @override
  State<GlowTrail> createState() => _GlowTrailState();
}

class _GlowTrailState extends State<GlowTrail>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.glowColor
                    .withOpacity(0.3 * widget.intensity * _animation.value),
                blurRadius: 30 * widget.intensity,
                spreadRadius: 5 * widget.intensity,
              ),
            ],
          ),
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}

/// Pulsing glow effect
class PulsingGlow extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final Duration duration;
  final double minIntensity;
  final double maxIntensity;

  const PulsingGlow({
    super.key,
    required this.child,
    this.glowColor = AppTheme.desertGold,
    this.duration = const Duration(milliseconds: 1500),
    this.minIntensity = 0.5,
    this.maxIntensity = 1.0,
  });

  @override
  State<PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<PulsingGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: widget.minIntensity,
      end: widget.maxIntensity,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(0.4 * _animation.value),
                blurRadius: 25 * _animation.value,
                spreadRadius: 3 * _animation.value,
              ),
              BoxShadow(
                color: widget.glowColor.withOpacity(0.2 * _animation.value),
                blurRadius: 50 * _animation.value,
                spreadRadius: 5 * _animation.value,
              ),
            ],
          ),
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}

/// Star constellation background
class StarConstellation extends StatelessWidget {
  final int starCount;
  final Color color;

  const StarConstellation({
    super.key,
    this.starCount = 100,
    this.color = AppTheme.paleGold,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ConstellationPainter(
        starCount: starCount,
        color: color,
      ),
      child: Container(),
    );
  }
}

class ConstellationPainter extends CustomPainter {
  final int starCount;
  final Color color;
  final math.Random random = math.Random(42); // Fixed seed for consistency

  ConstellationPainter({
    required this.starCount,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.3);

    for (int i = 0; i < starCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2 + 0.5;

      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.5);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(ConstellationPainter oldDelegate) => false;
}
