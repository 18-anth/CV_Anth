import 'package:flutter/material.dart';
import '../../utils/Colors.dart';

class ProjectDetailTechnologies extends StatelessWidget {
  final List<dynamic> technologies;
  final Map<String, List<String>> categorized;
  final Map<String, IconData> categoryIcons;

  const ProjectDetailTechnologies({
    super.key,
    required this.technologies,
    required this.categorized,
    required this.categoryIcons,
  });

  @override
  Widget build(BuildContext context) {
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
            color: Colors.black.withValues(alpha: 0.05),
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
                      color: AppColors.black.withValues(alpha: 0.2),
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

          // Categorías en dos columnas (siempre)
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

  Widget _buildCategoryWidget(String category, List<String> techs) {
    final icon = categoryIcons[category] ?? Icons.code;

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
                      color: AppColors.black.withValues(alpha: 0.15),
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
