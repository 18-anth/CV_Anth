import 'package:cv_anth/utils/Colors.dart';
import 'package:cv_anth/utils/google_drive_utils.dart';
import 'package:cv_anth/utils/web_pdf_viewer.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Widget para mostrar los logos de plataforma e institución
class CertificationLogoSection extends StatelessWidget {
  final String platformLogoUrl;
  final String institutionLogoUrl;

  const CertificationLogoSection({
    super.key,
    required this.platformLogoUrl,
    required this.institutionLogoUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (platformLogoUrl.isEmpty && institutionLogoUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (platformLogoUrl.isNotEmpty) ...[
            _buildLogoColumn(
              url: platformLogoUrl,
              label: 'Plataforma',
              icon: Icons.school_rounded,
            ),
            if (institutionLogoUrl.isNotEmpty) const SizedBox(width: 30),
          ],
          if (institutionLogoUrl.isNotEmpty)
            _buildLogoColumn(
              url: institutionLogoUrl,
              label: 'Institución',
              icon: Icons.account_balance,
            ),
        ],
      ),
    );
  }

  Widget _buildLogoColumn({
    required String url,
    required String label,
    required IconData icon,
  }) {
    return Column(
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
              GoogleDriveUtils.fixGoogleDriveUrl(url),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(icon, size: 45, color: AppColors.grey);
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.black.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget para mostrar el encabezado de la certificación
class CertificationHeader extends StatelessWidget {
  final String name;
  final String series;
  final String description;
  final String link;

  const CertificationHeader({
    super.key,
    required this.name,
    this.series = '',
    this.description = '',
    this.link = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
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
          SelectableText(
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
            _buildSeriesBadge(series),
          ],
          if (description.isNotEmpty) ...[
            const SizedBox(height: 16),
            SelectableText(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.darkgrey, fontSize: 16),
            ),
          ],
          if (link.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildLinkButton(link),
          ],
        ],
      ),
    );
  }

  Widget _buildSeriesBadge(String series) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.black, AppColors.black.withOpacity(0.85)],
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
        border: Border.all(color: AppColors.grey.withOpacity(0.2), width: 1),
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
          SelectableText(
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
    );
  }

  Widget _buildLinkButton(String link) {
    return Container(
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
            await launchUrl(uri, mode: LaunchMode.externalApplication);
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
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

/// Widget para mostrar el visor de PDF
class CertificationPdfViewer extends StatelessWidget {
  final String pdfUrl;

  const CertificationPdfViewer({super.key, required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    if (pdfUrl.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
    );
  }

  Widget _buildPdfViewer(String url) {
    if (kIsWeb) {
      final viewId = 'pdf-view-${DateTime.now().millisecondsSinceEpoch}';
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
}

/// Widget para mostrar la galería de imágenes
class ImageGallerySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<dynamic> images;

  const ImageGallerySection({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return _buildEmptyState();
    }

    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet =
        MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1024;
    final crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context),
        const SizedBox(height: 24),
        _buildImageGrid(context, crossAxisCount),
      ],
    );
  }

  Widget _buildEmptyState() {
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

  Widget _buildSectionHeader(BuildContext context) {
    return Container(
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
    );
  }

  Widget _buildImageGrid(BuildContext context, int crossAxisCount) {
    return GridView.builder(
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
        return ImageCard(imageUrl: imageUrl, imageNumber: index + 1);
      },
    );
  }
}

/// Widget para mostrar una tarjeta de imagen individual
class ImageCard extends StatelessWidget {
  final String imageUrl;
  final int imageNumber;

  const ImageCard({
    super.key,
    required this.imageUrl,
    required this.imageNumber,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageDialog(context),
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
              _buildImage(),
              _buildImageNumberBadge(),
              _buildHoverOverlay(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Image.network(
      GoogleDriveUtils.buildDriveImageUrl(imageUrl),
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
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 48, color: AppColors.grey),
              SizedBox(height: 8),
              Text(
                'Error al cargar',
                style: TextStyle(color: AppColors.darkgrey, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageNumberBadge() {
    return Positioned(
      top: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          border: Border.all(color: AppColors.light.withOpacity(0.2), width: 1),
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
    );
  }

  Widget _buildHoverOverlay(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showImageDialog(context),
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.black.withOpacity(0.3),
          highlightColor: AppColors.black.withOpacity(0.2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.black.withOpacity(0.4)],
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
    );
  }

  void _showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ImageDialog(imageUrl: imageUrl),
    );
  }
}

/// Widget para mostrar el diálogo con la imagen ampliada
class ImageDialog extends StatelessWidget {
  final String imageUrl;

  const ImageDialog({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [_buildImageContainer(context), _buildCloseButton(context)],
      ),
    );
  }

  Widget _buildImageContainer(BuildContext context) {
    return Center(
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
            GoogleDriveUtils.buildDriveImageUrl(imageUrl),
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
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Positioned(
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
            child: const Icon(Icons.close, color: AppColors.light, size: 24),
          ),
        ),
      ),
    );
  }
}
