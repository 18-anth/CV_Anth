import 'package:cv_anth/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class TechItem {
  final String name;
  final IconData icon;
  final Color color;

  TechItem({required this.name, required this.icon, required this.color});
}

class HomeTech extends StatefulWidget {
  const HomeTech({super.key});

  @override
  State<HomeTech> createState() => _HomeTechState();
}

class _HomeTechState extends State<HomeTech> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<TechItem> techStack = [
    TechItem(
      name: 'React',
      icon: Icons.flutter_dash,
      color: const Color(0xFF61DBFB),
    ),
    TechItem(
      name: 'Flutter',
      icon: Icons.flutter_dash,
      color: const Color(0xFF02569B),
    ),
    TechItem(name: 'Node.js', icon: Icons.dns, color: const Color(0xFF68A063)),
    TechItem(
      name: 'Express',
      icon: Icons.terminal,
      color: const Color(0xFF000000),
    ),
    TechItem(
      name: 'TypeScript',
      icon: Icons.code,
      color: const Color(0xFF3178C6),
    ),
    TechItem(
      name: 'MongoDB',
      icon: Icons.storage,
      color: const Color(0xFF47A248),
    ),
    TechItem(
      name: 'PostgreSQL',
      icon: Icons.table_chart,
      color: const Color(0xFF336791),
    ),
    TechItem(
      name: 'Docker',
      icon: Icons.layers,
      color: const Color(0xFF2496ED),
    ),
    TechItem(name: 'Git', icon: Icons.source, color: const Color(0xFFF05032)),
    TechItem(name: 'AWS', icon: Icons.cloud, color: const Color(0xFFFF9900)),
    TechItem(
      name: 'Firebase',
      icon: Icons.cloud,
      color: const Color(0xFFFFCB2B),
    ),
    TechItem(
      name: 'Python',
      icon: Icons.terminal,
      color: const Color(0xFF3776AB),
    ),
    TechItem(
      name: 'JavaScript',
      icon: Icons.code,
      color: const Color(0xFFF7DF1E),
    ),
  ];

  List<List<TechItem>> _chunkArray(List<TechItem> arr, int size) {
    final List<List<TechItem>> chunks = [];
    for (int i = 0; i < arr.length; i += size) {
      chunks.add(arr.sublist(i, i + size > arr.length ? arr.length : i + size));
    }
    return chunks;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.grey,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          children: [
            // Title
            Text(
              'Technologies I Work With',
              style: TextStyle(
                fontSize: isMobile ? 24 : 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Tech Stack Grid/Carousel
            if (isMobile) _buildMobileCarousel() else _buildDesktopGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileCarousel() {
    final chunks = _chunkArray(techStack, 4);
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        // Page View
        SizedBox(
          height: 280,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            children: chunks.map((group) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  height: 280,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 16,
                    children: group.map((tech) {
                      return SizedBox(
                        width: (screenWidth - 56) / 2,
                        child: _buildTechCard(tech),
                      );
                    }).toList(),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 24),

        // Page Indicators and Navigation
        Column(
          children: [
            // Page Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                chunks.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: index == _currentPage ? 13 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: index == _currentPage
                        ? const Color(0xFF555555)
                        : const Color(0xFFDDDDDD),
                    boxShadow: index == _currentPage
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                            ),
                          ]
                        : [],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _currentPage > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _currentPage > 0
                              ? const Color(0xFF333333)
                              : const Color(0xFFCCCCCC),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                        color: _currentPage > 0
                            ? const Color(0xFF333333)
                            : const Color(0xFFCCCCCC),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Next Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _currentPage < chunks.length - 1
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _currentPage < chunks.length - 1
                              ? const Color(0xFF333333)
                              : const Color(0xFFCCCCCC),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 20,
                        color: _currentPage < chunks.length - 1
                            ? const Color(0xFF333333)
                            : const Color(0xFFCCCCCC),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopGrid() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 24,
      runSpacing: 24,
      children: techStack.map((tech) {
        return SizedBox(width: 180, child: _buildTechCard(tech));
      }).toList(),
    );
  }

  Widget _buildTechCard(TechItem tech) {
    return _TechCardWidget(tech: tech);
  }
}

class _TechCardWidget extends StatefulWidget {
  final TechItem tech;

  const _TechCardWidget({required this.tech});

  @override
  State<_TechCardWidget> createState() => _TechCardWidgetState();
}

class _TechCardWidgetState extends State<_TechCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleHoverChange(bool isHovered) {
    if (isHovered) {
      _scaleController.forward();
    } else {
      _scaleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHoverChange(true),
      onExit: (_) => _handleHoverChange(false),
      child: GestureDetector(
        onTapDown: (_) => _handleHoverChange(true),
        onTapUp: (_) => _handleHoverChange(false),
        onTapCancel: () => _handleHoverChange(false),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(scale: _scaleAnimation.value, child: child);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: widget.tech.color.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon with color background
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.tech.color.withOpacity(0.1),
                        ),
                        child: Icon(
                          widget.tech.icon,
                          size: 40,
                          color: widget.tech.color,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tech Name
                      Text(
                        widget.tech.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
