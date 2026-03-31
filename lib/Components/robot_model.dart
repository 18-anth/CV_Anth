import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class RobotModel extends StatefulWidget {
  const RobotModel({Key? key}) : super(key: key);

  @override
  State<RobotModel> createState() => _RobotModelState();
}

class _RobotModelState extends State<RobotModel> {
  late Future<String> _modelUrlFuture;

  @override
  void initState() {
    super.initState();
    _modelUrlFuture = _getModelUrl();
  }

  Future<String> _getModelUrl() async {
    try {
      const modelPath = 'Robot.glb';
      final storageRef = FirebaseStorage.instance.ref(modelPath);
      final downloadURL = await storageRef.getDownloadURL();
      return downloadURL;
    } catch (error) {
      debugPrint('Error al obtener la URL del modelo: $error');
      rethrow;
    }
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

        return ModelViewer(
          src: snapshot.data!,
          alt: 'A 3D model of a robot',
          ar: false,
          autoRotate: true,
          cameraControls: true,
          disableZoom: false,
        );
      },
    );
  }
}
