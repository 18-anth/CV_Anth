import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/firebase_service.dart';
import '../services/google_drive_upload_service.dart';

class UploadProjectController extends ChangeNotifier {
  // ══════════════════════════════════════════════════════════════
  // ESTADO
  // ══════════════════════════════════════════════════════════════

  bool isUploading = false;
  double uploadProgress = 0.0;
  String uploadStatus = '';

  bool isLoadingTechnologies = true;
  Map<String, List<String>> technologiesMap = {};

  final List<PlatformFile> webImages = [];
  final List<PlatformFile> mobileImages = [];
  PlatformFile? logo;

  List<String> selectedTechnologies = [];
  String? selectedClassification;
  DateTime? startDate;
  DateTime? endDate;

  final List<String> classifications = [
    'Prácticas profesionales',
    'Freelancer',
    'Proyecto universitario',
  ];

  // ══════════════════════════════════════════════════════════════
  // CARGA DE TECNOLOGÍAS
  // ══════════════════════════════════════════════════════════════

  Future<void> loadTechnologies() async {
    try {
      final technologies = await FirebaseService.fetchTechnologies();
      technologiesMap = technologies;
      isLoadingTechnologies = false;
      notifyListeners();
    } catch (e) {
      isLoadingTechnologies = false;
      notifyListeners();
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // SELECCIÓN DE IMÁGENES
  // ══════════════════════════════════════════════════════════════

  Future<void> pickWebImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result != null && result.files.isNotEmpty) {
      webImages.addAll(result.files);
      notifyListeners();
    }
  }

  void removeWebImage(int index) {
    webImages.removeAt(index);
    notifyListeners();
  }

  Future<void> pickMobileImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result != null && result.files.isNotEmpty) {
      mobileImages.addAll(result.files);
      notifyListeners();
    }
  }

  void removeMobileImage(int index) {
    mobileImages.removeAt(index);
    notifyListeners();
  }

  Future<void> pickLogo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      logo = result.files.first;
      notifyListeners();
    }
  }

  void removeLogo() {
    logo = null;
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════
  // TECNOLOGÍAS
  // ══════════════════════════════════════════════════════════════

  void setTechnologies(List<String> selected) {
    selectedTechnologies = selected;
    notifyListeners();
  }

  void removeTechnology(String tech) {
    selectedTechnologies.remove(tech);
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════
  // CLASIFICACIÓN Y FECHAS
  // ══════════════════════════════════════════════════════════════

  void setClassification(String? value) {
    selectedClassification = value;
    notifyListeners();
  }

  void setStartDate(DateTime? date) {
    startDate = date;
    notifyListeners();
  }

  void setEndDate(DateTime? date) {
    endDate = date;
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════
  // GUARDAR PROYECTO
  // ══════════════════════════════════════════════════════════════

  Future<void> saveProject({
    required String title,
    required String name,
    required String description,
    required String link,
    required String problemSolved,
    required String difficulties,
    required String testimonials,
    required String responsibilities,
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

    // 2. Generar ID del proyecto
    final projectId = FirebaseService.generateUUID();

    // 3. Subir imágenes web
    List<String> webImageUrls = [];
    if (webImages.isNotEmpty) {
      uploadStatus = 'Subiendo imágenes web a Google Drive...';
      notifyListeners();
      webImageUrls = await GoogleDriveUploadService.uploadMultipleImages(
        projectId: projectId,
        type: 'web',
        files: webImages,
        onProgress: (current, total) {
          uploadProgress = (current / total) * 0.4;
          uploadStatus = 'Subiendo imagen web $current de $total';
          notifyListeners();
        },
      );
    }

    // 4. Subir imágenes mobile
    List<String> mobileImageUrls = [];
    if (mobileImages.isNotEmpty) {
      uploadStatus = 'Subiendo imágenes mobile a Google Drive...';
      notifyListeners();
      mobileImageUrls = await GoogleDriveUploadService.uploadMultipleImages(
        projectId: projectId,
        type: 'mobile',
        files: mobileImages,
        onProgress: (current, total) {
          uploadProgress = 0.4 + (current / total) * 0.3;
          uploadStatus = 'Subiendo imagen mobile $current de $total';
          notifyListeners();
        },
      );
    }

    // 5. Subir logo
    String? logoUrl;
    if (logo != null) {
      uploadStatus = 'Subiendo logo a Google Drive...';
      notifyListeners();
      final logoUrls = await GoogleDriveUploadService.uploadMultipleImages(
        projectId: projectId,
        type: 'logo',
        files: [logo!],
        onProgress: (current, total) {
          uploadProgress = 0.7;
          uploadStatus = 'Subiendo logo...';
          notifyListeners();
        },
      );
      logoUrl = logoUrls.isNotEmpty ? logoUrls.first : null;
    }

    // 6. Guardar en Firebase
    uploadProgress = 0.8;
    uploadStatus = 'Guardando proyecto en base de datos...';
    notifyListeners();

    await FirebaseService.saveProject(
      id: projectId,
      title: title,
      name: name,
      description: description,
      link: link,
      classification: selectedClassification,
      startDate: startDate?.toIso8601String(),
      endDate: endDate?.toIso8601String(),
      images: webImageUrls,
      imagesMobile: mobileImageUrls,
      logo: logoUrl,
      technologies: selectedTechnologies,
      problemSolved: problemSolved,
      difficulties: difficulties,
      testimonials: testimonials,
      responsibilities: responsibilities,
    );

    uploadProgress = 1.0;
    uploadStatus = '¡Proyecto guardado exitosamente!';
    notifyListeners();
  }

  void resetUpload() {
    isUploading = false;
    uploadProgress = 0.0;
    notifyListeners();
  }
}
