import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/ContactModel.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Abriendo: $url')));
    // TODO: Implementar url_launcher cuando se agregue el paquete
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
                  // Modelo 3D Satélite (Contacto)
                  Positioned(
                    child: SizedBox(
                      width: isMobile
                          ? MediaQuery.of(context).size.width * 0.8
                          : isTablet
                          ? MediaQuery.of(context).size.width * 0.6
                          : MediaQuery.of(context).size.width * 0.4,
                      height: 300,
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

          // Segunda sección: Formulario y redes sociales
          Container(
            height: MediaQuery.of(context).size.height * 1.2,
            color: Colors.white,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Formulario
                    FadeInLeft(
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(milliseconds: 200),
                      child: Card(
                        elevation: 8,
                        shadowColor: Colors.black45,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          width: isMobile ? 350 : 400,
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Text(
                                  'Escríbeme',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    hintText: 'Correo electrónico',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.all(12),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa un correo';
                                    }
                                    if (!RegExp(
                                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                    ).hasMatch(value)) {
                                      return 'Por favor ingresa un correo válido';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _descriptionController,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintText: 'Escribe una descripción',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.all(12),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa una descripción';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _submitForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF9c27b0),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Enviar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Redes sociales
                    FadeIn(
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(milliseconds: 400),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SocialIconButton(
                            icon: Icons.facebook,
                            color: Colors.blue,
                            url:
                                'https://www.facebook.com/profile.php?id=100095502885829',
                            onTap: _launchUrl,
                          ),
                          const SizedBox(width: 20),
                          _SocialIconButton(
                            icon: Icons.photo_camera,
                            color: Color(0xFFdc2743),
                            url: 'https://www.instagram.com/thony_cm_18/',
                            onTap: _launchUrl,
                          ),
                          const SizedBox(width: 20),
                          _SocialIconButton(
                            icon: Icons.chat,
                            color: Colors.green,
                            url:
                                'https://api.whatsapp.com/qr/FNSLSZHWS3CFM1?autoload=1&app_absent=0',
                            onTap: _launchUrl,
                          ),
                          const SizedBox(width: 20),
                          _SocialIconButton(
                            icon: Icons.business,
                            color: Colors.blue,
                            url:
                                'https://www.linkedin.com/in/anthony-c-a12928111/',
                            onTap: _launchUrl,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Divider
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: 2,
                      color: Color(0xFF9c27b0),
                    ),
                    const SizedBox(height: 20),

                    // Footer
                    Text(
                      '©2024 ANTHONY CORDOVA - Todos los Derechos Reservados',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF050A30), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String url;
  final Function(String) onTap;

  const _SocialIconButton({
    required this.icon,
    required this.color,
    required this.url,
    required this.onTap,
  });

  @override
  State<_SocialIconButton> createState() => _SocialIconButtonState();
}

class _SocialIconButtonState extends State<_SocialIconButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        iconSize: 50,
        icon: Icon(widget.icon),
        color: widget.color,
        onPressed: () {
          _scaleController.forward().then((_) {
            _scaleController.reverse();
          });
          widget.onTap(widget.url);
        },
        splashColor: widget.color.withOpacity(0.2),
        onHover: (isHovering) {
          if (isHovering) {
            _scaleController.forward();
          } else {
            _scaleController.reverse();
          }
        },
      ),
    );
  }
}
