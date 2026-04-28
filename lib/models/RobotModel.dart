import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

const String _modelDriveUrl =
    'https://drive.google.com/uc?export=download&id=1Ty8SVK_jeV7yvRibQyH_UJ9L5hkoTLE0';

class RobotModel extends StatefulWidget {
  const RobotModel({super.key});

  @override
  State<RobotModel> createState() => _RobotModelState();
}

class _RobotModelState extends State<RobotModel> {
  final Flutter3DController _controller = Flutter3DController();

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 [RobotModel] initState — plataforma web: $kIsWeb');
    if (!kIsWeb) {
      _controller.onModelLoaded.addListener(() {
        debugPrint(
          '🔔 [RobotModel] onModelLoaded: ${_controller.onModelLoaded.value}',
        );
        if (mounted && _controller.onModelLoaded.value) {
          _controller.playAnimation();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.onModelLoaded.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      width: double.infinity,
      child: kIsWeb
          ? ModelViewer(
              src: _modelDriveUrl,
              alt: 'Robot 3D',
              autoRotate: true,
              cameraControls: true,
              backgroundColor: const Color.fromARGB(0, 0, 0, 0),
            )
          : Flutter3DViewer(
              src: _modelDriveUrl,
              controller: _controller,
              activeGestureInterceptor: true,
              progressBarColor: Colors.deepPurple,
              enableTouch: true,
              onProgress: (double progressValue) {
                debugPrint(
                  '📦 [RobotModel] Progreso: ${(progressValue * 100).toStringAsFixed(0)}%',
                );
              },
              onLoad: (String modelAddress) {
                debugPrint('✅ [RobotModel] .glb cargado: $modelAddress');
              },
              onError: (String error) {
                debugPrint('❌ [RobotModel] Error: $error');
              },
            ),
    );
  }
}
