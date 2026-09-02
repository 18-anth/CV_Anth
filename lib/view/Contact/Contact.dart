import 'package:cv_anth/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/ContactModel.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _descriptionController;
  late AnimationController _colorAnimationController;

  final List<Color> pastelColors = [
    Color(0xFFfbb4ae),
    Color(0xFFb3cde3),
    Color(0xFFccebc5),
    Color(0xFFdecbe4),
    Color(0xFFfed9a6),
  ];

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _descriptionController = TextEditingController();

    _colorAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _descriptionController.dispose();
    _colorAnimationController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('No se puede abrir: $url')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al abrir el enlace: $e')));
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mensaje enviado correctamente')),
      );
      _emailController.clear();
      _descriptionController.clear();
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
                  // Modelo 3D Satélite (Contacto)
                  Positioned(
                    child: SizedBox(
                      width: isMobile
                          ? MediaQuery.of(context).size.width * 0.8
                          : isTablet
                          ? MediaQuery.of(context).size.width * 0.6
                          : MediaQuery.of(context).size.width * 0.4,
                      height: 400,
                      child: const ContactModel(),
                    ),
                  ),
                  // Texto "CONTACT ME"
                  Center(
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      from: 20,
                      child: Text(
                        'CONTACT ME',
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

          // Segunda sección: Formulario y redes sociales
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 60,
              vertical: 60,
            ),
            child: isMobile
                ? Column(
                    children: [
                      _buildForm(context, isMobile),
                      const SizedBox(height: 60),
                      _buildContactInfo(context),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildForm(context, isMobile)),
                      const SizedBox(width: 60),
                      Expanded(child: _buildContactInfo(context)),
                    ],
                  ),
          ),

          // Footer
          _buildFooter(context, isMobile),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, bool isMobile) {
    return FadeInLeft(
      duration: const Duration(milliseconds: 800),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SelectableText(
            '¿Tienes un proyecto\nen mente?',
            style: TextStyle(
              color: Color(0xFF050A30),
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const SelectableText(
            'Hablemos y construyamos algo increíble juntos.',
            style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 32),
          // Card formulario
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInput(
                    controller: _emailController,
                    hint: 'tu@email.com',
                    label: 'Correo electrónico',
                    icon: Icons.alternate_email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un correo';
                      }
                      if (!RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                      ).hasMatch(value)) {
                        return 'Correo inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildInput(
                    controller: _descriptionController,
                    hint: 'Cuéntame sobre tu idea...',
                    label: 'Mensaje',
                    icon: Icons.message_outlined,
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor escribe un mensaje';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _AnimatedSendButton(onPressed: _submitForm),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Color(0xFF050A30), fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: const Color(0xFF9c27b0), size: 20),
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF9c27b0), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    final socials = [
      _SocialData(
        icon: Icons.facebook,
        label: 'Facebook',
        handle: 'Anthony Córdova',
        color: const Color(0xFF1877F2),
        url: 'https://www.facebook.com/profile.php?id=100095502885829',
      ),
      _SocialData(
        icon: 'https://cdn-icons-png.flaticon.com/512/15713/15713420.png',
        label: 'Instagram',
        handle: '@thony_cm_18',
        color: const Color(0xFFE1306C),
        url: 'https://www.instagram.com/thony_cm_18/',
      ),
      _SocialData(
        icon: 'https://cdn-icons-png.flaticon.com/512/4423/4423697.png',
        label: 'WhatsApp',
        handle: 'Enviar mensaje',
        color: const Color(0xFF25D366),
        url:
            'https://api.whatsapp.com/qr/FNSLSZHWS3CFM1?autoload=1&app_absent=0',
      ),
      _SocialData(
        icon: 'https://cdn-icons-png.flaticon.com/512/3536/3536505.png',
        label: 'LinkedIn',
        handle: 'Anthony Córdova',
        color: const Color(0xFF0A66C2),
        url: 'https://www.linkedin.com/in/anthony-c-a12928111',
      ),
    ];

    return FadeInRight(
      duration: const Duration(milliseconds: 800),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SelectableText(
            'Conéctate\nconmigo',
            style: TextStyle(
              color: Color(0xFF050A30),
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const SelectableText(
            'También puedes encontrarme en estas plataformas.',
            style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 32),
          ...socials.asMap().entries.map((entry) {
            final i = entry.key;
            final s = entry.value;
            return FadeInRight(
              duration: const Duration(milliseconds: 600),
              delay: Duration(milliseconds: 100 * i),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _SocialCard(data: s, onTap: _launchUrl),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isMobile) {
    const techStack = [
      'Flutter',
      'Dart',
      'Firebase',
      'Node.js',
      'React',
      'Git',
    ];

    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 60,
        vertical: 40,
      ),
      child: Column(
        children: [
          // Tech stack tags
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: techStack.map((tech) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.blackOption.withValues(alpha: 0.15),
                  ),
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.blackOption.withValues(alpha: 0.05),
                ),
                child: Text(
                  tech,
                  style: TextStyle(
                    color: AppColors.blackOption.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          // Divider degradado
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withValues(alpha: 0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Nombre + copyright
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Anthony',
                      style: TextStyle(
                        color: AppColors.blackOption.withValues(alpha: 0.9),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    TextSpan(
                      text: '.dev',
                      style: const TextStyle(
                        color: Color(0xFF9c27b0),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '©2026 — Full Stack Developer',
                style: TextStyle(
                  color: AppColors.blackOption.withValues(alpha: 0.35),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Modelo de datos para redes sociales ───
class _SocialData {
  final dynamic icon; // Puede ser IconData o String (URL)
  final String label;
  final String handle;
  final Color color;
  final String url;

  const _SocialData({
    required this.icon,
    required this.label,
    required this.handle,
    required this.color,
    required this.url,
  });
}

// ─── Tarjeta de red social ───
class _SocialCard extends StatefulWidget {
  final _SocialData data;
  final Future<void> Function(String) onTap;

  const _SocialCard({required this.data, required this.onTap});

  @override
  State<_SocialCard> createState() => _SocialCardState();
}

class _SocialCardState extends State<_SocialCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(_hovered ? -6 : 0, 0, 0),
        child: GestureDetector(
          onTap: () => widget.onTap(widget.data.url),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _hovered
                    ? widget.data.color.withValues(alpha: 0.4)
                    : Colors.grey[200]!,
              ),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: widget.data.color.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: widget.data.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: widget.data.icon is IconData
                      ? Icon(
                          widget.data.icon,
                          color: widget.data.color,
                          size: 22,
                        )
                      : Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.data.icon,
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.link,
                                  color: widget.data.color,
                                  size: 22,
                                );
                              },
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.data.label,
                        style: const TextStyle(
                          color: Color(0xFF050A30),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        widget.data.handle,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: _hovered ? widget.data.color : Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Botón de envío animado ───
class _AnimatedSendButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _AnimatedSendButton({required this.onPressed});

  @override
  State<_AnimatedSendButton> createState() => _AnimatedSendButtonState();
}

class _AnimatedSendButtonState extends State<_AnimatedSendButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _hovered
                ? [const Color(0xFF7B1FA2), const Color(0xFF9c27b0)]
                : [const Color(0xFF9c27b0), const Color(0xFFAB47BC)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: const Color(0xFF9c27b0).withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Enviar mensaje',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedSlide(
                    duration: const Duration(milliseconds: 200),
                    offset: _hovered ? const Offset(0.3, 0) : Offset.zero,
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
