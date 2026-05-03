import 'package:cv_anth/utils/Colors.dart';
import 'package:cv_anth/utils/google_drive_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../services/firebase_service.dart';
import '../../widgets/certification_widgets.dart';

class CertificationDetail extends StatefulWidget {
  final String certificationId;

  const CertificationDetail({super.key, required this.certificationId});

  @override
  State<CertificationDetail> createState() => _CertificationDetailState();
}

class _CertificationDetailState extends State<CertificationDetail> {
  Map<String, dynamic>? certification;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCertification();
  }

  void _loadCertification() {
    FirebaseService.fetchCertificationById(widget.certificationId)
        .then((data) {
          if (data != null) {
            setState(() {
              certification = data;
              isLoading = false;
            });
          } else {
            setState(() {
              errorMessage = 'Certificación no encontrada';
              isLoading = false;
            });
          }
        })
        .catchError((error) {
          setState(() {
            errorMessage = 'Error al cargar: $error';
            isLoading = false;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.light,
        appBar: AppBar(
          title: const Text('Certificación'),
          backgroundColor: AppColors.light,
          foregroundColor: AppColors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/certification'),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.light,
        appBar: AppBar(
          title: const Text('Certificación'),
          backgroundColor: AppColors.light,
          foregroundColor: AppColors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/certification'),
          ),
        ),
        body: Center(
          child: Text(
            errorMessage ?? 'Error desconocido',
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    if (certification == null) {
      return Scaffold(
        backgroundColor: AppColors.light,
        appBar: AppBar(
          title: const Text('Certificación'),
          backgroundColor: AppColors.light,
          foregroundColor: AppColors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/certification'),
          ),
        ),
        body: const Center(child: Text('No hay datos disponibles')),
      );
    }

    final name = certification?['name'] ?? 'Sin nombre';
    final description = certification?['description'] ?? '';
    final series = certification?['series'] as String? ?? '';
    final link = certification?['link'] as String? ?? '';
    final platformLogoUrl = certification?['platformLogoUrl'] as String? ?? '';
    final institutionLogoUrl =
        certification?['institutionLogoUrl'] as String? ?? '';

    // Resolución de la URL del PDF:
    // 1) Si tiene 'driveFileId' se usa la URL de descarga directa de Drive.
    // 2) Si el documento tiene 'pdfUrl' se usa como respaldo.
    final rawPdfUrl = certification?['pdfUrl'] as String? ?? '';
    final driveFileId = certification?['driveFileId'] as String? ?? '';
    final pdfUrl = driveFileId.isNotEmpty
        ? GoogleDriveUtils.buildDriveDownloadUrl(driveFileId)
        : rawPdfUrl;

    return Scaffold(
      backgroundColor: AppColors.light,
      appBar: AppBar(
        title: const Text('Certificación'),
        backgroundColor: AppColors.light,
        foregroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/certification'),
        ),
        actions: [
          // Botón de edición (solo visible si está autenticado)
          if (authController.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar certificación',
              onPressed: () =>
                  context.go('/certification/${widget.certificationId}/edit'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logos
                CertificationLogoSection(
                  platformLogoUrl: platformLogoUrl,
                  institutionLogoUrl: institutionLogoUrl,
                ),
                // Título
                CertificationHeader(
                  name: name,
                  series: series,
                  description: description,
                  link: link,
                ),
              ],
            ),
            // PDF Viewer
            CertificationPdfViewer(pdfUrl: pdfUrl),

            const SizedBox(height: 40),

            // Galería de imágenes
            if (certification?['images'] != null &&
                (certification!['images'] as List).isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ImageGallerySection(
                  title: 'Galería de Imágenes',
                  icon: Icons.photo_library,
                  color: AppColors.black,
                  images: certification!['images'] as List<dynamic>,
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/certification'),
        backgroundColor: AppColors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.arrow_back, color: AppColors.light),
      ),
    );
  }
}
