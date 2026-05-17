import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;

/// 🔥 Servicio para subir archivos a Firebase Storage
/// Soporta imágenes tanto para Web como Mobile
class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Sube una imagen a Firebase Storage y retorna la URL de descarga
  ///
  /// [bytes] - Bytes de la imagen (para Web)
  /// [file] - Archivo de la imagen (para Mobile)
  /// [folder] - Carpeta donde se guardará (ej: 'Project/Web', 'Project/Mobile')
  /// [fileName] - Nombre del archivo
  static Future<String> uploadImage({
    Uint8List? bytes,
    File? file,
    required String folder,
    required String fileName,
  }) async {
    try {
      // Validar que haya datos
      if (bytes == null && file == null) {
        throw Exception('Debe proporcionar bytes o file');
      }

      // Crear referencia en Storage
      final ref = _storage.ref().child('$folder/$fileName');

      // Subir según la plataforma
      UploadTask uploadTask;
      if (kIsWeb && bytes != null) {
        uploadTask = ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else if (file != null) {
        uploadTask = ref.putFile(file);
      } else {
        throw Exception('No se puede subir el archivo');
      }

      // Esperar a que termine la subida
      final snapshot = await uploadTask;

      // Obtener la URL de descarga
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }

  /// Sube múltiples imágenes a Firebase Storage
  ///
  /// [images] - Lista de imágenes (PlatformFile de file_picker)
  /// [folder] - Carpeta donde se guardarán
  /// [onProgress] - Callback para reportar progreso (opcional)
  static Future<List<String>> uploadMultipleImages({
    required List<PlatformFile> images,
    required String folder,
    Function(int current, int total)? onProgress,
  }) async {
    final List<String> urls = [];

    for (int i = 0; i < images.length; i++) {
      final image = images[i];

      // Generar nombre único
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${timestamp}_${image.name}';

      // Subir según la plataforma
      String url;
      if (kIsWeb && image.bytes != null) {
        url = await uploadImage(
          bytes: image.bytes!,
          folder: folder,
          fileName: fileName,
        );
      } else if (image.path != null) {
        url = await uploadImage(
          file: File(image.path!),
          folder: folder,
          fileName: fileName,
        );
      } else {
        throw Exception('No se puede leer el archivo ${image.name}');
      }

      urls.add(url);

      // Reportar progreso
      if (onProgress != null) {
        onProgress(i + 1, images.length);
      }
    }

    return urls;
  }

  /// Sube múltiples imágenes desde ImagePicker (Mobile)
  static Future<List<String>> uploadImagesFromPicker({
    required List<XFile> images,
    required String folder,
    Function(int current, int total)? onProgress,
  }) async {
    final List<String> urls = [];

    for (int i = 0; i < images.length; i++) {
      final image = images[i];

      // Generar nombre único
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${timestamp}_${image.name}';

      // Leer bytes
      final bytes = await image.readAsBytes();

      // Subir
      final url = await uploadImage(
        bytes: bytes,
        folder: folder,
        fileName: fileName,
      );

      urls.add(url);

      // Reportar progreso
      if (onProgress != null) {
        onProgress(i + 1, images.length);
      }
    }

    return urls;
  }

  /// Elimina una imagen de Firebase Storage por su URL
  static Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Error al eliminar imagen: $e');
    }
  }

  /// Elimina múltiples imágenes de Firebase Storage
  static Future<void> deleteMultipleImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      try {
        await deleteImage(url);
      } catch (e) {
        // Continuar aunque falle una imagen
        print('⚠️ Error al eliminar imagen $url: $e');
      }
    }
  }
}
