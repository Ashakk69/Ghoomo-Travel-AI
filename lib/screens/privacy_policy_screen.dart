import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
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
              'Welcome to Ghoomo ("we," "our," or "us"). We are committed to protecting your privacy and ensuring you have a positive experience when using our travel planning application. This Privacy Policy explains how we collect, use, disclose, and safeguard your information.',
            ),
            _buildSection(
              '1. Information We Collect',
              'We collect information that you provide directly to us, including:\n\n'
                  '• Account Information: Name, email address, and password when you create an account\n'
                  '• Profile Information: Travel preferences, persona selection, and currency preferences\n'
                  '• Trip Data: Destinations, budgets, itineraries, and saved trips\n'
                  '• Device Information: Device type, operating system, and unique device identifiers\n'
                  '• Usage Data: How you interact with our app, features used, and time spent',
            ),
            _buildSection(
              '2. How We Use Your Information',
              'We use the information we collect to:\n\n'
                  '• Provide, maintain, and improve our services\n'
                  '• Generate personalized AI-powered travel itineraries\n'
                  '• Send you trip reminders and notifications\n'
                  '• Respond to your comments, questions, and requests\n'
                  '• Analyze usage patterns and optimize app performance\n'
                  '• Protect against fraudulent or illegal activity',
            ),
            _buildSection(
              '3. Data Storage and Security',
              'We implement appropriate technical and organizational measures to protect your personal information:\n\n'
                  '• Data is encrypted in transit using SSL/TLS\n'
                  '• Passwords are securely hashed and never stored in plain text\n'
                  '• Biometric authentication data is stored locally on your device\n'
                  '• We use Supabase for secure cloud storage with industry-standard security practices',
            ),
            _buildSection(
              '4. Third-Party Services',
              'We may use third-party services that collect, monitor, and analyze data:\n\n'
                  '• Google Generative AI: For generating personalized trip itineraries\n'
                  '• Weather APIs: For providing weather forecasts\n'
                  '• Supabase: For authentication and data storage\n\n'
                  'These services have their own privacy policies governing their use of your information.',
            ),
            _buildSection(
              '5. Your Rights and Choices',
              'You have the right to:\n\n'
                  '• Access and update your personal information\n'
                  '• Delete your account and associated data\n'
                  '• Opt-out of notifications\n'
                  '• Export your trip data\n'
                  '• Request clarification about how your data is used',
            ),
            _buildSection(
              '6. Data Retention',
              'We retain your information for as long as your account is active or as needed to provide you services. You may delete your account at any time through the app settings, which will remove all your personal data from our servers.',
            ),
            _buildSection(
              '7. Children\'s Privacy',
              'Our service is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13. If you are a parent or guardian and believe your child has provided us with personal information, please contact us.',
            ),
            _buildSection(
              '8. Changes to This Privacy Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date.',
            ),
            _buildSection(
              '9. Contact Us',
              'If you have any questions about this Privacy Policy, please contact us at:\n\n'
                  'Email: privacy@ghoomo.app\n'
                  'Website: www.ghoomo.app/privacy',
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
                    Icons.info_outline,
                    color: Color(0xFF6C63FF),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'By using Ghoomo, you agree to this Privacy Policy and our Terms of Service.',
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
