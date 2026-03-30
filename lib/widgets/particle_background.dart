import 'package:flutter/material.dart';
import 'dart:math' as math;

class Particle {
  late double x;
  late double y;
  late double vx;
  late double vy;
  final double radius;
  final double speed;

  Particle({
    required this.radius,
    required this.speed,
  }) {
    vx = (math.Random().nextDouble() - 0.5) * speed;
    vy = (math.Random().nextDouble() - 0.5) * speed;
  }

  void update(double width, double height) {
    x += vx;
    y += vy;

    if (x < 0) {
      x = width;
    } else if (x > width) {
      x = 0;
    }

    if (y < 0) {
      y = height;
    } else if (y > height) {
      y = 0;
    }
  }
}

class ParticleBackgroundPainter extends CustomPainter {
  final List<Particle> particles;
  final Color particleColor;

  ParticleBackgroundPainter({
    required this.particles,
    this.particleColor = const Color(0xFFF4F4F4),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = particleColor.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    for (final particle in particles) {
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticleBackgroundPainter oldDelegate) {
    return true;
  }
}

class ParticleBackground extends StatefulWidget {
  final int particleCount;
  final Color particleColor;
  final double particleSpeed;

  const ParticleBackground({
    Key? key,
    this.particleCount = 50,
    this.particleColor = const Color(0xFFF4F4F4),
    this.particleSpeed = 1.5,
  }) : super(key: key);

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late List<Particle> particles;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initializeParticles();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  void _initializeParticles() {
    final random = math.Random();
    particles = List.generate(
      widget.particleCount,
      (index) => Particle(
        radius: random.nextDouble() * 2 + 1,
        speed: widget.particleSpeed,
      )..x = random.nextDouble() * 500
      ..y = random.nextDouble() * 500,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        for (final particle in particles) {
          particle.update(500, 500);
        }
        return CustomPaint(
          painter: ParticleBackgroundPainter(
            particles: particles,
            particleColor: widget.particleColor,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}
