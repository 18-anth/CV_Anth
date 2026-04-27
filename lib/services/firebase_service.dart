import 'package:cloud_firestore/cloud_firestore.dart';

/// Servicio para obtener datos de Firebase Firestore.
///
/// Colecciones esperadas en Firestore:
///   - `projects`       → documentos con campos: name, description, timestamp,
///                        githubUrl?, demoUrl?, technologies?, driveFileId?
///   - `certifications` → documentos con campos: name, description,
///                        driveFileId (ID del PDF en Drive), imageUrl?
///
/// Los archivos grandes (PDFs, .glb) se sirven desde Google Drive /
/// Firebase Storage respectivamente y se referencian por ID/path.
class FirebaseService {
  static final _db = FirebaseFirestore.instance;

  // ───────────── PROJECTS ─────────────

  /// Retorna la lista de proyectos desde la colección `projects`.
  static Future<List<Map<String, dynamic>>> fetchProjects() async {
    final snap = await _db
        .collection('projects')
        .orderBy('timestamp', descending: true)
        .get();
    return snap.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// Retorna un proyecto por su `docId` de Firestore.
  static Future<Map<String, dynamic>?> fetchProjectById(String docId) async {
    final doc = await _db.collection('projects').doc(docId).get();
    if (!doc.exists) return null;
    final data = Map<String, dynamic>.from(doc.data()!);
    data['id'] = doc.id;
    return data;
  }

  // ───────────── CERTIFICATIONS ─────────────

  /// Retorna la lista de certificaciones desde la colección `certifications`.
  /// Cada documento debe tener un campo `driveFileId` con el ID del PDF en Drive.
  static Future<List<Map<String, dynamic>>> fetchCertifications() async {
    final snap = await _db.collection('certifications').orderBy('name').get();
    return snap.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// Retorna una certificación por su `docId` de Firestore.
  static Future<Map<String, dynamic>?> fetchCertificationById(
    String docId,
  ) async {
    final doc = await _db.collection('certifications').doc(docId).get();
    if (!doc.exists) return null;
    final data = Map<String, dynamic>.from(doc.data()!);
    data['id'] = doc.id;
    return data;
  }
}
