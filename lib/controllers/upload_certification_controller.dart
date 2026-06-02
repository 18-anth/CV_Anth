import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/firebase_service.dart';
import '../services/google_drive_upload_service.dart';

class UploadCertificationController extends ChangeNotifier {
  bool isUploading = false;
  double uploadProgress = 0.0;
  String uploadStatus = '';

  PlatformFile? pdfFile;
  PlatformFile? platformLogo;
  PlatformFile? institutionLogo;

  // ══════════════════════════════════════════════════════════════
  // SELECCIÓN DE ARCHIVOS
  // ══════════════════════════════════════════════════════════════

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      pdfFile = result.files.first;
      notifyListeners();
    }
  }

  void removePdf() {
    pdfFile = null;
    notifyListeners();
  }

  Future<void> pickPlatformLogo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      platformLogo = result.files.first;
      notifyListeners();
    }
  }

  void removePlatformLogo() {
    platformLogo = null;
    notifyListeners();
  }

  Future<void> pickInstitutionLogo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      institutionLogo = result.files.first;
      notifyListeners();
    }
  }

  void removeInstitutionLogo() {
    institutionLogo = null;
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════
  // GUARDAR CERTIFICACIÓN
  // ══════════════════════════════════════════════════════════════

  Future<void> saveCertification({
    required String name,
    required String series,
    required String link,
    required String classification,
    required Future<bool> Function() showAuthInstructions,
  }) async {
    isUploading = true;
    uploadProgress = 0.0;
    uploadStatus = 'Conectando con Google Drive...';
    notifyListeners();

    // 0. Mostrar instrucciones antes de autenticar
    final shouldContinue = await showAuthInstructions();
    if (!shouldContinue) {
      isUploading = false;
      notifyListeners();
      return;
    }

    // 1. Pre-autenticar con Google Drive
    uploadStatus = 'Autenticando con Google Drive...';
    notifyListeners();
    final authenticated = await GoogleDriveUploadService.preAuthenticate();
    if (!authenticated) {
      throw Exception('AUTENTICACION_CANCELADA');
    }

    // 2. Generar ID de la certificación
    final certificationId = FirebaseService.generateUUID();

    // 3. Subir PDF a Google Drive (subcarpeta 'pdf')
    uploadProgress = 0.2;
    uploadStatus = 'Subiendo PDF a Google Drive...';
    notifyListeners();

    final pdfUrl = await GoogleDriveUploadService.uploadImage(
      projectId: certificationId,
      type: 'certification',
      file: pdfFile!,
      subFolder: 'pdf',
    );

    uploadProgress = 0.4;
    uploadStatus = 'PDF subido correctamente';
    notifyListeners();

    // 4. Subir logo de plataforma (subcarpeta 'logos')
    String? platformLogoUrl;
    if (platformLogo != null) {
      uploadProgress = 0.5;
      uploadStatus = 'Subiendo logo de plataforma...';
      notifyListeners();

      platformLogoUrl = await GoogleDriveUploadService.uploadImage(
        projectId: certificationId,
        type: 'certification',
        file: platformLogo!,
        subFolder: 'logos',
      );
    }

    // 5. Subir logo de institución (subcarpeta 'logos')
    String? institutionLogoUrl;
    if (institutionLogo != null) {
      uploadProgress = 0.6;
      uploadStatus = 'Subiendo logo de institución...';
      notifyListeners();

      institutionLogoUrl = await GoogleDriveUploadService.uploadImage(
        projectId: certificationId,
        type: 'certification',
        file: institutionLogo!,
        subFolder: 'logos',
      );
    }

    // 6. Guardar en Firebase Realtime Database
    uploadProgress = 0.8;
    uploadStatus = 'Guardando certificación en base de datos...';
    notifyListeners();

    await FirebaseService.saveCertification(
      id: certificationId,
      name: name,
      pdfUrl: pdfUrl,
      series: series.isNotEmpty ? series : null,
      link: link.isNotEmpty ? link : null,
      platformLogoUrl: platformLogoUrl,
      institutionLogoUrl: institutionLogoUrl,
      classification: classification.isNotEmpty ? classification : null,
    );

    uploadProgress = 1.0;
    uploadStatus = '¡Certificación guardada exitosamente!';
    notifyListeners();
  }

  void resetUpload() {
    isUploading = false;
    uploadProgress = 0.0;
    notifyListeners();
  }
}
