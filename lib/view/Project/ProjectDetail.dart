import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../Components/iphone_webview.dart';
import '../../Components/device_frame.dart';
import '../../services/firebase_service.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/Colors.dart';

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

    final title = project?['title'] ?? '';
    final name = project?['name'] ?? 'Sin nombre';
    final description = project?['description'] ?? '';
    final link = project?['link'] ?? '';
    final logo = project?['logo'] as String?;
    final classification = project?['classification'] as String?;
    final startDate = project?['startDate'] as String?;
    final endDate = project?['endDate'] as String?;
    final technologies = project?['technologies'] as List<dynamic>?;

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
        // Título (si existe)
        if (title.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 32),
              const SizedBox(width: 1),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
        Text(
          description,
          textAlign: TextAlign.justify,
          style: const TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
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
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                Text(
                  _formatDate(startDate),
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
              if (startDate != null && endDate != null)
                const Text(
                  '→',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              if (endDate != null) ...[
                const Icon(Icons.event_available, size: 16, color: Colors.grey),
                Text(
                  _formatDate(endDate),
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
        ],
        // Nombre del proyecto
        Text(
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                const Icon(Icons.category, size: 16, color: Color(0xFF050A30)),
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
          _buildTechnologiesSection(technologies),
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Enero',
        'Febrero',
        'Marzo',
        'Abril',
        'Mayo',
        'Junio',
        'Julio',
        'Agosto',
        'Septiembre',
        'Octubre',
        'Noviembre',
        'Diciembre',
      ];
      return '${date.day} de ${months[date.month - 1]} de ${date.year}';
    } catch (e) {
      return dateString;
    }
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

  // ══════════════════════════════════════════════════════════════
  // SECCIÓN DE TECNOLOGÍAS ORGANIZADAS
  // ══════════════════════════════════════════════════════════════

  // Mapa de categorías con sus tecnologías y colores
  static const Map<String, List<String>> _technologiesMap = {
    'Lenguajes de Programación': [
      'Dart',
      'Flutter',
      'JavaScript',
      'TypeScript',
      'Python',
      'Java',
      'Kotlin',
      'Swift',
      'C#',
      'C++',
      'PHP',
      'Ruby',
      'Go',
      'Rust',
    ],
    'Frontend': [
      'React',
      'React Native',
      'Angular',
      'Vue.js',
      'Next.js',
      'Nuxt.js',
      'Svelte',
      'HTML5',
      'CSS3',
      'SASS',
      'Tailwind CSS',
      'Bootstrap',
      'Material UI',
    ],
    'Backend': [
      'Node.js',
      'Express.js',
      'NestJS',
      'Django',
      'Flask',
      'FastAPI',
      'Spring Boot',
      'Laravel',
      'Ruby on Rails',
      '.NET Core',
    ],
    'Bases de Datos': [
      'Firebase Realtime DB',
      'Firestore',
      'MongoDB',
      'MySQL',
      'PostgreSQL',
      'SQLite',
      'Redis',
      'Elasticsearch',
      'Oracle',
      'SQL Server',
    ],
    'Cloud & DevOps': [
      'Google Cloud',
      'AWS',
      'Azure',
      'Firebase',
      'Docker',
      'Kubernetes',
      'Jenkins',
      'GitHub Actions',
      'GitLab CI/CD',
      'Terraform',
    ],
    'Metodologías': [
      'Scrum',
      'Kanban',
      'Agile',
      'Waterfall',
      'Lean',
      'XP (Extreme Programming)',
    ],
    'Arquitectura': [
      'MVC',
      'MVVM',
      'Clean Architecture',
      'Hexagonal Architecture',
      'Microservicios',
      'Monolítico',
      'REST API',
      'GraphQL',
      'gRPC',
    ],
    'Control de Versiones': ['Git', 'GitHub', 'GitLab', 'Bitbucket', 'SVN'],
    'Testing': [
      'Jest',
      'Mocha',
      'Cypress',
      'Selenium',
      'JUnit',
      'PyTest',
      'Flutter Test',
    ],
    'Inteligencia Artificial': [
      'TensorFlow',
      'PyTorch',
      'Keras',
      'Scikit-learn',
      'OpenAI',
      'Hugging Face',
      'LangChain',
      'Machine Learning',
      'Deep Learning',
      'Computer Vision',
      'NLP',
      'GPT',
      'LLaMA',
      'Stable Diffusion',
      'YOLO',
      'Random Forest',
      'XGBoost',
      'LightGBM',
      'Gradient Boosting',
      'Extra Trees',
      'CatBoost',
      'AdaBoost',
      'Neural Networks',
      'CNN',
      'RNN',
      'Transformers',
      'SVM',
      'Decision Trees',
      'K-Means',
      'PCA',
      'Regresión Logística',
    ],
    'Otros': [
      'GraphQL',
      'WebSockets',
      'OAuth',
      'JWT',
      'Socket.io',
      'Redux',
      'Provider',
      'Bloc',
      'GetX',
    ],
  };

  // Iconos para cada categoría
  static const Map<String, IconData> _categoryIcons = {
    'Lenguajes de Programación': Icons.code,
    'Frontend': Icons.web,
    'Backend': Icons.storage,
    'Bases de Datos': Icons.storage_rounded,
    'Cloud & DevOps': Icons.cloud,
    'Metodologías': Icons.track_changes,
    'Arquitectura': Icons.account_tree,
    'Control de Versiones': Icons.source,
    'Testing': Icons.bug_report,
    'Inteligencia Artificial': Icons.psychology,
    'Otros': Icons.extension,
  };

  // Organiza las tecnologías por categorías
  Map<String, List<String>> _categorizeTechnologies(
    List<dynamic> technologies,
  ) {
    final categorized = <String, List<String>>{};
    final techSet = technologies.map((e) => e.toString()).toSet();

    _technologiesMap.forEach((category, categoryTechs) {
      final matchingTechs = categoryTechs
          .where((tech) => techSet.contains(tech))
          .toList();
      if (matchingTechs.isNotEmpty) {
        categorized[category] = matchingTechs;
      }
    });

    return categorized;
  }

  Widget _buildTechnologiesSection(List<dynamic> technologies) {
    final categorized = _categorizeTechnologies(technologies);

    if (categorized.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.light5,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado principal
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.settings_suggest,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Stack Tecnológico',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      '${technologies.length} tecnologías utilizadas',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.darkgrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Categorías con sus tecnologías en dos columnas (siempre)
          () {
            final categories = categorized.entries.toList();
            final mid = (categories.length / 2).ceil();
            final leftCategories = categories.sublist(0, mid);
            final rightCategories = categories.sublist(mid);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: leftCategories.map((entry) {
                      return _buildCategoryWidget(entry.key, entry.value);
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: rightCategories.map((entry) {
                      return _buildCategoryWidget(entry.key, entry.value);
                    }).toList(),
                  ),
                ),
              ],
            );
          }(),
        ],
      ),
    );
  }

  // Construye el widget de una categoría individual
  Widget _buildCategoryWidget(String category, List<String> techs) {
    final icon = _categoryIcons[category] ?? Icons.code;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado de categoría
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.black),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${techs.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Tecnologías de la categoría
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            children: techs.map((tech) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  tech,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
