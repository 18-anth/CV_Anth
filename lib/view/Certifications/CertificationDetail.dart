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

  /// Extrae el ID del archivo de Google Drive usando regex simple
  String? _extractDriveFileId(String url) {
    if (url.isEmpty) return null;
    // Extrae file IDs de Google Drive (típicamente 25+ caracteres)
    final regex = RegExp(r'[-\w]{25,}');
    final match = regex.firstMatch(url);
    return match?.group(0);
  }

  /// Construye la URL correcta para imágenes de Google Drive
  /// Usa drive.google.com/uc?export=view que es estable y evita rate-limiting
  String _buildDriveImageUrl(String url) {
    final fileId = _extractDriveFileId(url);
    if (fileId != null) {
      return 'https://drive.google.com/uc?export=view&id=$fileId';
    }
    return url; // Si no es Drive, devolver la URL original
  }

  /// Renderiza SOLO PDFs (separado de imágenes)
  Widget _buildPdfViewer(String url) {
    if (kIsWeb) {
      final viewId = 'pdf-view-${DateTime.now().millisecondsSinceEpoch}';

      // usar google docs viewer
      final viewerUrl =
          'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(url)}';

      return SizedBox(
        height: 600,
        child: buildWebPdfViewerWidget(viewerUrl, viewId),
      );
    } else {
      return SizedBox(
        height: 600,
        child: WebViewWidget(
          controller: WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..loadRequest(Uri.parse(url)),
        ),
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
    // 1) Si tiene 'driveFileId' se usa la URL de descarga directa de Drive.
    // 2) Si el documento tiene 'pdfUrl' se usa como respaldo.
    final rawPdfUrl = certification?['pdfUrl'] as String? ?? '';
    final driveFileId = certification?['driveFileId'] as String? ?? '';
    final pdfUrl = driveFileId.isNotEmpty
        ? 'https://drive.google.com/uc?export=download&id=$driveFileId'
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
                // Logos (si existen)
                if (platformLogoUrl.isNotEmpty || institutionLogoUrl.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (platformLogoUrl.isNotEmpty) ...[
                          Column(
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: AppColors.light,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.black.withOpacity(0.15),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: AppColors.grey.withOpacity(0.2),
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    _fixGoogleDriveUrl(platformLogoUrl),
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.school_rounded,
                                        size: 45,
                                        color: AppColors.grey,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.black.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Plataforma',
                                  style: TextStyle(
                                    color: AppColors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (institutionLogoUrl.isNotEmpty)
                            const SizedBox(width: 30),
                        ],
                        if (institutionLogoUrl.isNotEmpty)
                          Column(
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: AppColors.light,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.black.withOpacity(0.15),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: AppColors.grey.withOpacity(0.2),
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    _fixGoogleDriveUrl(institutionLogoUrl),
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.account_balance,
                                        size: 45,
                                        color: AppColors.grey,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.black.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Institución',
                                  style: TextStyle(
                                    color: AppColors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                // Título
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 30,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primary],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.08),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.3,
                          shadows: [
                            Shadow(
                              color: AppColors.grey.withOpacity(0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      if (series.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.black,
                                AppColors.black.withOpacity(0.85),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 1,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: AppColors.black.withOpacity(0.1),
                                blurRadius: 6,
                                spreadRadius: -2,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: AppColors.grey.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.light,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.light.withOpacity(0.5),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                series,
                                style: const TextStyle(
                                  color: AppColors.light,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
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
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withOpacity(0.3),
                                blurRadius: 16,
                                spreadRadius: 2,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final uri = Uri.parse(link);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                            icon: const Icon(Icons.link_rounded, size: 22),
                            label: const Text(
                              'Ver Certificado en Línea',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.black,
                              foregroundColor: AppColors.light,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 18,
                              ),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
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
                  child: _buildPdfViewer(pdfUrl),
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
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.08), color.withOpacity(0.03)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.15), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(icon, color: AppColors.light, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: color,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${images.length} imagen${images.length != 1 ? 'es' : ''}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Grid de imágenes
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
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
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.2),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: -2,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: AppColors.grey.withOpacity(0.15), width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                _buildDriveImageUrl(imageUrl),
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
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.black.withOpacity(0.9),
                        AppColors.black.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.light.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '#$imageNumber',
                    style: const TextStyle(
                      color: AppColors.light,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
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
                    borderRadius: BorderRadius.circular(16),
                    splashColor: AppColors.black.withOpacity(0.3),
                    highlightColor: AppColors.black.withOpacity(0.2),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.black.withOpacity(0.4),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withOpacity(0.5),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.zoom_in_rounded,
                            color: AppColors.light,
                            size: 36,
                          ),
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
                    _buildDriveImageUrl(imageUrl),
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
