// ignore_for_file: file_names

import 'package:cv_anth/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  final List<bool> _expandedSections = [];

  final List<Map<String, String>> _sections = [
    {
      'title': 'Especificaciones de la Página Web',
      'content':
          'El sitio web tiene como finalidad brindar un canal de comunicación institucional, acceso a contenidos académicos y administrativos, así como servicios de gestión educativa.\n\n'
          'Las plataformas digitales buscan optimizar los procesos institucionales, garantizar una experiencia de navegación eficiente, segura, accesible e inclusiva.\n\n'
          'Este portal es de propiedad exclusiva y todos los contenidos, estructura, diseño, imágenes, software, marcas y logotipos están protegidos por derechos de propiedad intelectual.',
    },
    {
      'title': 'Condiciones de Acceso y Utilización',
      'content':
          'El uso de la página web es gratuito. Como Usuario, usted se obliga a utilizar nuestras herramientas respetando la normativa vigente.\n\n'
          'Está prohibido utilizar la página web con fines ilícitos o que pudieran afectar a terceros.\n\n'
          'Se prohíben tecnologías que puedan dañar, inutilizar o sobrecargar los servicios ofrecidos.',
    },
    {
      'title': 'Correcto Uso de la Página Web',
      'content':
          '✓ Mantener en buen estado los sistemas sin afectarlos\n'
          '✓ No reproducir ni comercializar contenidos\n'
          '✓ No interferir en el acceso y funcionamiento\n'
          '✓ Cargar solo documentos en formatos soportados\n'
          '✓ No cargar archivos con malware o código dañino\n\n'
          'En caso de incumplimiento, se podrán interponer acciones legales pertinentes.',
    },
    {
      'title': 'Responsabilidad de los Usuarios',
      'content':
          'Deberá hacer un uso adecuado de las herramientas disponibles:\n\n'
          '• No ingresar contenidos ilícitos\n'
          '• No vulnerar derechos de autor\n'
          '• Evitar acciones que comprometan la seguridad\n'
          '• Utilizar formatos permitidos para carga de documentos\n'
          '• Abstenerse de incluir scripts o código malicioso',
    },
    {
      'title': 'Propiedad Intelectual',
      'content':
          'Todas las marcas, nombres comerciales y signos distintivos son de propiedad única y exclusiva o de sus partners.\n\n'
          'El uso no atribuye al Usuario ningún derecho sobre la propiedad intelectual.\n\n'
          'Queda estrictamente prohibida la reproducción, distribución, modificación o cualquier uso no autorizado de los contenidos.',
    },
    {
      'title': 'Enlaces a Sitios Externos',
      'content':
          'Los portales pueden contener dispositivos técnicos de enlace (links, banners, botones) que permiten acceder a sitios externos.\n\n'
          'Para el uso de cada página externa, revise los Términos y Condiciones y Políticas de Privacidad aplicables.',
    },
    {
      'title': 'Protección de Datos Personales',
      'content':
          'La información personal es importante. Se solicita lea con atención la Política de Privacidad para comprender cómo se manejan los datos.\n\n'
          'Se utiliza un banner limitando el uso únicamente a cookies técnicas necesarias para el correcto funcionamiento del sitio.',
    },
    {
      'title': 'Retiro y Suspensión de Servicios',
      'content':
          'Se podrá retirar o suspender, en cualquier momento y sin necesidad de previo aviso, los servicios a aquellos usuarios que incumplan lo establecido en estos Términos.',
    },
    {
      'title': 'Exención de Responsabilidad',
      'content':
          '• Interrupciones o fallos debidos a causas técnicas o mantenimiento\n'
          '• Daños derivados del uso indebido del sitio\n'
          '• Contenidos enlazados desde sitios de terceros\n\n'
          'El acceso se realiza bajo exclusiva responsabilidad del Usuario.',
    },
    {
      'title': 'Legislación Aplicable',
      'content':
          'Toda controversia derivada de la aplicación e interpretación de estos Términos será competencia de tribunales arbitrales.\n\n'
          'La ley aplicable será la de la República del Ecuador.\n\n'
          'Jurisdicción: Quito, Ecuador.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _expandedSections.addAll(List.filled(_sections.length, false));
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.light,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.blackOption),
            onPressed: () => context.go('/'),
          ),
        ),
        title: FadeTransition(
          opacity: _fadeController,
          child: const Text(
            'Términos y Condiciones',
            style: TextStyle(
              color: AppColors.blackOption,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Fondo con gradiente decorativo
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withOpacity(0.1),
              ),
            ),
          ),
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(_slideController),
            child: FadeTransition(
              opacity: _fadeController,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF6366F1).withOpacity(0.1),
                                    const Color(0xFF8B5CF6).withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    '⚖️',
                                    style: TextStyle(fontSize: 48),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Términos y Condiciones',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.blackOption,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Actualizado: 28 de Abril, 2026',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.darkgrey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildIntroductionCard(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return _buildAnimatedSection(index);
                      }, childCount: _sections.length),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: _buildFooterCard(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroductionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📖 Introducción',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.blackOption,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Este documento tiene por objeto establecer las condiciones de uso del sitio web. Al hacer uso de estas plataformas, usted declara haber leído, comprendido y aceptado expresamente los presentes términos y condiciones.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.darkgrey,
              height: 1.7,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Nos reservamos el derecho de modificar o actualizar en cualquier momento los términos aquí expuestos. Las modificaciones entrarán en vigor desde el momento de su publicación.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.darkgrey,
              height: 1.7,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSection(int index) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        final delayedAnimation = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _fadeController,
            curve: Interval(
              (index * 0.08).clamp(0.0, 1.0),
              ((index * 0.08) + 0.6).clamp(0.0, 1.0),
              curve: Curves.easeOut,
            ),
          ),
        );

        return Opacity(
          opacity: delayedAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - delayedAnimation.value)),
            child: _buildExpandableSection(index),
          ),
        );
      },
    );
  }

  Widget _buildExpandableSection(int index) {
    final isExpanded = _expandedSections[index];
    final section = _sections[index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isExpanded
                  ? const Color(0xFF6366F1).withOpacity(0.5)
                  : const Color(0xFF6366F1).withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isExpanded
                    ? const Color(0xFF6366F1).withOpacity(0.15)
                    : Colors.black.withOpacity(0.05),
                blurRadius: isExpanded ? 20 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _expandedSections[index] = !_expandedSections[index];
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              _getEmoji(index),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            section['title']!,
                            style: const TextStyle(
                              fontSize: 16,
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
                            color: const Color(0xFF6366F1),
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: const Color(0xFF6366F1).withOpacity(0.2),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        section['content']!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.darkgrey,
                          height: 1.8,
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
  }

  String _getEmoji(int index) {
    final emojis = ['📄', '🔓', '✅', '👤', '©️', '🔗', '🔒', '⛔', '⚠️', '⚖️'];
    return emojis[index % emojis.length];
  }

  Widget _buildFooterCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.1),
            const Color(0xFF8B5CF6).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📞 ¿Preguntas?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.blackOption,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Si tienes dudas sobre estos Términos y Condiciones, por favor consulta la Política de Privacidad y la Política de Cookies en la plataforma.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.darkgrey,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '✨ Última actualización: 28 de Abril, 2026',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.blackOption,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
