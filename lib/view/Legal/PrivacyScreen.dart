// ignore_for_file: file_names

import 'package:cv_anth/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final Set<int> _expandedSections = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      appBar: AppBar(
        backgroundColor: AppColors.light,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blackOption),
          onPressed: () => context.go('/'),
        ),
        title: const Text(
          'Privacy Policy | CV { Anth }',
          style: TextStyle(
            color: AppColors.blackOption,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    _buildHeaderSection(),
                    const SizedBox(height: 32),

                    // Introduction Card
                    _buildAnimatedCard(
                      0,
                      'Introducción',
                      Icons.shield_outlined,
                      'Esta Política de Privacidad explica cómo recopilamos, utilizamos y protegemos la información que proporcionas al usar nuestro sitio. Tu privacidad es importante para nosotros.',
                    ),
                    const SizedBox(height: 16),

                    // Information Collection
                    _buildExpandableSection(
                      1,
                      'Información que Recopilamos',
                      Icons.storage_outlined,
                      [
                        '👤 Tu nombre',
                        '📧 Tu dirección de correo electrónico',
                        '💬 El contenido de tu mensaje',
                        '🕐 Información técnica (IP, navegador, tipo de dispositivo)',
                        '📍 Datos de localización (opcional)',
                        '🔗 Historial de navegación en el sitio',
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Legal Basis
                    _buildExpandableSection(
                      2,
                      'Base Jurídica para la Recopilación',
                      Icons.gavel_outlined,
                      [
                        '✅ Consentimiento del usuario (Artículo 6.1.a GDPR)',
                        '✅ Contrato de servicios (Artículo 6.1.b GDPR)',
                        '✅ Obligación legal (Artículo 6.1.c GDPR)',
                        '✅ Intereses legítimos (Artículo 6.1.f GDPR)',
                        '✅ Protección de datos personales (Artículo 6.1.e GDPR)',
                      ],
                    ),
                    const SizedBox(height: 16),

                    // How We Collect Data
                    _buildExpandableSection(
                      3,
                      'Cómo Recopilamos Información',
                      Icons.cloud_download_outlined,
                      [
                        '🍪 Cookies de sesión (esenciales)',
                        '🔐 Cookies de autenticación',
                        '📊 Cookies de análisis (Google Analytics)',
                        '🔗 Firebase Authentication',
                        '💾 Almacenamiento local (localStorage)',
                        '📱 Datos del formulario de contacto',
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Data Usage
                    _buildExpandableSection(
                      4,
                      'Cómo Usamos Tus Datos',
                      Icons.trending_up_outlined,
                      [
                        '✉️ Para responder a tus consultas',
                        '🔐 Para autenticación y seguridad',
                        '📈 Para mejorar nuestra experiencia de usuario',
                        '📊 Para análisis estadísticos',
                        '🛡️ Para prevenir fraude y abuso',
                        '📬 Para comunicaciones esenciales del servicio',
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Third Parties
                    _buildExpandableSection(
                      5,
                      'Terceros y Compartición de Datos',
                      Icons.people_outlined,
                      [
                        '🔹 Google Firebase: Autenticación y almacenamiento',
                        '🔹 Google Analytics: Análisis de tráfico',
                        '🔹 Vercel: Hosting y CDN',
                        '🔹 No vendemos ni compartimos datos personales',
                        '🔹 Solo compartimos con proveedores necesarios para operar el servicio',
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Data Retention
                    _buildExpandableSection(
                      6,
                      'Tiempo de Retención de Datos',
                      Icons.schedule_outlined,
                      [
                        '⏱️ Mensajes de contacto: 2 años (cumplimiento legal)',
                        '⏱️ Datos de sesión: 30 días después del último acceso',
                        '⏱️ Cookies de análisis: 2 años',
                        '⏱️ Datos de autenticación: Mientras la cuenta esté activa',
                        '⏱️ Logs de acceso: 90 días',
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Data Security
                    _buildAnimatedCard(
                      7,
                      'Seguridad de Datos',
                      Icons.lock_outlined,
                      'Implementamos medidas técnicas y administrativas apropiadas para proteger tus datos personales, incluyendo encriptación SSL/TLS, autenticación de dos factores y auditorías de seguridad regulares.',
                    ),
                    const SizedBox(height: 16),

                    // User Rights
                    _buildExpandableSection(
                      8,
                      'Tus Derechos de Protección de Datos',
                      Icons.verified_user_outlined,
                      [
                        '📋 Derecho de Acceso: Solicitar copia de tus datos',
                        '✏️ Derecho de Rectificación: Corregir datos inexactos',
                        '🗑️ Derecho de Olvido: Solicitar eliminación de datos',
                        '⛔ Derecho de Restricción: Limitar el procesamiento',
                        '📤 Derecho de Portabilidad: Obtener datos en formato transferible',
                        '🚫 Derecho de Objeción: Oponerser al procesamiento',
                      ],
                    ),
                    const SizedBox(height: 16),

                    // DSAR Form
                    _buildAnimatedCard(
                      9,
                      'Solicitud de Acceso del Interesado (DSAR)',
                      Icons.article_outlined,
                      'Puedes presentar una solicitud DSAR en cualquier momento a través del formulario de contacto de nuestro sitio. Responderemos dentro de 30 días hábiles como requiere la ley.',
                    ),
                    const SizedBox(height: 16),

                    // Regulations
                    _buildRegulationsSection(),
                    const SizedBox(height: 16),

                    // Cookies Policy
                    _buildExpandableSection(
                      10,
                      'Política de Cookies',
                      Icons.cookie_outlined,
                      [
                        '🔐 Cookies Esenciales: Requeridas para funcionalidad',
                        '📊 Cookies de Análisis: Para entender el uso del sitio',
                        '⚙️ Cookies de Preferencia: Para recordar tus configuraciones',
                        '📢 Cookies de Marketing: Deshabilitadas por defecto',
                        '🔧 Puedes gestionar preferencias de cookies en cualquier momento',
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Consent Management
                    _buildAnimatedCard(
                      11,
                      'Gestión del Consentimiento',
                      Icons.check_circle_outlined,
                      'Implementamos un banner de consentimiento claro que te permite aceptar o rechazar cookies no esenciales. Puedes cambiar tus preferencias en cualquier momento desde el Centro de Preferencias de Consentimiento.',
                    ),
                    const SizedBox(height: 16),

                    // Do Not Sell Link
                    _buildAnimatedCard(
                      12,
                      'No Vender Mis Datos Personales',
                      Icons.block_outlined,
                      'De conformidad con la CCPA, no vendemos ni compartimos tus datos personales. Puedes ejercer este derecho en cualquier momento contactándonos directamente.',
                    ),
                    const SizedBox(height: 16),

                    // Data Processing Agreement
                    _buildAnimatedCard(
                      13,
                      'Acuerdo de Tratamiento de Datos (DPA)',
                      Icons.assignment_outlined,
                      'Mantenemos acuerdos de tratamiento de datos con todos nuestros proveedores de servicios para garantizar que tus datos se manejen con los más altos estándares de seguridad y privacidad.',
                    ),
                    const SizedBox(height: 16),

                    // Updates
                    _buildAnimatedCard(
                      14,
                      'Cambios en esta Política',
                      Icons.update_outlined,
                      'Podemos actualizar esta política de privacidad de vez en cuando. Los cambios entrarán en vigor inmediatamente después de su publicación. Continuando el uso del sitio aceptas los cambios.',
                    ),
                    const SizedBox(height: 16),

                    // Contact
                    _buildAnimatedCard(
                      15,
                      'Contacto',
                      Icons.mail_outlined,
                      'Si tienes preguntas sobre esta Política de Privacidad, por favor usa la sección de Contacto de nuestro sitio o envía un correo a anthonycordova330@gmail.com',
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.blackOption.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.blackOption.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.blackOption.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.privacy_tip_outlined,
                  color: AppColors.blackOption,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Política de Privacidad',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blackOption,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Última actualización: 28 de abril de 2026',
                      style: TextStyle(
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
        ],
      ),
    );
  }

  Widget _buildAnimatedCard(
    int index,
    String title,
    IconData icon,
    String body,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 50)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.blackOption.withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackOption.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.blackOption.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          icon,
                          color: AppColors.blackOption,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blackOption,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    body,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.darkgrey,
                      height: 1.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandableSection(
    int index,
    String title,
    IconData icon,
    List<String> items,
  ) {
    final isExpanded = _expandedSections.contains(index);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 50)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.blackOption.withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackOption.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_expandedSections.contains(index)) {
                          _expandedSections.remove(index);
                        } else {
                          _expandedSections.add(index);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.blackOption.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              icon,
                              color: AppColors.blackOption,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.blackOption,
                              ),
                            ),
                          ),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              Icons.expand_more,
                              color: AppColors.blackOption,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 1,
                            color: AppColors.blackOption.withValues(alpha: 0.1),
                            margin: const EdgeInsets.only(bottom: 16),
                          ),
                          ...List.generate(
                            items.length,
                            (itemIndex) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    items[itemIndex].substring(0, 1),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.blackOption,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      items[itemIndex].substring(1),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.darkgrey,
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    crossFadeState: isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegulationsSection() {
    const regulations = [
      ('GDPR', '🇪🇺', 'Unión Europea'),
      ('UK GDPR', '🇬🇧', 'Reino Unido'),
      ('CCPA', '🇺🇸', 'California'),
      ('CDPA', '🇺🇸', 'Virginia'),
      ('LGPD', '🇧🇷', 'Brasil'),
      ('PIPEDA', '🇨🇦', 'Canadá'),
      ('Privacy Act', '🇦🇺', 'Australia'),
      ('POPIA', '🇿🇦', 'Sudáfrica'),
    ];

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.blackOption.withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackOption.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.blackOption.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.public_outlined,
                          color: AppColors.blackOption,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Leyes y Regulaciones Aplicables',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blackOption,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(regulations.length, (index) {
                      final (name, flag, country) = regulations[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.blackOption.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.blackOption.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(flag, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.blackOption,
                                  ),
                                ),
                                Text(
                                  country,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.darkgrey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
