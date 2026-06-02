import 'package:firebase_database/firebase_database.dart';

/// Servicio para obtener datos de Firebase Realtime Database.
///
/// Nodos esperados en la Realtime Database:
///   - `Projects`       → objetos con campos: name, description, timestamp,
///                        githubUrl?, demoUrl?, technologies?, driveFileId?
///   - `Certifications` → objetos con campos: name, description,
///                        driveFileId (ID del PDF en Drive), imageUrl?
class FirebaseService {
  static final _db = FirebaseDatabase.instance;

  // ───────────── PROJECTS ─────────────

  /// Retorna la lista de proyectos desde el nodo `Projects`.
  static Future<List<Map<String, dynamic>>> fetchProjects() async {
    final snap = await _db.ref('Projects').get();
    if (!snap.exists || snap.value == null) return [];

    final raw = snap.value as Map<dynamic, dynamic>;
    final list = raw.entries.map((entry) {
      final data = Map<String, dynamic>.from(entry.value as Map);
      data['id'] = entry.key.toString();
      return data;
    }).toList();

    list.sort((a, b) {
      final ta = num.tryParse(a['timestamp']?.toString() ?? '0') ?? 0;
      final tb = num.tryParse(b['timestamp']?.toString() ?? '0') ?? 0;
      return tb.compareTo(ta);
    });

    return list;
  }

  /// Retorna un proyecto por su clave en Realtime Database.
  static Future<Map<String, dynamic>?> fetchProjectById(String id) async {
    final snap = await _db.ref('Projects/$id').get();
    if (!snap.exists || snap.value == null) return null;
    final data = Map<String, dynamic>.from(snap.value as Map);
    data['id'] = id;
    return data;
  }

  // ───────────── CERTIFICATIONS ─────────────

  /// Retorna la lista de certificaciones desde el nodo `Certifications`.
  static Future<List<Map<String, dynamic>>> fetchCertifications() async {
    final snap = await _db.ref('Certifications').get();
    if (!snap.exists || snap.value == null) return [];

    final raw = snap.value as Map<dynamic, dynamic>;
    final list = raw.entries.map((entry) {
      final data = Map<String, dynamic>.from(entry.value as Map);
      data['id'] = entry.key.toString();
      return data;
    }).toList();

    list.sort((a, b) {
      final na = (a['name'] ?? '').toString();
      final nb = (b['name'] ?? '').toString();
      return na.compareTo(nb);
    });

    return list;
  }

  /// Retorna una certificación por su clave en Realtime Database.
  static Future<Map<String, dynamic>?> fetchCertificationById(String id) async {
    final snap = await _db.ref('Certifications/$id').get();
    if (!snap.exists || snap.value == null) return null;
    final data = Map<String, dynamic>.from(snap.value as Map);
    data['id'] = id;
    return data;
  }

  /// Retorna las categorías de certificaciones desde el nodo `certificationCategories`.
  static Future<List<String>> fetchCertificationCategories() async {
    final snap = await _db.ref('certificationCategories').get();
    if (!snap.exists || snap.value == null) return [];
    final categories = <String>[];
    if (snap.value is List) {
      final list = snap.value as List<dynamic>;
      categories.addAll(list.whereType<String>());
    } else if (snap.value is Map) {
      final map = snap.value as Map<dynamic, dynamic>;
      categories.addAll(map.values.whereType<String>());
    }
    return categories;
  }

  // ───────────── WRITE OPERATIONS ─────────────

  /// Crea o actualiza una certificación en Firebase.
  /// Si [id] no se proporciona, genera uno automáticamente.
  static Future<String> saveCertification({
    required String name,
    required String pdfUrl,
    String? series,
    String? link,
    String? platformLogoUrl,
    String? institutionLogoUrl,
    String? classification,
    String? id,
  }) async {
    final certId = id ?? _generateId();
    final data = {
      'name': name,
      'pdfUrl': pdfUrl,
      if (series != null && series.isNotEmpty) 'series': series,
      if (link != null && link.isNotEmpty) 'link': link,
      if (platformLogoUrl != null && platformLogoUrl.isNotEmpty)
        'platformLogoUrl': platformLogoUrl,
      if (institutionLogoUrl != null && institutionLogoUrl.isNotEmpty)
        'institutionLogoUrl': institutionLogoUrl,
      if (classification != null && classification.isNotEmpty)
        'classification': classification,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _db.ref('Certifications/$certId').set(data);
    return certId;
  }

  /// Elimina una certificación por su ID.
  static Future<void> deleteCertification(String id) async {
    await _db.ref('Certifications/$id').remove();
  }

  // ───────────── PROJECTS WRITE OPERATIONS ─────────────

  /// Crea o actualiza un proyecto en Firebase.
  /// Si [id] no se proporciona, genera uno automáticamente.
  static Future<String> saveProject({
    required String name,
    required String description,
    required String link,
    required List<String> images,
    required List<String> imagesMobile,
    String? title,
    String? classification,
    String? startDate,
    String? endDate,
    String? logo,
    String? id,
    List<String>? technologies,
    String? problemSolved,
    String? difficulties,
    String? testimonials,
    String? responsibilities,
  }) async {
    final projectId = id ?? generateUUID();
    final data = {
      'name': name,
      'description': description,
      'link': link,
      'images': images,
      'imagesMobile': imagesMobile,
      'logo': logo ?? '',
      'timestamp': DateTime.now().toIso8601String(),
      if (title != null && title.isNotEmpty) 'title': title,
      if (classification != null && classification.isNotEmpty)
        'classification': classification,
      if (startDate != null && startDate.isNotEmpty) 'startDate': startDate,
      if (endDate != null && endDate.isNotEmpty) 'endDate': endDate,
      if (technologies != null && technologies.isNotEmpty)
        'technologies': technologies,
      if (problemSolved != null && problemSolved.isNotEmpty)
        'problemSolved': problemSolved,
      if (difficulties != null && difficulties.isNotEmpty)
        'difficulties': difficulties,
      if (testimonials != null && testimonials.isNotEmpty)
        'testimonials': testimonials,
      if (responsibilities != null && responsibilities.isNotEmpty)
        'responsibilities': responsibilities,
    };

    await _db.ref('Projects/$projectId').set(data);
    return projectId;
  }

  /// Elimina un proyecto por su ID.
  static Future<void> deleteProject(String id) async {
    await _db.ref('Projects/$id').remove();
  }

  // ───────────── TECHNOLOGIES ─────────────

  /// Retorna las tecnologías organizadas por categorías desde Firebase.
  /// Lee del nodo 'Stack' y convierte los nombres de las claves a nombres legibles.
  static Future<Map<String, List<String>>> fetchTechnologies() async {
    final snap = await _db.ref('Stack').get();
    if (!snap.exists || snap.value == null) return {};

    final raw = snap.value as Map<dynamic, dynamic>;
    final Map<String, List<String>> technologies = {};

    // Mapeo de nombres de claves en Firebase a nombres de categorías legibles
    final categoryNames = {
      'APIseIntegraciones': 'APIs e Integraciones',
      'AnalisisModelado': 'Análisis y Modelado',
      'Arquitectura': 'Arquitectura',
      'AutenticacionSeguridad': 'Autenticación y Seguridad',
      'Backend': 'Backend',
      'BigData': 'Big Data',
      'Cloud': 'Cloud',
      'ControlDeVersiones': 'Control de Versiones',
      'Data': 'Data',
      'Despliegue': 'Despliegue',
      'DevOps': 'DevOps',
      'DiseñoUIUX': 'Diseño UI/UX',
      'Frontend': 'Frontend',
      'HerramientasDesarrollo': 'Herramientas de Desarrollo',
      'IA': 'Inteligencia Artificial',
      'Lenguajes': 'Lenguajes',
      'Metodologias': 'Metodologías',
      'Mobile': 'Mobile',
      'MonitoreoObservabilidad': 'Monitoreo y Observabilidad',
      'ORMs': 'ORMs',
      'Testing': 'Testing',
    };

    raw.forEach((key, value) {
      final categoryKey = key.toString();
      final categoryName = categoryNames[categoryKey] ?? categoryKey;

      if (value is List) {
        technologies[categoryName] = List<String>.from(
          value.map((e) => e.toString()),
        );
      } else if (value is Map) {
        // Si el valor es un mapa, convertir sus valores a una lista
        final items = <String>[];
        (value).forEach((k, v) {
          if (v != null) {
            items.add(v.toString());
          }
        });
        if (items.isNotEmpty) {
          technologies[categoryName] = items;
        }
      }
    });

    return technologies;
  }

  // ───────────── HELPERS ─────────────

  /// Genera un UUID v4 simple (compatible con la estructura de Firebase).
  static String generateUUID() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random1 = DateTime.now().microsecond;
    final random2 = (timestamp * random1) % 1000000;

    return '${timestamp.toRadixString(16)}-${random1.toRadixString(16)}-${random2.toRadixString(16)}-${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}';
  }

  /// Genera un ID único (similar al de Firebase).
  static String _generateId() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final result = StringBuffer(random);
    for (int i = 0; i < 10; i++) {
      result.write(chars[DateTime.now().microsecond % chars.length]);
    }
    return result.toString();
  }
}
