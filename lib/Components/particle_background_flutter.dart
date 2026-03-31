import 'package:flutter/material.dart';
import 'dart:math';

class Particle {
  late Offset position;
  late Offset velocity;
  late double size;
  late double opacity;
  double angle = 0;

  Particle({required Offset initialPosition, required Size canvasSize}) {
    position = initialPosition;
    velocity = Offset(
      (Random().nextDouble() - 0.5) * 3,
      (Random().nextDouble() - 0.5) * 3,
    );
    size = Random().nextDouble() * 3 + 1; // Entre 1 y 4
    opacity = 0.5;
  }

  void update(Size canvasSize) {
    position += velocity;

    // Rebote en los bordes
    if (position.dx < 0 || position.dx > canvasSize.width) {
      velocity = Offset(-velocity.dx, velocity.dy);
    }
    if (position.dy < 0 || position.dy > canvasSize.height) {
      velocity = Offset(velocity.dx, -velocity.dy);
    }

    // Mantener dentro de los bordes
    position = Offset(
      position.dx.clamp(0, canvasSize.width),
      position.dy.clamp(0, canvasSize.height),
    );
  }

  void repulseFrom(Offset point, double distance) {
    final dx = position.dx - point.dx;
    final dy = position.dy - point.dy;
    final dist = sqrt(dx * dx + dy * dy);

    if (dist < distance && dist > 0) {
      final angle = atan2(dy, dx);
      velocity = Offset(cos(angle) * 2, sin(angle) * 2);
    }
  }
}

class ParticleBackgroundPainter extends CustomPainter {
  final List<Particle> particles;
  final Offset? hoverPoint;

  ParticleBackgroundPainter({required this.particles, this.hoverPoint});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..isAntiAlias = true;

    for (final particle in particles) {
      paint.color = Color.fromARGB(
        (particle.opacity * 255).toInt(),
        255,
        255,
        255,
      );
      canvas.drawCircle(particle.position, particle.size, paint);
    }

    // Dibujar líneas conectando partículas cercanas
    final linePaint = Paint()
      ..color = Color.fromARGB((50).toInt(), 255, 255, 255)
      ..strokeWidth = 0.5;

    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final dx = particles[i].position.dx - particles[j].position.dx;
        final dy = particles[i].position.dy - particles[j].position.dy;
        final distance = sqrt(dx * dx + dy * dy);

        if (distance < 150) {
          canvas.drawLine(
            particles[i].position,
            particles[j].position,
            linePaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant ParticleBackgroundPainter oldDelegate) {
    return true;
  }
}

class ParticleBackground extends StatefulWidget {
  final int particleCount;

  const ParticleBackground({super.key, this.particleCount = 60});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late List<Particle> particles;
  late AnimationController _animationController;
  Offset? _hoverPoint;

  @override
  void initState() {
    super.initState();
    particles = [];
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _animationController.addListener(() {
      setState(() {
        _updateParticles();
        if (_hoverPoint != null) {
          for (final particle in particles) {
            particle.repulseFrom(_hoverPoint!, 100);
          }
        }
      });
    });
  }

  void _initializeParticles(Size size) {
    if (particles.isEmpty) {
      // Inicializar solo una vez
      particles = List.generate(
        widget.particleCount,
        (_) => Particle(
          initialPosition: Offset(
            Random().nextDouble() * size.width,
            Random().nextDouble() * size.height,
          ),
          canvasSize: size,
        ),
      );
    }
  }

  void _updateParticles() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;
      for (final particle in particles) {
        particle.update(size);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _initializeParticles(Size(constraints.maxWidth, constraints.maxHeight));
        return MouseRegion(
          child: CustomPaint(
            painter: ParticleBackgroundPainter(
              particles: particles,
              hoverPoint: _hoverPoint,
            ),
            size: Size(constraints.maxWidth, constraints.maxHeight),
          ),
        );
      },
    );
  }
}
