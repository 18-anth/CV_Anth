import 'package:cv_anth/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cv_anth/widgets/particle_background.dart';
import 'package:cv_anth/models/RobotModel.dart';
import 'package:cv_anth/view/Home/home_tech.dart';
import 'package:cv_anth/utils/asset_paths.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero Section with Particles
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 100),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Particle Background
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                    child: ParticleBackground(
                      particleCount: 50,
                      particleColor: const Color(0xFFF4F4F4),
                      particleSpeed: 1.5,
                    ),
                  ),
                ),

                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.light,
                          AppColors.light,
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                  ),
                ),

                // Main Content
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 60,
                    ),
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 1200),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Profile Image
                          AnimatedBuilder(
                            animation: _floatController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                  0,
                                  _floatController.value * 10 - 5,
                                ),
                                child: child,
                              );
                            },
                            child: Container(
                              width: isMobile ? 250 : 350,
                              height: isMobile ? 250 : 350,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.blackOption.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: Image.asset(
                                  AssetPaths.yoTrajePng,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade300,
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 80,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Title
                          FadeInUp(
                            delay: const Duration(milliseconds: 300),
                            duration: const Duration(milliseconds: 1200),
                            child: Text(
                              'Hi! I\'m Anthony',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isMobile ? 32 : 56,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Subtitle
                          FadeInUp(
                            delay: const Duration(milliseconds: 600),
                            duration: const Duration(milliseconds: 1200),
                            child: Text(
                              'Full Stack Software Developer',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isMobile ? 18 : 28,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87,
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Description
                          FadeInUp(
                            delay: const Duration(milliseconds: 900),
                            duration: const Duration(milliseconds: 1200),
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 600),
                              child: Text(
                                'Passionate about building high-quality, scalable web applications. I specialize in modern JavaScript frameworks, cloud services, and software architecture. Always eager to learn, collaborate, and solve complex technical problems.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black87,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Quote and Robot Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (isMobile) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeInLeft(
                        duration: const Duration(milliseconds: 1000),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Text(
                            '"Code is not just about solving problems, it\'s about crafting experiences."',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      FadeInRight(
                        duration: const Duration(milliseconds: 1000),
                        child: const RobotModel(),
                      ),
                    ],
                  );
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: FadeInLeft(
                          duration: const Duration(milliseconds: 1000),
                          child: Text(
                            '"Code is not just about solving problems, it\'s about crafting experiences."',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                      FadeInRight(
                        duration: const Duration(milliseconds: 1000),
                        child: const RobotModel(),
                      ),
                    ],
                  );
                }
              },
            ),
          ),

          // Tech Stack Section
          FadeInUp(
            duration: const Duration(milliseconds: 1000),
            child: const HomeTech(),
          ),

          // Additional spacing at the bottom
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
