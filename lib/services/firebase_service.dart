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

  // ───────────── WRITE OPERATIONS ─────────────

  /// Crea o actualiza una certificación en Firebase.
  /// Si [id] no se proporciona, genera uno automáticamente.
  static Future<String> saveCertification({
    required String name,
    required String driveFileId,
    String? description,
    String? imageUrl,
    String? id,
  }) async {
    final certId = id ?? _generateId();
    final data = {
      'name': name,
      'driveFileId': driveFileId,
      if (description != null && description.isNotEmpty)
        'description': description,
      if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
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
    String? id,
  }) async {
    final projectId = id ?? _generateUUID();
    final data = {
      'name': name,
      'description': description,
      'link': link,
      'images': images,
      'imagesMobile': imagesMobile,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _db.ref('Projects/$projectId').set(data);
    return projectId;
  }

  /// Elimina un proyecto por su ID.
  static Future<void> deleteProject(String id) async {
    await _db.ref('Projects/$id').remove();
  }

  // ───────────── HELPERS ─────────────

  /// Genera un UUID v4 simple (compatible con la estructura de Firebase).
  static String _generateUUID() {
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
