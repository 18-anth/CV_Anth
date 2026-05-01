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

    final isMobile = MediaQuery.of(context).size.width < 600;
    final isWeb = MediaQuery.of(context).size.width >= 1024;

    // ── Columna izquierda: título y descripción ──
    final titleColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
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
          child: isWeb
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
