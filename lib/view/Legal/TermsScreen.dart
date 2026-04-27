// ignore_for_file: file_names

import 'package:cv_anth/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({Key? key}) : super(key: key);

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
          'Terms of Use | CV { Anth }',
          style: TextStyle(
            color: AppColors.blackOption,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Terms of Use',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackOption,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Last updated: April 27, 2026',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.darkgrey,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'Acceptance of Terms',
                  'By accessing and using this portfolio website, you accept and agree to be bound by the terms and provisions of this agreement. '
                      'If you do not agree to these terms, please do not use this site.',
                ),
                _buildSection(
                  'Use of Content',
                  'All content on this site — including text, images, code samples, and design elements — is the intellectual property of Anthony Estuardo and is protected by applicable copyright laws. '
                      'You may not reproduce, distribute, or use any content without prior written permission.',
                ),
                _buildSection(
                  'Purpose of the Site',
                  'This website is a personal portfolio intended solely to showcase professional experience, projects, and certifications. '
                      'It is not intended for commercial transactions or the collection of personal data beyond what is strictly necessary for contact purposes.',
                ),
                _buildSection(
                  'External Links',
                  'This site may contain links to third-party websites. These links are provided for convenience only. '
                      'We have no control over the content of those sites and accept no responsibility for them.',
                ),
                _buildSection(
                  'Disclaimer of Warranties',
                  'This website is provided on an "as is" basis without any warranties of any kind. '
                      'We do not warrant that the site will be available, error-free, or free of viruses or other harmful components.',
                ),
                _buildSection(
                  'Changes to Terms',
                  'We reserve the right to modify these terms at any time. Changes will be posted on this page with an updated date. '
                      'Continued use of the site after changes constitutes your acceptance of the new terms.',
                ),
                _buildSection(
                  'Contact',
                  'If you have any questions about these Terms, please use the Contact section of this site.',
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.blackOption,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.darkgrey,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
