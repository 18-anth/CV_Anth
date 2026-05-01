import 'package:cv_anth/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cv_anth/view/Home/Homescreen.dart';
import 'package:cv_anth/view/Contact/Contact.dart';
import 'package:cv_anth/view/Project/Project.dart';
import 'package:cv_anth/view/Project/ProjectDetail.dart';
import 'package:cv_anth/view/Project/UploadProject.dart';
import 'package:cv_anth/view/Project/EditProject.dart';
import 'package:cv_anth/view/Certifications/Certification.dart';
import 'package:cv_anth/view/Certifications/CertificationDetail.dart';
import 'package:cv_anth/view/About/AboutMe.dart';
import 'package:cv_anth/view/Auth/LoginScreen.dart';
import 'package:cv_anth/view/Legal/TermsScreen.dart';
import 'package:cv_anth/view/Legal/PrivacyScreen.dart';
import 'package:cv_anth/layouts/main_layout.dart';

class RoutePaths {
  static const String home = '/';
  static const String login = '/login';
  static const String project = '/project';
  static const String projectDetail = '/project/:id';
  static const String editProject = '/project/:id/edit';
  static const String aboutMe = '/aboutme';
  static const String certification = '/certification';
  static const String certificationDetail = '/certification/:id';
  static const String contact = '/contact';
  static const String uploadCertification = '/uploadcertification';
  static const String uploadProject = '/uploadproject';
  static const String terms = '/terms';
  static const String privacy = '/privacy';
}

// Navigation helper class
class AppNavigator {
  static void goHome(BuildContext context) {
    context.go(RoutePaths.home);
  }

  static void goToLogin(BuildContext context) {
    context.go(RoutePaths.login);
  }

  static void goToProject(BuildContext context) {
    context.go(RoutePaths.project);
  }

  static void goToProjectDetail(BuildContext context, String id) {
    context.go('/project/$id');
  }

  static void goToEditProject(BuildContext context, String id) {
    context.go('/project/$id/edit');
  }

  static void goToAboutMe(BuildContext context) {
    context.go(RoutePaths.aboutMe);
  }

  static void goToCertification(BuildContext context) {
    context.go(RoutePaths.certification);
  }

  static void goToCertificationDetail(BuildContext context, String id) {
    context.go('/certification/$id');
  }

  static void goToContact(BuildContext context) {
    context.go(RoutePaths.contact);
  }

  static void goToUploadCertification(BuildContext context) {
    context.go(RoutePaths.uploadCertification);
  }

  static void goToUploadProject(BuildContext context) {
    context.go(RoutePaths.uploadProject);
  }

  static void goToTerms(BuildContext context) {
    context.go(RoutePaths.terms);
  }

  static void goToPrivacy(BuildContext context) {
    context.go(RoutePaths.privacy);
  }
}

/// 🚀 Router estático - Todas las rutas son públicas sin protección
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // 🔐 Login Route (Modal)
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) {
        return const LoginScreen();
      },
    ),

    // 🏠 Shell route para las rutas principales con navegación
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child, currentRoute: state.matchedLocation);
      },
      routes: [
        // Home Route
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) {
            return const HomeScreen();
          },
        ),

        // Project List Route
        GoRoute(
          path: '/project',
          name: 'project',
          builder: (context, state) {
            return const Project();
          },
        ),

        // Certification List Route
        GoRoute(
          path: '/certification',
          name: 'certification',
          builder: (context, state) {
            return const Certification();
          },
        ),

        // About Me Route
        GoRoute(
          path: '/aboutme',
          name: 'aboutMe',
          builder: (context, state) {
            return const AboutMe();
          },
        ),

        // Contact Route
        GoRoute(
          path: '/contact',
          name: 'contact',
          builder: (context, state) {
            return const ContactPage();
          },
        ),
      ],
    ),

    // Rutas secundarias sin MainLayout
    // Project Detail Route
    GoRoute(
      path: '/project/:id',
      name: 'projectDetail',
      builder: (context, state) {
        final String projectId = state.pathParameters['id']!;
        return ProjectDetail(projectId: projectId);
      },
    ),

    // Edit Project Route
    GoRoute(
      path: '/project/:id/edit',
      name: 'editProject',
      builder: (context, state) {
        final String projectId = state.pathParameters['id']!;
        return EditProject(projectId: projectId);
      },
    ),

    // Certification Detail Route
    GoRoute(
      path: '/certification/:id',
      name: 'certificationDetail',
      builder: (context, state) {
        final String certId = state.pathParameters['id']!;
        return CertificationDetail(certificationId: certId);
      },
    ),

    // Upload Certification Route
    GoRoute(
      path: '/uploadcertification',
      name: 'uploadCertification',
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Upload Certification | CV { Anth }'),
            backgroundColor: AppColors.light,
            foregroundColor: AppColors.light,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/certification'),
            ),
          ),
          body: const Center(child: Text('Upload Certification Page')),
          backgroundColor: AppColors.light,
        );
      },
    ),

    // Upload Project Route
    GoRoute(
      path: '/uploadproject',
      name: 'uploadProject',
      builder: (context, state) {
        return const UploadProject();
      },
    ),

    // Terms of Use Route
    GoRoute(
      path: '/terms',
      name: 'terms',
      builder: (context, state) {
        return const TermsScreen();
      },
    ),

    // Privacy Policy Route
    GoRoute(
      path: '/privacy',
      name: 'privacy',
      builder: (context, state) {
        return const PrivacyScreen();
      },
    ),
  ],
);
