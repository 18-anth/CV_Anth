import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/firebase_service.dart';
import '../services/google_drive_upload_service.dart';

class EditCertificationController extends ChangeNotifier {
  bool isLoading = true;
  bool isUploading = false;
  double uploadProgress = 0.0;
  String uploadStatus = '';

  PlatformFile? pdfFile;
  PlatformFile? platformLogo;
  PlatformFile? institutionLogo;

  String? currentPdfUrl;
  String? currentPlatformLogoUrl;
  String? currentInstitutionLogoUrl;

  Map<String, dynamic>? certification;

  // ══════════════════════════════════════════════════════════════
  // CARGA DE DATOS
  // ══════════════════════════════════════════════════════════════

  Future<void> loadCertification(String certificationId) async {
    final data = await FirebaseService.fetchCertificationById(certificationId);
    if (data == null) {
      isLoading = false;
      notifyListeners();
      return;
    }
    certification = data;
    currentPdfUrl = data['pdfUrl'];
    currentPlatformLogoUrl = data['platformLogoUrl'];
    currentInstitutionLogoUrl = data['institutionLogoUrl'];
    isLoading = false;
    notifyListeners();
  }

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
    currentPlatformLogoUrl = null;
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
    currentInstitutionLogoUrl = null;
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════
  // ACTUALIZACIÓN
  // ══════════════════════════════════════════════════════════════

  Future<void> updateCertification({
    required String certificationId,
    required String name,
    required String series,
    required String link,
    required Future<bool> Function() showAuthInstructions,
  }) async {
    isUploading = true;
    uploadProgress = 0.0;
    uploadStatus = 'Preparando actualización...';
    notifyListeners();

    String pdfUrl = currentPdfUrl ?? '';
    String? platformLogoUrl = currentPlatformLogoUrl;
    String? institutionLogoUrl = currentInstitutionLogoUrl;

    if (pdfFile != null || platformLogo != null || institutionLogo != null) {
      // 1. Mostrar instrucciones antes de autenticar
      final shouldContinue = await showAuthInstructions();
      if (!shouldContinue) {
        isUploading = false;
        notifyListeners();
        return;
      }

      // 2. Pre-autenticar con Google Drive
      uploadStatus = 'Autenticando con Google Drive...';
      notifyListeners();
      final authenticated = await GoogleDriveUploadService.preAuthenticate();
      if (!authenticated) {
        throw Exception('AUTENTICACION_CANCELADA');
      }

      // 3. Subir nuevo PDF si se seleccionó uno
      if (pdfFile != null) {
        uploadProgress = 0.2;
        uploadStatus = 'Subiendo nuevo PDF a Google Drive...';
        notifyListeners();

        pdfUrl = await GoogleDriveUploadService.uploadImage(
          projectId: certificationId,
          type: 'pdf',
          file: pdfFile!,
          subFolder: 'pdf',
        );

        uploadProgress = 0.4;
        uploadStatus = 'PDF actualizado correctamente';
        notifyListeners();
      }

      // 4. Subir nuevo logo de plataforma si se seleccionó
      if (platformLogo != null) {
        uploadProgress = 0.5;
        uploadStatus = 'Subiendo logo de plataforma...';
        notifyListeners();

        platformLogoUrl = await GoogleDriveUploadService.uploadImage(
          projectId: certificationId,
          type: 'platform_logo',
          file: platformLogo!,
          subFolder: 'logos',
        );

        uploadProgress = 0.7;
        notifyListeners();
      }

      // 5. Subir nuevo logo de institución si se seleccionó
      if (institutionLogo != null) {
        uploadProgress = 0.75;
        uploadStatus = 'Subiendo logo de institución...';
        notifyListeners();

        institutionLogoUrl = await GoogleDriveUploadService.uploadImage(
          projectId: certificationId,
          type: 'institution_logo',
          file: institutionLogo!,
          subFolder: 'logos',
        );

        uploadProgress = 0.9;
        notifyListeners();
      }
    }

    // 6. Actualizar en Firebase
    uploadProgress = 0.95;
    uploadStatus = 'Actualizando certificación en base de datos...';
    notifyListeners();

    await FirebaseService.saveCertification(
      id: certificationId,
      name: name,
      pdfUrl: pdfUrl,
      series: series.isNotEmpty ? series : null,
      link: link.isNotEmpty ? link : null,
      platformLogoUrl: platformLogoUrl,
      institutionLogoUrl: institutionLogoUrl,
    );

    uploadProgress = 1.0;
    uploadStatus = '¡Certificación actualizada exitosamente!';
    notifyListeners();
  }

  void resetUpload() {
    isUploading = false;
    uploadProgress = 0.0;
    notifyListeners();
  }
}
