import 'package:cv_anth/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
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
    }).catchError((error) {
      setState(() {
        errorMessage = 'Error al cargar: $error';
        isLoading = false;
      });
    });
  }

  Widget _buildPdfOrImageViewer(String url) {
    final isPdf = url.toLowerCase().endsWith('.pdf');

    if (isPdf) {
      // Para PDFs, usar WebView directamente (como <embed> en React)
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
            color: AppColors.darkgrey.withOpacity(0.2),
            height: 400,
            child: Center(
              child: CircularProgressIndicator(
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
            color: AppColors.darkgrey.withOpacity(0.2),
            height: 400,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  const Text('No se pudo cargar la imagen'),
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
                      backgroundColor: const Color(0xFF050A30),
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
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: AppBar(
          title: const Text('Certificación'),
          backgroundColor: const Color(0xFF0d0d0d),
          foregroundColor: Colors.white,
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
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: AppBar(
          title: const Text('Certificación'),
          backgroundColor: const Color(0xFF0d0d0d),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/certification'),
          ),
        ),
        body: Center(
          child: Text(
            errorMessage ?? 'Error desconocido',
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    if (certification == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: AppBar(
          title: const Text('Certificación'),
          backgroundColor: const Color(0xFF0d0d0d),
          foregroundColor: Colors.white,
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
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text('Certificación'),
        backgroundColor: const Color(0xFF0d0d0d),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/certification'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Título
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                children: [
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF050A30),
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 16,
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
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
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
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'No hay PDF disponible',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/certification'),
        backgroundColor: const Color(0xFF040404),
        shape: const CircleBorder(),
        child: const Icon(Icons.arrow_back, color: Color(0xFFF4F4F4)),
      ),
    );
  }
}
