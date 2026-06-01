import 'package:flutter/material.dart';
import '../../utils/Colors.dart';

class ProjectDetailInfoSlider extends StatefulWidget {
  final String? problemSolved;
  final String? difficulties;
  final String? testimonials;
  final String? responsibilities;

  const ProjectDetailInfoSlider({
    super.key,
    this.problemSolved,
    this.difficulties,
    this.testimonials,
    this.responsibilities,
  });

  @override
  State<ProjectDetailInfoSlider> createState() =>
      _ProjectDetailInfoSliderState();
}

class _ProjectDetailInfoSliderState extends State<ProjectDetailInfoSlider> {
  late final PageController _infoPageController;
  int _currentInfoIndex = 0;

  @override
  void initState() {
    super.initState();
    _infoPageController = PageController();
  }

  @override
  void dispose() {
    _infoPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> infoSections = [];

    if (widget.problemSolved != null && widget.problemSolved!.isNotEmpty) {
      infoSections.add({
        'title': 'Problema que resuelve',
        'icon': Icons.lightbulb_outline,
        'content': widget.problemSolved,
        'color': AppColors.black,
        'gradient': [AppColors.black, AppColors.blackOption],
      });
    }

    if (widget.difficulties != null && widget.difficulties!.isNotEmpty) {
      infoSections.add({
        'title': 'Dificultades y soluciones',
        'icon': Icons.engineering,
        'content': widget.difficulties,
        'color': AppColors.black,
        'gradient': [AppColors.black, AppColors.blackOption],
      });
    }

    if (widget.testimonials != null && widget.testimonials!.isNotEmpty) {
      infoSections.add({
        'title': 'Testimonios o feedback',
        'icon': Icons.rate_review,
        'content': widget.testimonials,
        'color': AppColors.black,
        'gradient': [AppColors.black, AppColors.blackOption],
      });
    }

    if (widget.responsibilities != null &&
        widget.responsibilities!.isNotEmpty) {
      infoSections.add({
        'title': 'Responsabilidades',
        'icon': Icons.assignment_ind,
        'content': widget.responsibilities,
        'color': AppColors.black,
        'gradient': [AppColors.black, AppColors.blackOption],
      });
    }

    if (infoSections.isEmpty) {
      return const SizedBox.shrink();
    }

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.light5,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con título y contador
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Información del Proyecto',
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentInfoIndex + 1}/${infoSections.length}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // PageView con las secciones
          SizedBox(
            height: isMobile ? 280 : 250,
            child: PageView.builder(
              controller: _infoPageController,
              onPageChanged: (index) {
                setState(() {
                  _currentInfoIndex = index;
                });
              },
              itemCount: infoSections.length,
              itemBuilder: (context, index) {
                final section = infoSections[index];
                return _buildInfoSlide(
                  title: section['title'],
                  icon: section['icon'],
                  content: section['content'],
                  color: section['color'],
                  gradient: section['gradient'],
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Controles de navegación
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botón Anterior
              _buildNavigationButton(
                icon: Icons.arrow_back_ios_rounded,
                onPressed: _currentInfoIndex > 0
                    ? () {
                        _infoPageController.previousPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
                isEnabled: _currentInfoIndex > 0,
              ),

              // Indicadores de página (dots)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    infoSections.length,
                    (index) => _buildPageIndicator(
                      isActive: index == _currentInfoIndex,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),

              // Botón Siguiente
              _buildNavigationButton(
                icon: Icons.arrow_forward_ios_rounded,
                onPressed: _currentInfoIndex < infoSections.length - 1
                    ? () {
                        _infoPageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
                isEnabled: _currentInfoIndex < infoSections.length - 1,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSlide({
    required String title,
    required IconData icon,
    required String content,
    required Color color,
    required List<Color> gradient,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, AppColors.light5],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey.withOpacity(0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con icono y título
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Contenido
            SelectableText(
              content,
              style: TextStyle(
                color: AppColors.darkgrey,
                fontSize: 15,
                height: 1.6,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isEnabled,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isEnabled
            ? LinearGradient(
                colors: [AppColors.black, AppColors.black.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isEnabled ? null : AppColors.grey.withOpacity(0.3),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: isEnabled ? AppColors.primary : AppColors.darkgrey,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator({required bool isActive, required Color color}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? color : AppColors.grey.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
    );
  }
}
