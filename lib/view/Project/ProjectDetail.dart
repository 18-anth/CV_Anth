import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../Components/iphone_webview.dart';
import '../../Components/device_frame.dart';
import '../../services/firebase_service.dart';
import '../../controllers/auth_controller.dart';

class ProjectDetail extends StatefulWidget {
  final String projectId;

  const ProjectDetail({super.key, required this.projectId});

  @override
  State<ProjectDetail> createState() => _ProjectDetailState();
}

class _ProjectDetailState extends State<ProjectDetail> {
  Map<String, dynamic>? project;
  bool isLoading = true;
  String? errorMessage;
  String? selectedView;

  @override
  void initState() {
    super.initState();
    _loadProject();
  }

  Future<void> _loadProject() async {
    try {
      final data = await FirebaseService.fetchProjectById(widget.projectId);
      if (!mounted) return;
      setState(() {
        project = data;
        errorMessage = data == null ? 'Proyecto no encontrado' : null;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Error al cargar: $error';
        isLoading = false;
      });
    }
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

  double _getPreviewWidth(String? view) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet =
        MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1024;

    final viewToUse =
        view ??
        (isMobile
            ? 'android'
            : isTablet
            ? 'tablet'
            : 'iphone');

    switch (viewToUse) {
      case 'iphone':
        return 390;
      case 'android':
        return 412;
      case 'tablet':
        return 768;
      default:
        return MediaQuery.of(context).size.width * 0.8;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Detalles del Proyecto'),
          backgroundColor: const Color(0xFF0d0d0d),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/project'),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Detalles del Proyecto'),
          backgroundColor: const Color(0xFF0d0d0d),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/project'),
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

    if (project == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Detalles del Proyecto'),
          backgroundColor: const Color(0xFF0d0d0d),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/project'),
          ),
        ),
        body: const Center(child: Text('No hay datos disponibles')),
      );
    }

    final name = project?['name'] ?? 'Sin nombre';
    final description = project?['description'] ?? '';
    final link = project?['link'] ?? '';
    final logo = project?['logo'] as String?;

    final isMobile = MediaQuery.of(context).size.width < 600;
    final isWeb = MediaQuery.of(context).size.width >= 1024;

    // ── Columna izquierda: título y descripción ──
    final titleColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo del proyecto
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF050A30).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: (logo != null && logo.isNotEmpty)
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _fixGoogleDriveUrl(logo),
                    width: 500,
                    height: 500,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 500,
                        height: 500,
                        decoration: BoxDecoration(
                          color: const Color(0xFF050A30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.code,
                          color: Colors.white,
                          size: 40,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 500,
                        height: 500,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          color: const Color(0xFF050A30),
                        ),
                      );
                    },
                  ),
                )
              : Container(
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    color: const Color(0xFF050A30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.code, color: Colors.white, size: 40),
                ),
        ),
        const SizedBox(height: 24),
        Text(
          name,
          style: const TextStyle(
            color: Color(0xFF050A30),
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          description,
          textAlign: TextAlign.justify,
          style: const TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
        ),
      ],
    );

    // ── Columna derecha: tabs + preview ──
    final previewColumn = link.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildViewTab('iphone', Icons.phone_iphone, 'iPhone'),
                    _buildViewTab('android', Icons.phone_android, 'Android'),
                    _buildViewTab('tablet', Icons.tablet_mac, 'Tablet'),
                    _buildViewTab(null, Icons.devices_other, 'Auto'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Preview container
              Center(
                child: SizedBox(
                  width: _getPreviewWidth(selectedView),
                  height: isMobile ? 640 : 820,
                  child: selectedView == null
                      ? IphoneWebView(link: link)
                      : DeviceFrame(
                          deviceType: selectedView == 'iphone'
                              ? DeviceType.iphone
                              : selectedView == 'android'
                              ? DeviceType.android
                              : DeviceType.tablet,
                          child: IphoneWebView(link: link),
                        ),
                ),
              ),
            ],
          )
        : Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'No hay enlace disponible para este proyecto',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detalles del Proyecto'),
        backgroundColor: const Color(0xFF0d0d0d),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/project'),
        ),
        actions: [
          // Botón de editar (solo visible si está autenticado)
          Consumer<AuthController>(
            builder: (context, auth, child) {
              if (!auth.isAuthenticated) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Editar Proyecto',
                onPressed: () =>
                    context.go('/project/${widget.projectId}/edit'),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Contenido principal (título + preview)
              isWeb
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Columna izquierda
                        Expanded(flex: 2, child: titleColumn),
                        // Columna derecha
                        Expanded(flex: 3, child: previewColumn),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 30),
                          child: titleColumn,
                        ),
                        previewColumn,
                        const SizedBox(height: 40),
                      ],
                    ),

              // Secciones de imágenes
              const SizedBox(height: 60),
              _buildImageGallerySection(
                title: 'Imágenes Web',
                icon: Icons.computer,
                color: Colors.blue,
                images: project?['images'] as List<dynamic>? ?? [],
              ),
              const SizedBox(height: 40),
              _buildImageGallerySection(
                title: 'Imágenes Mobile',
                icon: Icons.phone_android,
                color: Colors.green,
                images: project?['imagesMobile'] as List<dynamic>? ?? [],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/project'),
        backgroundColor: const Color(0xFF040404),
        shape: const CircleBorder(),
        child: const Icon(Icons.arrow_back, color: Color(0xFFF4F4F4)),
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
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No hay imágenes $title',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
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
                borderRadius: BorderRadius.circular(10),
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
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF050A30),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${images.length} ${images.length == 1 ? 'imagen' : 'imágenes'}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            final imageUrl = images[index] as String;
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
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
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
                    color: Colors.grey[200],
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
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.broken_image,
                      size: 48,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
              // Overlay con número de imagen
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '#$imageNumber',
                    style: const TextStyle(
                      color: Colors.white,
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
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.zoom_in,
                          color: Colors.white,
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
            // Imagen ampliada
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  _fixGoogleDriveUrl(imageUrl),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      padding: const EdgeInsets.all(40),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.white,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Error al cargar la imagen',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            // Botón cerrar
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewTab(String? viewType, IconData icon, String label) {
    final isSelected = selectedView == viewType;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => selectedView = viewType),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? const Color(0xFF050A30) : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isSelected
                  ? const Color(0xFF050A30).withOpacity(0.1)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? const Color(0xFF050A30)
                      : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF050A30)
                        : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
