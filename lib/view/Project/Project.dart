import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:animate_do/animate_do.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';
import '../../models/RobotModel.dart';

class ProjectCard {
  final String id;
  final String name;
  final String description;
  final int timestamp;

  ProjectCard({
    required this.id,
    required this.name,
    required this.description,
    required this.timestamp,
  });

  factory ProjectCard.fromMap(String id, Map<dynamic, dynamic> data) {
    int timestamp = 0;
    final rawTimestamp = data['timestamp'];
    
    if (rawTimestamp is int) {
      timestamp = rawTimestamp;
    } else if (rawTimestamp is String) {
      try {
        final dateTime = DateTime.parse(rawTimestamp);
        timestamp = dateTime.millisecondsSinceEpoch;
      } catch (e) {
        print('Error parsing timestamp: $e');
        timestamp = 0;
      }
    }
    
    return ProjectCard(
      id: id,
      name: data['name'] ?? 'Sin nombre',
      description: data['description'] ?? '',
      timestamp: timestamp,
    );
  }
}

class Project extends StatefulWidget {
  const Project({Key? key}) : super(key: key);

  @override
  State<Project> createState() => _ProjectState();
}

class _ProjectState extends State<Project> {
  late DatabaseReference _projectsRef;
  List<ProjectCard> cardsData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    try {
      _projectsRef = FirebaseDatabase.instance.ref('Projects');
      _fetchProjects();
    } catch (e) {
      print('Firebase initialization error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _fetchProjects() {
    try {
      _projectsRef.onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          final projects = data.entries
              .map(
                (entry) => ProjectCard.fromMap(
                  entry.key as String,
                  entry.value as Map<dynamic, dynamic>,
                ),
              )
              .toList();
          setState(() {
            cardsData = projects;
            isLoading = false;
          });
        } else {
          setState(() {
            cardsData = [];
            isLoading = false;
          });
        }
      });
    } catch (e) {
      print('Error fetching projects: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
  }

  void _shareProject(ProjectCard card) async {
    try {
      await Share.share(
        'Mira este proyecto: ${card.name}. Este proyecto podría interesarte:',
        subject: 'Mira este proyecto',
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al compartir: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet =
        MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1024;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero Section con modelo 3D
          Container(
            margin: const EdgeInsets.only(top: 0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black.withOpacity(0.2),
                  const Color.fromRGBO(1, 1, 3, 0.1),
                ],
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
                  // Modelo 3D Robot
                  Positioned(
                    child: SizedBox(
                      width: isMobile
                          ? MediaQuery.of(context).size.width * 0.8
                          : isTablet
                          ? MediaQuery.of(context).size.width * 0.6
                          : MediaQuery.of(context).size.width * 0.4,
                      height: 300,
                      child: const RobotModel(),
                    ),
                  ),
                  // Texto "PROJECTS"
                  Center(
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      from: 20,
                      child: Text(
                        'PROJECTS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFFF4F4F4),
                          fontSize: isMobile
                              ? 48
                              : isTablet
                              ? 80
                              : 120,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.5),
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
          // Sección de tarjetas
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: isLoading
                ? const CircularProgressIndicator()
                : cardsData.isEmpty
                ? const SizedBox(
                    height: 200,
                    child: Center(child: Text('No hay proyectos disponibles')),
                  )
                : _buildProjectGrid(isMobile, isTablet),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectGrid(bool isMobile, bool isTablet) {
    int crossAxisCount = isMobile
        ? 1
        : isTablet
        ? 2
        : 3;
    double childAspectRatio = isMobile ? 1.0 : 0.85;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: SlideInLeft(
            duration: const Duration(milliseconds: 600),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: cardsData.length,
              itemBuilder: (context, index) {
                final card = cardsData[index];
                return _buildProjectCard(card, index);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(ProjectCard card, int index) {
    return FadeInUp(
      from: 100,
      delay: Duration(milliseconds: 50 * index),
      duration: const Duration(milliseconds: 600),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFFF4F4F4),
        child: InkWell(
          onTap: () {
            context.go('/project/${card.id}');
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    color: const Color(0xFFF4F4F4),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.name,
                          style: const TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          card.description,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(card.timestamp),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      color: Colors.grey,
                      onPressed: () => _shareProject(card),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
