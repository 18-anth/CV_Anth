import 'package:cv_anth/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/BookModel.dart';
import '../../services/firebase_service.dart';
import '../../services/google_drive_service.dart';

class CertificationModel {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String? series;
  final String? link;
  final String? platformLogoUrl;
  final String? institutionLogoUrl;
  final String classification;

  CertificationModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.series,
    this.link,
    this.platformLogoUrl,
    this.institutionLogoUrl,
    this.classification = '',
  });

  factory CertificationModel.fromMap(Map<String, dynamic> data) {
    return CertificationModel(
      id: data['id']?.toString() ?? '',
      name: data['name'] ?? 'Sin nombre',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      series: data['series'],
      link: data['link'],
      platformLogoUrl: data['platformLogoUrl'],
      institutionLogoUrl: data['institutionLogoUrl'],
      classification: data['classification']?.toString() ?? '',
    );
  }
}

class Certification extends StatefulWidget {
  const Certification({super.key});

  @override
  State<Certification> createState() => _CertificationState();
}

class _CertificationState extends State<Certification> {
  List<CertificationModel> certifications = [];
  List<CertificationModel> filteredCertifications = [];
  List<int> order = [];
  bool isLoading = true;
  String? errorMessage;
  List<String> availableCategories = [];
  String selectedCategory = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadCertifications();
  }

  Future<void> _loadCertifications() async {
    try {
      final [certData, catData] = await Future.wait<dynamic>([
        FirebaseService.fetchCertifications(),
        FirebaseService.fetchCertificationCategories(),
      ]);
      
      if (!mounted) return;
      setState(() {
        certifications = (certData as List<Map<String, dynamic>>)
            .map((e) => CertificationModel.fromMap(e))
            .toList();
        availableCategories = ['Todos', ...(catData as List<String>)];
        order = List.generate(certifications.length, (i) => i);
        filteredCertifications = certifications;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error cargando certificaciones: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  void _filterCertifications() {
    if (selectedCategory == 'Todos') {
      filteredCertifications = certifications;
    } else {
      filteredCertifications = certifications
          .where((cert) => cert.classification == selectedCategory)
          .toList();
    }
  }

  void _selectCategory(String category) {
    setState(() {
      selectedCategory = category;
      _filterCertifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet =
        MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1024;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Primera sección: Título y modelo
            Container(
              margin: const EdgeInsets.only(top: 0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primary],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Modelo 3D Libro
                    Positioned(
                      child: SizedBox(
                        width: isMobile
                            ? MediaQuery.of(context).size.width * 0.8
                            : isTablet
                            ? MediaQuery.of(context).size.width * 0.6
                            : MediaQuery.of(context).size.width * 0.4,
                        height: 300,
                        child: const BookModel(),
                      ),
                    ),
                    // Texto "COURSES"
                    Center(
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        from: 20,
                        child: Text(
                          'COURSES',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFF4F4F4),
                            fontSize: isMobile
                                ? 48
                                : isTablet
                                ? 80
                                : 120,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Segunda sección: Lista de certificaciones
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.light.withOpacity(0.02),
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Encabezado de la sección
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 20 : 40,
                      vertical: 40,
                    ),
                    child: Column(
                      children: [
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: Text(
                            'CERTIFICACIONES Y CURSOS',
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: isMobile ? 24 : 32,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          duration: const Duration(milliseconds: 800),
                          child: Container(
                            width: 60,
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.light.withOpacity(0),
                                  AppColors.light.withOpacity(0.6),
                                  AppColors.light.withOpacity(0),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Filtro de categorías
                  if (!isLoading && certifications.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        duration: const Duration(milliseconds: 700),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(
                              availableCategories.length,
                              (index) {
                                final category = availableCategories[index];
                                final isSelected =
                                    selectedCategory == category;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: GestureDetector(
                                    onTap: () =>
                                        _selectCategory(category),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.light
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: AppColors.light
                                              .withOpacity(
                                            isSelected ? 1 : 0.4,
                                          ),
                                          width: 1.5,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.light,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Contenido de certificaciones
                  if (isLoading)
                    Padding(
                      padding: const EdgeInsets.all(60),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(
                            color: AppColors.light,
                            strokeWidth: 2,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Cargando certificaciones...',
                            style: TextStyle(
                              color: AppColors.light.withOpacity(0.6),
                              fontSize: 16,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text(
                        'Error: $errorMessage',
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else if (filteredCertifications.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(60),
                      child: Text(
                        selectedCategory == 'Todos'
                            ? 'No hay certificaciones disponibles.'
                            : 'No hay certificaciones en esta categoría.',
                        style: TextStyle(
                          color: AppColors.light.withOpacity(0.5),
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 40,
                        vertical: 20,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = isMobile ? 1 : 2;
                          const spacing = 20.0;
                          final cardWidth =
                              (constraints.maxWidth - spacing * (columns - 1)) /
                              columns;
                          return Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: List.generate(
                              filteredCertifications.length,
                              (index) {
                                final cert = filteredCertifications[index];
                                return SizedBox(
                                  width: cardWidth,
                                  child: _CertificationCard(
                                    cert: cert,
                                    isMobile: isMobile,
                                    animationDelay: Duration(
                                      milliseconds: index * 120,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CertificationCard extends StatefulWidget {
  final CertificationModel cert;
  final bool isMobile;
  final Duration animationDelay;

  const _CertificationCard({
    required this.cert,
    required this.isMobile,
    required this.animationDelay,
  });

  @override
  State<_CertificationCard> createState() => _CertificationCardState();
}

class _CertificationCardState extends State<_CertificationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  String _fixGoogleDriveUrl(String url) {
    if (url.isEmpty) return url;
    if (url.contains('alt=media')) return url;
    final regExp = RegExp(r'(?:id=|/d/|/files/)([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount > 0) {
      return GoogleDriveService.downloadUrl(match.group(1)!);
    }
    return url;
  }

  Future<void> _launchLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageWidth = widget.isMobile ? 120.0 : 200.0;
    final cardHeight = widget.isMobile ? 180.0 : 210.0;

    return FadeInUp(
      delay: widget.animationDelay,
      duration: const Duration(milliseconds: 700),
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          _hoverController.forward();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _hoverController.reverse();
        },
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, -(_hoverController.value * 6)),
            child: child,
          ),
          child: GestureDetector(
            onTap: () => context.go('/certification/${widget.cert.id}'),
            child: IntrinsicHeight(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                constraints: BoxConstraints(minHeight: cardHeight),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.82),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.light.withOpacity(
                      _isHovered ? 0.15 : 0.06,
                    ),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_isHovered ? 0.5 : 0.3),
                      blurRadius: _isHovered ? 32 : 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,

                    children: [
                      // ── Imagen izquierda ──
                      SizedBox(
                        width: imageWidth,
                        child: Stack(
                          fit: StackFit.expand,
                          alignment: Alignment.center,
                          children: [
                            widget.cert.imageUrl != null &&
                                    widget.cert.imageUrl!.isNotEmpty
                                ? Image.network(
                                    _fixGoogleDriveUrl(widget.cert.imageUrl!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _PlaceholderImage(
                                          isMobile: widget.isMobile,
                                        ),
                                  )
                                : _PlaceholderImage(isMobile: widget.isMobile),
                            // Degradado derecho para fusión suave con el fondo oscuro
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.55),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Logos en columna en la parte inferior de la imagen
                            Positioned(
                              bottom: 8,
                              left: 0,
                              right: 0,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.cert.platformLogoUrl != null &&
                                      widget.cert.platformLogoUrl!.isNotEmpty)
                                    _SmallLogo(
                                      url: _fixGoogleDriveUrl(
                                        widget.cert.platformLogoUrl!,
                                      ),
                                    ),
                                  if (widget.cert.institutionLogoUrl != null &&
                                      widget
                                          .cert
                                          .institutionLogoUrl!
                                          .isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: _SmallLogo(
                                        url: _fixGoogleDriveUrl(
                                          widget.cert.institutionLogoUrl!,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Contenido derecho ──
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: widget.isMobile ? 14 : 24,
                            vertical: widget.isMobile ? 14 : 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Series + nombre + descripción
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.cert.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.light,
                                      fontSize: widget.isMobile ? 14 : 19,
                                      fontWeight: FontWeight.w800,
                                      height: 1.2,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (widget.cert.series != null &&
                                      widget.cert.series!.isNotEmpty)
                                    Text(
                                      widget.cert.series!.toUpperCase(),
                                      style: TextStyle(
                                        color: AppColors.light.withOpacity(
                                          0.45,
                                        ),
                                        fontSize: widget.isMobile ? 9 : 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 2.5,
                                      ),
                                    ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.cert.description,
                                    maxLines: widget.isMobile ? 2 : 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.light.withOpacity(0.55),
                                      fontSize: widget.isMobile ? 11 : 13,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),

                              // Botón alineado a la derecha
                              Align(
                                alignment: Alignment.centerRight,
                                child:
                                    widget.cert.link != null &&
                                        widget.cert.link!.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () =>
                                            _launchLink(widget.cert.link!),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: widget.isMobile
                                                ? 10
                                                : 16,
                                            vertical: widget.isMobile ? 6 : 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.light,
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
                                          ),
                                          child: Text(
                                            'Certificado',
                                            style: TextStyle(
                                              color: AppColors.black,
                                              fontSize: widget.isMobile
                                                  ? 10
                                                  : 12,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () => context.go(
                                          '/certification/${widget.cert.id}',
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Ver detalles',
                                              style: TextStyle(
                                                color: AppColors.light
                                                    .withOpacity(0.6),
                                                fontSize: widget.isMobile
                                                    ? 10
                                                    : 12,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              color: AppColors.light
                                                  .withOpacity(0.5),
                                              size: 14,
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ), // IntrinsicHeight
          ),
        ),
      ),
    );
  }
}

class _SmallLogo extends StatelessWidget {
  final String url;
  const _SmallLogo({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.verified, size: 16, color: Colors.grey),
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final bool isMobile;
  const _PlaceholderImage({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withOpacity(0.3),
      child: Icon(
        Icons.menu_book_rounded,
        size: isMobile ? 36 : 52,
        color: AppColors.light.withOpacity(0.3),
      ),
    );
  }
}
