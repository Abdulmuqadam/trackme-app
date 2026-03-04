import 'package:flutter/material.dart';
import 'package:frontend_app_flutter/core/theme/app_theme.dart';
import 'package:frontend_app_flutter/features/support/screens/terms_and_conditions.dart';
import 'package:frontend_app_flutter/features/user/screens/profile_screen.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Help & Support'),
      ),
      body: const _ArticleBody(
        title: 'Help & Support',
        sections: [
          _Section(
            heading: '1. Description of Service',
            body:
                'TrackMe is a mobile application designed to assist individuals in emergency situations by sending their location to predetermined emergency contacts or services based on the user\'s emergency query.',
          ),
          _Section(
            heading: '2. User Responsibilities',
            body:
                'a. You must be at least 18 years old to use the App.\n'
                'b. You are responsible for providing accurate information when setting up your emergency contacts.\n'
                'c. You agree not to misuse the App for illegal purposes or in a manner that violates the rights of others.',
          ),
          _Section(
            heading: '3. Emergency Services',
            body:
                'TrackMe does not provide emergency services. In an emergency, contact local emergency services immediately. TrackMe sends your location to designated contacts, but does not guarantee accuracy or timeliness.',
          ),
          _Section(
            heading: '4. Privacy Policy',
            body:
                'Your privacy is important to us. By using the App, you consent to the collection, use, and disclosure of your personal information as described in our Privacy Policy.',
          ),
          _Section(
            heading: '5. Limitation of Liability',
            body:
                'TrackMe shall not be liable for any direct, indirect, incidental, or consequential damages arising from your use of the App, including loss of profits, data, or other intangible losses.',
          ),
          _Section(
            heading: '6. Contact Support',
            body:
                'If you need assistance or have questions, please reach out to our support team through the App or via email. We are available to help with any questions or technical issues.',
          ),
          _Section(
            heading: '7. Modifications',
            body:
                'We reserve the right to modify these Terms at any time. Your continued use of the App constitutes acceptance of the revised Terms.',
          ),
        ],
      ),
    );
  }
}
