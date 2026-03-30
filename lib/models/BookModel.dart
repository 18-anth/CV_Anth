import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class BookModel extends StatefulWidget {
  const BookModel({Key? key}) : super(key: key);

  @override
  State<BookModel> createState() => _BookModelState();
}

class _BookModelState extends State<BookModel> {
  late Future<String> _modelUrlFuture;
  bool _isMounted = true;

  @override
  void initState() {
    super.initState();
    _modelUrlFuture = _getModelUrl();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<String> _getModelUrl() async {
    try {
      final firebaseStorage = FirebaseStorage.instance;
      final ref = firebaseStorage.ref('ModelBlender/Libro.glb');
      final url = await ref
          .getDownloadURL()
          .timeout(const Duration(seconds: 30));
      return url;
    } catch (error) {
      debugPrint('Error al obtener URL del modelo Libro: $error');
      if (_isMounted) {
        return 'error';
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isMounted) return const SizedBox.shrink();

    return FutureBuilder<String>(
      future: _modelUrlFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cargando modelo 3D...'),
              ],
            ),
          );
        }

        if (snapshot.hasError || (snapshot.hasData && snapshot.data == 'error')) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No se pudo cargar el modelo 3D',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Error: ${snapshot.error ?? "Conexión perdida"}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No se encontró el modelo'));
        }

        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          width: MediaQuery.of(context).size.width,
          child: ModelViewer(
            src: snapshot.data!,
            alt: 'Libro',
            ar: false,
            autoRotate: true,
            cameraControls: true,
            disablePan: true,
            disableZoom: false,
          ),
        );
      },
    );
  }
}