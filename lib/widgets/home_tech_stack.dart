import 'package:flutter/material.dart';

/// Widget que muestra el stack de tecnologías
/// 
/// Puedes expandir la lista de tecnologías según sea necesario
class HomeTechStack extends StatelessWidget {
  final List<TechItem> techs;

  const HomeTechStack({
    Key? key,
    this.techs = const [
      TechItem(label: 'Flutter', icon: Icons.flutter_dash),
      TechItem(label: 'Dart', icon: Icons.code),
      TechItem(label: 'React', icon: Icons.favorite),
      TechItem(label: 'Node.js', icon: Icons.storage),
      TechItem(label: 'Firebase', icon: Icons.cloud),
      TechItem(label: 'AWS', icon: Icons.cloud_queue),
    ],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        children: [
          const Text(
            'Tech Stack',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: techs.map((tech) => _TechCard(tech: tech)).toList(),
          ),
        ],
      ),
    );
  }
}

class TechItem {
  final String label;
  final IconData icon;
  final String? logo;

  const TechItem({
    required this.label,
    required this.icon,
    this.logo,
  });
}

class _TechCard extends StatefulWidget {
  final TechItem tech;

  const _TechCard({required this.tech});

  @override
  State<_TechCard> createState() => _TechCardState();
}

class _TechCardState extends State<_TechCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Card(
          elevation: _isHovered ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isHovered
                    ? [
                        Colors.deepPurple.shade300,
                        Colors.purple.shade600,
                      ]
                    : [
                        Colors.grey.shade100,
                        Colors.grey.shade200,
                      ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.tech.icon,
                  size: 40,
                  color: _isHovered ? Colors.white : Colors.deepPurple,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.tech.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isHovered ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
