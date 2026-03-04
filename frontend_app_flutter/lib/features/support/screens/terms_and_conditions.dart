import 'package:flutter/material.dart';
import 'package:frontend_app_flutter/core/theme/app_theme.dart';
import 'package:frontend_app_flutter/features/user/screens/profile_screen.dart';

class TermConditionPage extends StatelessWidget {
  const TermConditionPage({super.key});

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
        title: const Text('Terms & Conditions'),
      ),
      body: const _ArticleBody(
        title: 'Terms & Conditions',
        sections: [
          _Section(
            heading: '1. Frequently Asked Questions',
            body:
                'Visit our FAQ section to find answers to common questions about TrackMe. We\'ve compiled a list of frequently asked questions with detailed answers to provide quick solutions.',
          ),
          _Section(
            heading: '2. User Guide',
            body:
                'Explore our comprehensive User Guide for step-by-step instructions on using all features of the TrackMe app — from setting up emergency contacts to initiating emergency queries.',
          ),
          _Section(
            heading: '3. Contact Support',
            body:
                'If you can\'t find the answers you\'re looking for, reach out to our dedicated support team through the App or via email. We\'re available to assist with any questions or technical issues.',
          ),
          _Section(
            heading: '4. Feedback and Suggestions',
            body:
                'We value your feedback and suggestions. If you have ideas for new features or general feedback, please let us know — your input helps us continually enhance the App.',
          ),
          _Section(
            heading: '5. Privacy and Security',
            body:
                'At TrackMe, we prioritize your privacy and security. If you have concerns, refer to our Privacy Policy or contact our support team for assistance.',
          ),
          _Section(
            heading: '6. Stay Updated',
            body:
                'Stay informed about the latest news and updates by following our social media channels and checking our website. We\'ll keep you posted on new features and important announcements.',
          ),
          _Section(
            heading: '7. Community Forum',
            body:
                'Join our community forum to connect with other TrackMe users, share experiences, and exchange tips and advice on using the App effectively.',
          ),
        ],
      ),
    );
  }
}

// ── Shared article layout widgets ─────────────────────────────────────────

class _Section {
  const _Section({required this.heading, required this.body});
  final String heading;
  final String body;
}

class _ArticleBody extends StatelessWidget {
  const _ArticleBody({required this.title, required this.sections});
  final String title;
  final List<_Section> sections;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.navyGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.article_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sections
          ...sections.map((s) => _SectionCard(section: s)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});
  final _Section section;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  section.heading,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            section.body,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
