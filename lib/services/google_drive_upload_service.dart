import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show File;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'app_config.dart';

/// 📤 Servicio para subir imágenes directamente a Google Drive
/// usando Google Sign-In y Google Drive API
class GoogleDriveUploadService {
  // Singleton instances
  static GoogleSignIn? _googleSignIn;
  static drive.DriveApi? _driveApi;
  static bool _isInitialized = false;

  /// Inicializa Google Sign-In con los scopes necesarios (solo una vez)
  static GoogleSignIn _getGoogleSignIn() {
    if (_googleSignIn == null) {
      if (_isInitialized) {
        throw Exception('GoogleSignIn ya fue inicializado pero la instancia es nula');
      }
      
      _googleSignIn = GoogleSignIn(
        clientId: AppConfig.googleClientId,
        scopes: [
          drive.DriveApi.driveFileScope, // Permiso para crear/modificar archivos
        ],
      );
      _isInitialized = true;
      
      if (kIsWeb) {
        print('✅ GoogleSignIn inicializado para web');
      }
    }
    return _googleSignIn!;
  }

  /// Autentica al usuario con Google (solo la primera vez)
  static Future<void> _ensureAuthenticated() async {
    try {
      final googleSignIn = _getGoogleSignIn();

      // Verificar si ya está autenticado
      GoogleSignInAccount? account = googleSignIn.currentUser;

      // Intentar autenticación silenciosa
      if (account == null) {
        account = await googleSignIn.signInSilently();
      }

      // Si no hay cuenta, solicitar autenticación interactiva
      if (account == null) {
        account = await googleSignIn.signIn();
      }

      if (account == null) {
        throw Exception('AUTENTICACION_CANCELADA');
      }

      // Obtener cliente HTTP autenticado
      final httpClient = await googleSignIn.authenticatedClient();
      if (httpClient == null) {
        throw Exception('No se pudo obtener cliente autenticado');
      }

      // Crear API de Drive
      _driveApi = drive.DriveApi(httpClient);
    } catch (e) {
      if (e.toString().contains('popup_closed')) {
        throw Exception('POPUP_CERRADO');
      } else if (e.toString().contains('AUTENTICACION_CANCELADA')) {
        rethrow;
      } else {
        throw Exception('Error de autenticación: $e');
      }
    }
  }

  /// Busca o crea una carpeta en Google Drive
  static Future<String> _findOrCreateFolder(
    String folderName,
    String parentId,
  ) async {
    await _ensureAuthenticated();

    try {
      // Buscar carpeta existente
      final query =
          "name='$folderName' and '$parentId' in parents and mimeType='application/vnd.google-apps.folder' and trashed=false";

      final fileList = await _driveApi!.files.list(
        q: query,
        spaces: 'drive',
        $fields: 'files(id, name)',
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        return fileList.files!.first.id!;
      }

      // Crear carpeta si no existe
      final folder = drive.File()
        ..name = folderName
        ..mimeType = 'application/vnd.google-apps.folder'
        ..parents = [parentId];

      final createdFolder = await _driveApi!.files.create(folder);

      // Hacer la carpeta pública
      final permission = drive.Permission()
        ..role = 'reader'
        ..type = 'anyone';

      await _driveApi!.permissions.create(permission, createdFolder.id!);

      return createdFolder.id!;
    } catch (e) {
      throw Exception('Error al crear carpeta en Drive: $e');
    }
  }

  /// Pre-autentica al usuario antes de subir archivos
  /// Útil para mostrar el popup de Google antes de comenzar el proceso
  static Future<bool> preAuthenticate() async {
    try {
      await _ensureAuthenticated();
      return true;
    } catch (e) {
      print('❌ Error en preAuthenticate: $e');
      return false;
    }
  }

  /// Verifica si el usuario ya está autenticado
  static bool isAuthenticated() {
    if (!_isInitialized || _googleSignIn == null) {
      return false;
    }
    return _googleSignIn!.currentUser != null;
  }

  /// Cierra la sesión de Google
  static Future<void> signOut() async {
    try {
      if (_googleSignIn != null) {
        await _googleSignIn!.signOut();
        _driveApi = null;
        print('✅ Sesión de Google cerrada');
      }
    } catch (e) {
      print('⚠️ Error al cerrar sesión de Google: $e');
    }
  }

  /// Limpia todas las instancias (útil para reiniciar el servicio)
  static Future<void> dispose() async {
    await signOut();
    _googleSignIn = null;
    _driveApi = null;
    _isInitialized = false;
    print('✅ Servicio de Google Drive limpiado');
  }

  /// Sube un archivo a Google Drive
  static Future<String> uploadImage({
    required String projectId,
    required String type,
    required PlatformFile file,
  }) async {
    try {
      await _ensureAuthenticated();

      // Obtener bytes del archivo
      Uint8List bytes;
      if (kIsWeb && file.bytes != null) {
        bytes = file.bytes!;
      } else if (file.path != null) {
        final ioFile = File(file.path!);
        bytes = await ioFile.readAsBytes();
      } else {
        throw Exception('No se puede leer el archivo ${file.name}');
      }

      // Obtener carpeta raíz según el tipo
      final rootFolderId = _getRootFolderIdByType(type);

      // Crear carpeta del proyecto dentro de la carpeta específica
      final projectFolderId = await _findOrCreateFolder(
        projectId,
        rootFolderId,
      );

      // Preparar metadata del archivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${timestamp}_${file.name}';

      final driveFile = drive.File()
        ..name = fileName
        ..parents = [projectFolderId];

      // Subir archivo
      final media = drive.Media(
        Stream.value(bytes.toList()),
        bytes.length,
        contentType: _getMimeType(file.name),
      );

      final uploadedFile = await _driveApi!.files.create(
        driveFile,
        uploadMedia: media,
        $fields: 'id, webViewLink, webContentLink',
      );

      // Hacer el archivo público
      final permission = drive.Permission()
        ..role = 'reader'
        ..type = 'anyone';

      await _driveApi!.permissions.create(permission, uploadedFile.id!);

      // Retornar URL de descarga directa
      return 'https://drive.google.com/uc?export=download&id=${uploadedFile.id}';
    } catch (e) {
      throw Exception('Error al subir imagen a Google Drive: $e');
    }
  }

  /// Sube múltiples imágenes a Google Drive
  static Future<List<String>> uploadMultipleImages({
    required String projectId,
    required String type,
    required List<PlatformFile> files,
    Function(int current, int total)? onProgress,
  }) async {
    final List<String> urls = [];

    for (int i = 0; i < files.length; i++) {
      final file = files[i];

      try {
        final url = await uploadImage(
          projectId: projectId,
          type: type,
          file: file,
        );

        urls.add(url);

        // Reportar progreso
        if (onProgress != null) {
          onProgress(i + 1, files.length);
        }

        // Pequeña pausa para evitar rate limiting
        if (i < files.length - 1) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      } catch (e) {
        print('⚠️ Error al subir ${file.name}: $e');
        rethrow; // Propagar el error para que se maneje en la UI
      }
    }

    if (urls.isEmpty && files.isNotEmpty) {
      throw Exception('No se pudo subir ninguna imagen');
    }

    return urls;
  }

  /// Obtiene el ID de la carpeta raíz según el tipo
  static String _getRootFolderIdByType(String type) {
    switch (type.toLowerCase()) {
      case 'logo':
        return AppConfig.googleDriveProjectsLogoFolderId;
      case 'mobile':
        return AppConfig.googleDriveProjectsMobileFolderId;
      case 'web':
        return AppConfig.googleDriveProjectsWebFolderId;
      default:
        throw Exception('Tipo de carpeta no válido: $type');
    }
  }

  /// Determina el MIME type basado en la extensión
  static String _getMimeType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'svg':
        return 'image/svg+xml';
      default:
        return 'image/jpeg';
    }
  }
}
