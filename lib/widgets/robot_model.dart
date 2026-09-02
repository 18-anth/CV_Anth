import 'package:flutter/material.dart';

/// Placeholder para el modelo 3D del robot
///
/// t ODO: Reemplaza esto con tu modelo 3D usando:
/// - model_viewer_plus: para modelos GLTF/GLB
/// - three_d: para renderizado 3D custom
class RobotModel extends StatefulWidget {
  const RobotModel({super.key});

  @override
  State<RobotModel> createState() => _RobotModelState();
}

class _RobotModelState extends State<RobotModel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
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
        return Transform.rotate(
          angle: _animationController.value * 2 * 3.14159,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.deepPurple.shade300,
                  Colors.purple.shade600,
                  Colors.indigo.shade900,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withValues(alpha: 0.5),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.android, size: 80, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
