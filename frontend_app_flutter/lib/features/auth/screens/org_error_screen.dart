import 'package:flutter/material.dart';
import 'package:frontend_app_flutter/misc/const.dart';
import 'package:frontend_app_flutter/features/auth/screens/login_screen.dart';

enum OrgErrorType { notFound, subscriptionInactive }

class OrgErrorScreen extends StatelessWidget {
  final OrgErrorType errorType;

  const OrgErrorScreen({super.key, required this.errorType});

  @override
  Widget build(BuildContext context) {
    final isNotFound = errorType == OrgErrorType.notFound;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isNotFound ? Icons.search_off_rounded : Icons.block_rounded,
                  size: 80,
                  color: secondaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  isNotFound
                      ? 'Organization Not Found'
                      : 'Subscription Inactive',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: thirdColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  isNotFound
                      ? 'The organization you entered does not exist. Please check the subdomain and try again.'
                      : 'Your organization\'s subscription has expired or is inactive. Please contact your administrator.',
                  style: TextStyle(
                    fontSize: 16,
                    color: thirdColor.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LogInScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
