import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class RobotModel extends StatefulWidget {
  const RobotModel({Key? key}) : super(key: key);

  @override
  State<RobotModel> createState() => _RobotModelState();
}

class _RobotModelState extends State<RobotModel> {
  late Future<String> _modelUrlFuture;
  final Flutter3DController _controller = Flutter3DController();

  @override
  void initState() {
    super.initState();
    _modelUrlFuture = _getModelUrl();
  }

  Future<String> _getModelUrl() async {
    return 'https://drive.google.com/uc?export=download&id=1g1VT5_dnJDf4C4LsHW2EFpYsLmXEEyz1';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _modelUrlFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: Text('No se encontró el modelo'),
          );
        }

        return kIsWeb
            ? ModelViewer(
                src: snapshot.data!,
                alt: 'A 3D model of a robot',
                autoRotate: true,
                cameraControls: true,
              )
            : Flutter3DViewer(
                src: snapshot.data!,
                controller: _controller,
                progressBarColor: Colors.deepPurple,
              );
      },
    );
  }
}
