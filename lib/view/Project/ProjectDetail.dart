import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../Components/iphone_webview.dart';
import '../../Components/device_frame.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/project_detail_controller.dart';
import '../../utils/Colors.dart';
import '../../widgets/ProjectDetail/project_detail_image_gallery.dart';
import '../../widgets/ProjectDetail/project_detail_technologies.dart';
import '../../widgets/ProjectDetail/project_detail_info_slider.dart';
import '../../widgets/ProjectDetail/project_detail_view_tab.dart';

class ProjectDetail extends StatefulWidget {
  final String projectId;

  const ProjectDetail({super.key, required this.projectId});

  @override
  State<ProjectDetail> createState() => _ProjectDetailState();
}

class _ProjectDetailState extends State<ProjectDetail> {
  late final ProjectDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProjectDetailController();
    _controller.loadTechnologies();
    _controller.loadProject(widget.projectId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text('Detalles del Proyecto'),
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0d0d0d),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/project'),
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (_controller.errorMessage != null) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text('Detalles del Proyecto'),
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0d0d0d),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/project'),
              ),
            ),
            body: Center(
              child: Text(
                _controller.errorMessage ?? 'Error desconocido',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          );
        }

        if (_controller.project == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text('Detalles del Proyecto'),
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0d0d0d),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/project'),
              ),
            ),
            body: const Center(child: Text('No hay datos disponibles')),
          );
        }

        final project = _controller.project!;
        final title = project['title'] ?? '';
        final name = project['name'] ?? 'Sin nombre';
        final description = project['description'] ?? '';
        final link = project['link'] ?? '';
        final logo = project['logo'] as String?;
        final classification = project['classification'] as String?;
        final startDate = project['startDate'] as String?;
        final endDate = project['endDate'] as String?;
        final technologies = project['technologies'] as List<dynamic>?;
        final problemSolved = project['problemSolved'] as String?;
        final difficulties = project['difficulties'] as String?;
        final testimonials = project['testimonials'] as String?;
        final responsibilities = project['responsibilities'] as String?;

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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(40),
              ),
              child: (logo != null && logo.isNotEmpty)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.network(
                        _controller.fixGoogleDriveUrl(logo),
                        width: 500,
                        height: 500,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 500,
                            height: 500,
                            decoration: BoxDecoration(
                              color: const Color(0xFF050A30),
                              borderRadius: BorderRadius.circular(40),
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
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.code,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            // Título (si existe)
            if (title.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 32),
                  const SizedBox(width: 1),
                  Flexible(
                    child: SelectableText(
                      title,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      style: const TextStyle(
                        color: Color(0xFF050A30),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Descripción
            SelectableText(
              description,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            // Fechas (si existen)
            if (startDate != null || endDate != null) ...[
              Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (startDate != null) ...[
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey,
                    ),
                    Text(
                      _controller.formatDate(startDate),
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                  if (startDate != null && endDate != null)
                    const Text(
                      '→',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  if (endDate != null) ...[
                    const Icon(
                      Icons.event_available,
                      size: 16,
                      color: Colors.grey,
                    ),
                    Text(
                      _controller.formatDate(endDate),
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
            ],
            // Nombre del proyecto
            SelectableText(
              name,
              style: const TextStyle(
                color: Color(0xFF050A30),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Clasificación (si existe)
            if (classification != null && classification.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF050A30).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF050A30).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.category,
                      size: 16,
                      color: Color(0xFF050A30),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        classification,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF050A30),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Tecnologías (si existen)
            if (technologies != null && technologies.isNotEmpty) ...[
              ProjectDetailTechnologies(
                technologies: technologies,
                categorized: _controller.categorizeTechnologies(technologies),
                categoryIcons: ProjectDetailController.categoryIcons,
              ),
              const SizedBox(height: 16),
            ],
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
                        ProjectDetailViewTab(
                          viewType: 'iphone',
                          selectedView: _controller.selectedView,
                          icon: Icons.phone_iphone,
                          label: 'iPhone',
                          onTap: _controller.setSelectedView,
                        ),
                        ProjectDetailViewTab(
                          viewType: 'android',
                          selectedView: _controller.selectedView,
                          icon: Icons.phone_android,
                          label: 'Android',
                          onTap: _controller.setSelectedView,
                        ),
                        ProjectDetailViewTab(
                          viewType: 'tablet',
                          selectedView: _controller.selectedView,
                          icon: Icons.tablet_mac,
                          label: 'Tablet',
                          onTap: _controller.setSelectedView,
                        ),
                        ProjectDetailViewTab(
                          viewType: null,
                          selectedView: _controller.selectedView,
                          icon: Icons.devices_other,
                          label: 'Auto',
                          onTap: _controller.setSelectedView,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Preview container
                  Center(
                    child: SizedBox(
                      width: _getPreviewWidth(_controller.selectedView),
                      height: isMobile ? 640 : 820,
                      child: _controller.selectedView == null
                          ? IphoneWebView(link: link)
                          : DeviceFrame(
                              deviceType: _controller.selectedView == 'iphone'
                                  ? DeviceType.iphone
                                  : _controller.selectedView == 'android'
                                  ? DeviceType.android
                                  : DeviceType.tablet,
                              child: IphoneWebView(link: link),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ProjectDetailInfoSlider(
                    problemSolved: problemSolved,
                    difficulties: difficulties,
                    testimonials: testimonials,
                    responsibilities: responsibilities,
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
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0d0d0d),
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
                crossAxisAlignment: CrossAxisAlignment.center,
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
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                  ProjectDetailImageGallery(
                    title: 'Imágenes Web',
                    icon: Icons.computer,
                    color: Colors.blue,
                    images: project['images'] as List<dynamic>? ?? [],
                    fixUrl: _controller.fixGoogleDriveUrl,
                  ),
                  const SizedBox(height: 40),
                  ProjectDetailImageGallery(
                    title: 'Imágenes Mobile',
                    icon: Icons.phone_android,
                    color: Colors.green,
                    images: project['imagesMobile'] as List<dynamic>? ?? [],
                    fixUrl: _controller.fixGoogleDriveUrl,
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
      },
    );
  }
}
