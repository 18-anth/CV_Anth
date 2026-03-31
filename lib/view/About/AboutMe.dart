import 'package:cv_anth/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/AvatarAbstractoModel.dart';

class AboutMe extends StatefulWidget {
  const AboutMe({Key? key}) : super(key: key);

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
      backgroundColor: Colors.white,
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
                  colors: [AppColors.light, AppColors.light],
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
                    // Modelo 3D Avatar Abstracto
                    Positioned(
                      child: SizedBox(
                        width: isMobile
                            ? MediaQuery.of(context).size.width * 0.8
                            : isTablet
                            ? MediaQuery.of(context).size.width * 0.6
                            : MediaQuery.of(context).size.width * 0.4,
                        height: 300,
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

            // Segunda sección: Contenido
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              child: FadeInLeft(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    // Grid con cards principales
                    if (!isMobile)
                      Column(
                        children: [
                          // Row 1: Who am I + Hobbies
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Who am I Card
                              Expanded(child: _buildWhoAmICard()),
                              const SizedBox(width: 24),
                              // Hobbies Card
                              Expanded(child: _buildHobbiesCard()),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Row 2: Skills
                          _buildSkillsCard(),
                          const SizedBox(height: 24),
                          // Row 3: Academic Background
                          _buildAcademicCard(),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildWhoAmICard(),
                          const SizedBox(height: 24),
                          _buildHobbiesCard(),
                          const SizedBox(height: 24),
                          _buildSkillsCard(),
                          const SizedBox(height: 24),
                          _buildAcademicCard(),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhoAmICard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Who am I?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Color(0xFF464646),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "I'm passionate about technology. I love programming so much that it sometimes feels like an obsession. I enjoy solving problems, creating innovative solutions, and collaborating on projects that challenge my skills.",
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHobbiesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Hobbies',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Color(0xFF464646),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                Chip(
                  avatar: Icon(Icons.sports_soccer),
                  label: Text('Soccer'),
                  backgroundColor: Colors.blue.shade100,
                ),
                Chip(
                  avatar: Icon(Icons.two_wheeler),
                  label: Text('Motorbiking'),
                  backgroundColor: Colors.pink.shade100,
                ),
                Chip(
                  avatar: Icon(Icons.code),
                  label: Text('Coding'),
                  backgroundColor: Colors.green.shade100,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Skills',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Color(0xFF464646),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: skills
                  .map(
                    (skill) => Chip(
                      label: Text(skill),
                      side: BorderSide(color: Color(0xFF9c27b0), width: 1),
                      labelStyle: TextStyle(
                        color: Color(0xFF464646),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Academic Background',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Color(0xFF464646),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Education Timeline
            _buildTimelineItem(
              title: 'Unidad Educativa Santa Mariana de Jesús',
              subtitle: 'High School Diploma in Science (2005 - 2019)',
              isFirst: true,
              color: Colors.pink,
            ),
            _buildTimelineConnector(),
            _buildTimelineItem(
              title: 'University of Guayaquil',
              subtitle:
                  'B.S. in Information Systems Engineering – 8th Semester (2019 - 2025)',
              isLast: true,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
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
              width: 16,
              height: 16,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
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
