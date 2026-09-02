// ignore_for_file: file_names

import 'package:cv_anth/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/AvatarAbstractoModel.dart';

class AboutMe extends StatefulWidget {
  const AboutMe({super.key});

  @override
  State<AboutMe> createState() => _AboutMeState();
}

class _AboutMeState extends State<AboutMe> {
  final List<String> skills = [
    "Responsible",
    "Committed",
    "Respectful",
    "Loyal to my principles",
    "Sociable",
    "Creative",
    "Leadership",
    "Teamwork",
  ];

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
                    color: Colors.black.withValues(alpha: 0.5),
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
                    // Modelo 3D Avatar Abstracto
                    Positioned(
                      child: SizedBox(
                        width: isMobile
                            ? MediaQuery.of(context).size.width * 0.8
                            : isTablet
                            ? MediaQuery.of(context).size.width * 0.6
                            : MediaQuery.of(context).size.width * 0.4,
                        height: 400,
                        child: const AvatarAbstractoModel(),
                      ),
                    ),
                    // Texto "ABOUT ME"
                    Center(
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        from: 20,
                        child: Text(
                          'ABOUT ME',
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
                                color: Colors.black.withValues(alpha: 0.5),
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

            // Segunda sección: Contenido
            Container(
              margin: const EdgeInsets.only(top: 40),
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primary, AppColors.primary],
                ),
              ),
              child: Column(
                children: [
                  // Título de sección
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: Column(
                      children: [
                        Text(
                          'MY EXPERTISE',
                          style: TextStyle(
                            fontSize: isMobile ? 32 : 42,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1a1a1a),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 80,
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF9c27b0), Color(0xFF673ab7)],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Grid con cards principales - Responsive Layout
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Determinar ancho de columna según el ancho disponible
                      double cardWidth;
                      if (constraints.maxWidth < 600) {
                        // Móvil: 1 columna - ancho completo
                        cardWidth = constraints.maxWidth;
                      } else if (constraints.maxWidth < 1200) {
                        // Tablet: 2 columnas
                        cardWidth = (constraints.maxWidth - 32) / 2;
                      } else {
                        // Desktop: 2 columnas
                        cardWidth = (constraints.maxWidth - 32) / 2;
                      }

                      return Wrap(
                        spacing: 32,
                        runSpacing: 32,
                        alignment: WrapAlignment.center,
                        children: [
                          SizedBox(
                            width: cardWidth,
                            child: _buildWhoAmICard(0),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _buildHobbiesCard(1),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _buildSkillsCard(2),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _buildAcademicCard(3),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhoAmICard(int index) {
    return FadeInUp(
      duration: const Duration(milliseconds: 700),
      delay: Duration(milliseconds: 100 + (index * 150)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.white],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF9c27b0).withValues(alpha: 0.08),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF9c27b0), Color(0xFF673ab7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 20),
              Text(
                'Who am I?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1a1a1a),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF9c27b0), Color(0xFF673ab7)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              SelectableText(
                "I'm passionate about technology. I love programming so much that it sometimes feels like an obsession. I enjoy solving problems, creating innovative solutions, and collaborating on projects that challenge my skills.",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHobbiesCard(int index) {
    return FadeInUp(
      duration: const Duration(milliseconds: 700),
      delay: Duration(milliseconds: 100 + (index * 150)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey.shade50],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF9c27b0).withValues(alpha: 0.08),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF9c27b0), Color(0xFF673ab7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.favorite, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 20),
              Text(
                'Hobbies',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1a1a1a),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF9c27b0), Color(0xFF673ab7)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildHobbyChip('Soccer', Icons.sports_soccer, Colors.blue),
                  _buildHobbyChip(
                    'Motorbiking',
                    Icons.two_wheeler,
                    Colors.pink,
                  ),
                  _buildHobbyChip('Coding', Icons.code, Colors.green),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHobbyChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsCard(int index) {
    return FadeInUp(
      duration: const Duration(milliseconds: 700),
      delay: Duration(milliseconds: 100 + (index * 150)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.white],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF9c27b0).withValues(alpha: 0.08),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF9c27b0), Color(0xFF673ab7)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.star, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Professional Skills',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1a1a1a),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF9c27b0), Color(0xFF673ab7)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: skills
                    .asMap()
                    .entries
                    .map(
                      (entry) => FadeInUp(
                        delay: Duration(milliseconds: 200 + (entry.key * 80)),
                        duration: const Duration(milliseconds: 600),
                        child: _buildSkillChip(entry.value),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9c27b0).withValues(alpha: 0.12),
            Color(0xFF673ab7).withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Color(0xFF9c27b0).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF9c27b0).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        skill,
        style: TextStyle(
          color: Color(0xFF464646),
          fontWeight: FontWeight.w700,
          fontSize: 14,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildAcademicCard(int index) {
    return FadeInUp(
      duration: const Duration(milliseconds: 700),
      delay: Duration(milliseconds: 100 + (index * 150)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.white],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF9c27b0).withValues(alpha: 0.08),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF9c27b0), Color(0xFF673ab7)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.school, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Academic Journey',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1a1a1a),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF9c27b0), Color(0xFF673ab7)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 28),
              // Education Timeline
              _buildEnhancedTimelineItem(
                title: 'Unidad Educativa Santa Mariana de Jesús',
                subtitle: 'High School Diploma in Science',
                period: '2005 - 2019',
                icon: Icons.school,
                color: Colors.pink,
                isFirst: true,
              ),
              _buildTimelineConnector(),
              _buildEnhancedTimelineItem(
                title: 'University of Guayaquil',
                subtitle: 'B.S. in Information Systems Engineering',
                period: '8th Semester (2019 - 2025)',
                icon: Icons.apartment,
                color: Colors.blue,
                isLast: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedTimelineItem({
    required String title,
    required String subtitle,
    required String period,
    required IconData icon,
    required Color color,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 12),
            ),
          ],
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              SelectableText(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9c27b0),
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 6),
              SelectableText(
                period,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineConnector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 8,
            child: Center(
              child: Container(width: 2, height: 24, color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }
}
