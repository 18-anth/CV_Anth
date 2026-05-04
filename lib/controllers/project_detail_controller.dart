import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class ProjectDetailController extends ChangeNotifier {
  // ══════════════════════════════════════════════════════════════
  // ESTADO
  // ══════════════════════════════════════════════════════════════

  Map<String, dynamic>? project;
  bool isLoading = true;
  String? errorMessage;
  String? selectedView;
  Map<String, List<String>> technologiesMap = {};

  // ══════════════════════════════════════════════════════════════
  // CONSTANTES
  // ══════════════════════════════════════════════════════════════

  static const Map<String, IconData> categoryIcons = {
    'Lenguajes de Programación': Icons.code,
    'Frontend': Icons.web,
    'Backend': Icons.storage,
    'Bases de Datos': Icons.storage_rounded,
    'Cloud & DevOps': Icons.cloud,
    'Metodologías': Icons.track_changes,
    'Arquitectura': Icons.account_tree,
    'Control de Versiones': Icons.source,
    'Testing': Icons.bug_report,
    'Inteligencia Artificial': Icons.psychology,
    'Otros': Icons.extension,
  };

  // ══════════════════════════════════════════════════════════════
  // CARGA DE DATOS
  // ══════════════════════════════════════════════════════════════

  Future<void> loadTechnologies() async {
    try {
      final technologies = await FirebaseService.fetchTechnologies();
      technologiesMap = technologies;
      notifyListeners();
    } catch (e) {
      technologiesMap = {};
      notifyListeners();
    }
  }

  Future<void> loadProject(String projectId) async {
    try {
      final data = await FirebaseService.fetchProjectById(projectId);
      project = data;
      errorMessage = data == null ? 'Proyecto no encontrado' : null;
      isLoading = false;
      notifyListeners();
    } catch (error) {
      errorMessage = 'Error al cargar: $error';
      isLoading = false;
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════════
  // ACCIONES DE UI
  // ══════════════════════════════════════════════════════════════

  void setSelectedView(String? view) {
    selectedView = view;
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════
  // UTILIDADES
  // ══════════════════════════════════════════════════════════════

  /// Convierte URLs de Google Drive al formato correcto que evita problemas de CORS
  /// Usa lh3.googleusercontent.com que permite acceso directo sin CORS
  String fixGoogleDriveUrl(String url) {
    if (url.isEmpty) return url;

    // Si ya es el formato correcto (lh3.googleusercontent.com), devolverla sin cambios
    if (url.contains('lh3.googleusercontent.com/d/')) {
      return url;
    }

    // Extraer el ID del archivo de diferentes formatos de URLs de Google Drive
    // Soporta:
    // - https://drive.usercontent.google.com/download?id=FILE_ID
    // - https://drive.google.com/uc?export=view&id=FILE_ID
    // - https://drive.google.com/file/d/FILE_ID/view
    // - https://www.googleapis.com/drive/v3/files/FILE_ID
    RegExp regExp = RegExp(r'(?:id=|/d/|/files/)([a-zA-Z0-9_-]+)');
    Match? match = regExp.firstMatch(url);

    if (match != null && match.groupCount > 0) {
      String fileId = match.group(1)!;
      // Convertir al formato que funciona sin CORS
      // lh3.googleusercontent.com sirve contenido directamente sin redirecciones
      return 'https://lh3.googleusercontent.com/d/$fileId';
    }

    // Si no es una URL de Google Drive, devolverla sin cambios
    return url;
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      const months = [
        'Enero',
        'Febrero',
        'Marzo',
        'Abril',
        'Mayo',
        'Junio',
        'Julio',
        'Agosto',
        'Septiembre',
        'Octubre',
        'Noviembre',
        'Diciembre',
      ];
      return '${date.day} de ${months[date.month - 1]} de ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Map<String, List<String>> categorizeTechnologies(
    List<dynamic> technologies,
  ) {
    final categorized = <String, List<String>>{};
    final techSet = technologies.map((e) => e.toString()).toSet();

    technologiesMap.forEach((category, categoryTechs) {
      final matchingTechs = categoryTechs
          .where((tech) => techSet.contains(tech))
          .toList();
      if (matchingTechs.isNotEmpty) {
        categorized[category] = matchingTechs;
      }
    });

    return categorized;
  }
}
