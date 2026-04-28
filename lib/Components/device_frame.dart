import 'package:flutter/material.dart';

enum DeviceType { iphone, android, tablet }

class DeviceFrame extends StatelessWidget {
  final Widget child;
  final DeviceType deviceType;

  const DeviceFrame({super.key, required this.child, required this.deviceType});

  @override
  Widget build(BuildContext context) {
    switch (deviceType) {
      case DeviceType.iphone:
        return _IphoneFrame(child: child);
      case DeviceType.android:
        return _AndroidFrame(child: child);
      case DeviceType.tablet:
        return _TabletFrame(child: child);
    }
  }
}

// ─────────────── iPhone Frame ───────────────

class _IphoneFrame extends StatelessWidget {
  final Widget child;
  const _IphoneFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    const borderRadius = 44.0;
    const bezel = 14.0;
    const notchWidth = 160.0;
    const notchHeight = 28.0;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.08),
            blurRadius: 1,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(color: const Color(0xFF3A3A3A), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(bezel),
        child: Column(
          children: [
            // Screen con notch superpuesto
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius - bezel - 2),
                child: Stack(
                  children: [
                    // Contenido
                    Positioned.fill(child: child),
                    // Notch overlay encima de la pantalla
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: CustomPaint(
                        size: const Size(double.infinity, notchHeight + 4),
                        painter: _NotchPainter(
                          notchWidth: notchWidth,
                          notchHeight: notchHeight,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Home indicator
            Container(
              width: 120,
              height: 5,
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotchPainter extends CustomPainter {
  final double notchWidth;
  final double notchHeight;
  final Color color;

  const _NotchPainter({
    required this.notchWidth,
    required this.notchHeight,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final cx = size.width / 2;
    const r = 16.0;

    // Notch: rectángulo centrado desde el tope, solo esquinas inferiores redondeadas
    final notchRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(cx - notchWidth / 2, 0, notchWidth, notchHeight),
      bottomLeft: const Radius.circular(r),
      bottomRight: const Radius.circular(r),
    );
    canvas.drawRRect(notchRect, paint);

    // Cámara frontal dentro del notch
    final camCenter = Offset(cx + 28, notchHeight / 2 - 1);
    canvas.drawCircle(camCenter, 5.0, Paint()..color = const Color(0xFF2A2A2A));
    canvas.drawCircle(camCenter, 3.5, Paint()..color = const Color(0xFF1A3A4A));
    canvas.drawCircle(
      camCenter + const Offset(-1.2, -1.2),
      1.0,
      Paint()..color = Colors.white.withOpacity(0.3),
    );
  }

  @override
  bool shouldRepaint(_NotchPainter oldDelegate) => false;
}

// ─────────────── Android Frame ───────────────

class _AndroidFrame extends StatelessWidget {
  final Widget child;
  const _AndroidFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    const borderRadius = 36.0;
    const bezel = 12.0;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF202020),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 4,
          ),
        ],
        border: Border.all(color: const Color(0xFF3A3A3A), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(bezel),
        child: Column(
          children: [
            // Cámara frontal
            Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF555555), width: 1),
              ),
            ),
            // Screen
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius - bezel - 2),
                child: child,
              ),
            ),
            // Navigation bar
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navIcon(Icons.arrow_back),
                  _navIcon(Icons.circle_outlined, size: 18),
                  _navIcon(Icons.square_outlined, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, {double size = 20}) {
    return Icon(icon, color: Colors.white.withOpacity(0.4), size: size);
  }
}

// ─────────────── Tablet Frame ───────────────

class _TabletFrame extends StatelessWidget {
  final Widget child;
  const _TabletFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    const borderRadius = 24.0;
    const bezel = 14.0;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 4,
          ),
        ],
        border: Border.all(color: const Color(0xFF3A3A3A), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(bezel),
        child: Column(
          children: [
            // Cámara frontal
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                shape: BoxShape.circle,
              ),
            ),
            // Screen
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius - bezel - 2),
                child: child,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
