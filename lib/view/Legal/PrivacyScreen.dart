// ignore_for_file: file_names

import 'package:cv_anth/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackOption,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Last updated: April 27, 2026',
                  style: TextStyle(fontSize: 13, color: AppColors.darkgrey),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'Introduction',
                  'This Privacy Policy explains how this portfolio website collects, uses, and protects any information you provide when using the site. '
                      'Your privacy is important to us and we are committed to protecting it.',
                ),
                _buildSection(
                  'Information We Collect',
                  'We may collect the following information when you use the contact form:\n'
                      '• Your name\n'
                      '• Your email address\n'
                      '• Your message content\n\n'
                      'We do not collect any additional personal information beyond what is voluntarily provided.',
                ),
                _buildSection(
                  'How We Use Your Information',
                  'Information submitted through the contact form is used solely to respond to your inquiry. '
                      'We do not sell, trade, or transfer your personal information to third parties.',
                ),
                _buildSection(
                  'Cookies',
                  'This website may use minimal session cookies required for basic functionality. '
                      'No tracking cookies or third-party advertising cookies are used.',
                ),
                _buildSection(
                  'Firebase & Third-Party Services',
                  'This site uses Firebase (by Google) for authentication and data storage. '
                      'Firebase may collect certain technical information as described in the Google Privacy Policy. '
                      'We encourage you to review Google\'s privacy practices at https://policies.google.com/privacy.',
                ),
                _buildSection(
                  'Data Security',
                  'We implement appropriate technical measures to protect your personal information. '
                      'However, no method of transmission over the internet is 100% secure, and we cannot guarantee absolute security.',
                ),
                _buildSection(
                  'Your Rights',
                  'You have the right to request access to, correction of, or deletion of any personal information we hold about you. '
                      'To exercise these rights, please contact us through the Contact section of this site.',
                ),
                _buildSection(
                  'Changes to This Policy',
                  'We may update this Privacy Policy from time to time. Changes will be reflected on this page with an updated date. '
                      'Continued use of the site after changes constitutes your acceptance of the updated policy.',
                ),
                _buildSection(
                  'Contact',
                  'If you have any questions about this Privacy Policy, please use the Contact section of this site.',
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
