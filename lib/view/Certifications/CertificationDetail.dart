import 'package:cv_anth/utils/Colors.dart';
import 'package:cv_anth/utils/web_pdf_viewer.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/auth_controller.dart';
import '../../services/firebase_service.dart';
import '../../services/google_drive_service.dart';

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

  /// Convierte URLs de Google Drive al formato correcto que evita problemas de CORS
  /// Usa lh3.googleusercontent.com que permite acceso directo sin CORS
  String _fixGoogleDriveUrl(String url) {
    if (url.isEmpty) return url;

    // Si ya es el formato correcto (lh3.googleusercontent.com), devolverla sin cambios
    if (url.contains('lh3.googleusercontent.com/d/')) {
      return url;
    }

    // Extraer el ID del archivo de diferentes formatos de URLs de Google Drive
    RegExp regExp = RegExp(r'(?:id=|/d/|/files/)([a-zA-Z0-9_-]+)');
    Match? match = regExp.firstMatch(url);

    if (match != null && match.groupCount > 0) {
      String fileId = match.group(1)!;
      return 'https://lh3.googleusercontent.com/d/$fileId';
    }

    return url;
  }

  Widget _buildPdfOrImageViewer(String url) {
    // En web, el iframe del browser maneja tanto PDFs como imágenes sin CORS
    if (kIsWeb) {
      final viewId = 'cert-iframe-${url.hashCode}';
      return buildWebPdfViewerWidget(url, viewId);
    }

    final isPdf =
        url.toLowerCase().endsWith('.pdf') ||
        url.contains('drive.google.com') ||
        url.contains('docs.google.com');

    if (isPdf) {
      return SizedBox(
        height: 800,
        child: WebViewWidget(
          controller: WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..loadRequest(Uri.parse(url)),
        ),
      );
    } else {
      // Es una imagen
      return Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: AppColors.light5,
            height: 400,
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.black,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.light5,
            height: 400,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.darkgrey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No se pudo cargar la imagen',
                    style: TextStyle(color: AppColors.darkgrey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      }
                    },
                    icon: const Icon(Icons.open_in_new, color: AppColors.light),
                    label: const Text(
                      'Abrir en navegador',
                      style: TextStyle(color: AppColors.light),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
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
    // 1) Si el documento tiene 'pdfUrl' se usa directamente.
    // 2) Si tiene 'driveFileId' se construye la URL de previsualización de Drive.
    final rawPdfUrl = certification?['pdfUrl'] as String? ?? '';
    final driveFileId = certification?['driveFileId'] as String? ?? '';
    final pdfUrl = rawPdfUrl.isNotEmpty
        ? rawPdfUrl
        : driveFileId.isNotEmpty
        ? GoogleDriveService.previewUrl(driveFileId)
        : '';

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
            // Logos (si existen)
            if (platformLogoUrl.isNotEmpty || institutionLogoUrl.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (platformLogoUrl.isNotEmpty) ...[
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.grey.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _fixGoogleDriveUrl(platformLogoUrl),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.school_rounded,
                                size: 40,
                                color: AppColors.grey,
                              );
                            },
                          ),
                        ),
                      ),
                      if (institutionLogoUrl.isNotEmpty)
                        const SizedBox(width: 20),
                    ],
                    if (institutionLogoUrl.isNotEmpty)
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.grey.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _fixGoogleDriveUrl(institutionLogoUrl),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.account_balance,
                                size: 40,
                                color: AppColors.grey,
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // Título
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                children: [
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (series.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.light5,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.grey, width: 1.5),
                      ),
                      child: Text(
                        series,
                        style: const TextStyle(
                          color: AppColors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.darkgrey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                  if (link.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(link);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      icon: const Icon(Icons.link, size: 18),
                      label: const Text('Ver Certificado en Línea'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black,
                        foregroundColor: AppColors.light,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // PDF/Imagen Viewer
            if (pdfUrl.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildPdfOrImageViewer(pdfUrl),
                ),
              )
            else
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: AppColors.light5,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'No hay PDF disponible',
                    style: TextStyle(color: AppColors.darkgrey),
                  ),
                ),
              ),

            const SizedBox(height: 40),

            // Galería de imágenes (si existen)
            if (certification?['images'] != null &&
                (certification!['images'] as List).isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildImageGallerySection(
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

  // ══════════════════════════════════════════════════════════════
  // SECCIÓN DE GALERÍA DE IMÁGENES
  // ══════════════════════════════════════════════════════════════

  Widget _buildImageGallerySection({
    required String title,
    required IconData icon,
    required Color color,
    required List<dynamic> images,
  }) {
    if (images.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.light5,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: AppColors.grey),
            const SizedBox(height: 16),
            const Text(
              'No hay imágenes disponibles',
              style: TextStyle(color: AppColors.darkgrey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet =
        MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1024;

    final crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado de la sección
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    '${images.length} imagen${images.length != 1 ? 'es' : ''}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.darkgrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Grid de imágenes
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            final imageUrl = images[index].toString();
            return _buildImageCard(imageUrl, index + 1);
          },
        ),
      ],
    );
  }

  Widget _buildImageCard(String imageUrl, int imageNumber) {
    return GestureDetector(
      onTap: () => _showImageDialog(imageUrl),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                _fixGoogleDriveUrl(imageUrl),
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: AppColors.light5,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.black,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 3,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.light5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.broken_image,
                          size: 48,
                          color: AppColors.grey,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Error al cargar',
                          style: TextStyle(
                            color: AppColors.darkgrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Overlay con número de imagen
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#$imageNumber',
                    style: const TextStyle(
                      color: AppColors.light,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Overlay hover effect
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showImageDialog(imageUrl),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.zoom_in,
                          color: AppColors.light,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            // Imagen principal
            Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.7),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    _fixGoogleDriveUrl(imageUrl),
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppColors.black,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.light,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.black,
                        padding: const EdgeInsets.all(32),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 64,
                                color: AppColors.light,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Error al cargar la imagen',
                                style: TextStyle(color: AppColors.light),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Botón de cerrar
            Positioned(
              top: 40,
              right: 40,
              child: Material(
                color: AppColors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(50),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.light,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
