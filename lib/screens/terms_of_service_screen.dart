import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terms of Service',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Updated: January 30, 2026',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.white54,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Introduction',
              'These Terms of Service ("Terms") govern your access to and use of Ghoomo ("the App"), a travel planning application. By accessing or using the App, you agree to be bound by these Terms.',
            ),
            _buildSection(
              '1. Acceptance of Terms',
              'By creating an account or using the App, you acknowledge that you have read, understood, and agree to be bound by these Terms and our Privacy Policy. If you do not agree to these Terms, you may not use the App.',
            ),
            _buildSection(
              '2. Eligibility',
              'You must be at least 13 years old to use the App. By using the App, you represent and warrant that you meet this age requirement and have the legal capacity to enter into these Terms.',
            ),
            _buildSection(
              '3. User Accounts',
              'Account Creation:\n'
                  '• You must provide accurate and complete information when creating an account\n'
                  '• You are responsible for maintaining the confidentiality of your account credentials\n'
                  '• You are responsible for all activities that occur under your account\n'
                  '• You must notify us immediately of any unauthorized use of your account\n\n'
                  'Account Termination:\n'
                  '• You may delete your account at any time through the app settings\n'
                  '• We reserve the right to suspend or terminate accounts that violate these Terms',
            ),
            _buildSection(
              '4. Use of the App',
              'Permitted Use:\n'
                  '• Plan and organize personal travel itineraries\n'
                  '• Save and manage trip information\n'
                  '• Access AI-generated travel recommendations\n'
                  '• Use weather forecasts and currency conversion tools\n\n'
                  'Prohibited Use:\n'
                  '• Use the App for any illegal or unauthorized purpose\n'
                  '• Attempt to gain unauthorized access to the App or its systems\n'
                  '• Interfere with or disrupt the App\'s functionality\n'
                  '• Use automated systems to access the App without permission\n'
                  '• Impersonate any person or entity',
            ),
            _buildSection(
              '5. AI-Generated Content',
              'The App uses artificial intelligence to generate travel itineraries and recommendations. You acknowledge that:\n\n'
                  '• AI-generated content is provided for informational purposes only\n'
                  '• We do not guarantee the accuracy, completeness, or reliability of AI-generated content\n'
                  '• You should verify all travel information independently before making bookings\n'
                  '• We are not responsible for any decisions made based on AI-generated recommendations',
            ),
            _buildSection(
              '6. Third-Party Services',
              'The App may contain links to third-party websites or services. We are not responsible for:\n\n'
                  '• The content, accuracy, or practices of third-party services\n'
                  '• Any transactions between you and third-party providers\n'
                  '• The availability or functionality of third-party services',
            ),
            _buildSection(
              '7. Intellectual Property',
              'All content, features, and functionality of the App are owned by Ghoomo and are protected by copyright, trademark, and other intellectual property laws. You may not:\n\n'
                  '• Copy, modify, or distribute App content without permission\n'
                  '• Reverse engineer or attempt to extract source code\n'
                  '• Remove or alter any copyright or proprietary notices',
            ),
            _buildSection(
              '8. User Content',
              'You retain ownership of any content you create or upload to the App (trip plans, notes, etc.). By using the App, you grant us a license to:\n\n'
                  '• Store and process your content to provide the service\n'
                  '• Use aggregated, anonymized data to improve the App\n\n'
                  'You are responsible for ensuring your content does not violate any laws or third-party rights.',
            ),
            _buildSection(
              '9. Disclaimers',
              'THE APP IS PROVIDED "AS IS" WITHOUT WARRANTIES OF ANY KIND. WE DISCLAIM ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING:\n\n'
                  '• Warranties of merchantability or fitness for a particular purpose\n'
                  '• Warranties regarding accuracy, reliability, or availability\n'
                  '• Warranties that the App will be uninterrupted or error-free',
            ),
            _buildSection(
              '10. Limitation of Liability',
              'TO THE MAXIMUM EXTENT PERMITTED BY LAW, GHOOMO SHALL NOT BE LIABLE FOR:\n\n'
                  '• Any indirect, incidental, special, or consequential damages\n'
                  '• Loss of profits, data, or business opportunities\n'
                  '• Damages arising from your use or inability to use the App\n'
                  '• Damages resulting from third-party services or content',
            ),
            _buildSection(
              '11. Indemnification',
              'You agree to indemnify and hold harmless Ghoomo from any claims, damages, or expenses arising from:\n\n'
                  '• Your use of the App\n'
                  '• Your violation of these Terms\n'
                  '• Your violation of any rights of another party',
            ),
            _buildSection(
              '12. Changes to Terms',
              'We reserve the right to modify these Terms at any time. We will notify you of material changes by:\n\n'
                  '• Posting the updated Terms in the App\n'
                  '• Updating the "Last Updated" date\n'
                  '• Sending you a notification (if applicable)\n\n'
                  'Your continued use of the App after changes constitutes acceptance of the new Terms.',
            ),
            _buildSection(
              '13. Governing Law',
              'These Terms shall be governed by and construed in accordance with applicable laws, without regard to conflict of law principles.',
            ),
            _buildSection(
              '14. Contact Information',
              'If you have any questions about these Terms, please contact us at:\n\n'
                  'Email: legal@ghoomo.app\n'
                  'Website: www.ghoomo.app/terms',
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.gavel,
                    color: Color(0xFF6C63FF),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'By using Ghoomo, you acknowledge that you have read and understood these Terms of Service.',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.white70,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
