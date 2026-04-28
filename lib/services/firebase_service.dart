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
}

