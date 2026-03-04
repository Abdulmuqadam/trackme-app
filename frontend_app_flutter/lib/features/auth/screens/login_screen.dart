import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend_app_flutter/core/theme/app_theme.dart';
import 'package:frontend_app_flutter/misc/const.dart';
import 'package:frontend_app_flutter/main.dart';
import 'package:frontend_app_flutter/screens/facilitator_signup.dart';
import 'package:frontend_app_flutter/screens/org_error_screen.dart';
import 'package:frontend_app_flutter/screens/user_signup.dart';
import 'package:frontend_app_flutter/misc/flash_message_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_app_flutter/core/storage/storage_service.dart';

class LogInScreen extends StatelessWidget {
  const LogInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              // Brand icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppTheme.brandGradient,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: AppTheme.elevatedShadow,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sign in to continue',
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 32),
              const LogInForm(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class LogInForm extends StatefulWidget {
  const LogInForm({super.key});

  @override
  State<LogInForm> createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController orgSubdomainController = TextEditingController();

  bool _obscureText = true;
  int currentSwitchIndex = 0;
  bool _isLoading = false;

  Map<String, String> _buildHeaders() {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final subdomain = orgSubdomainController.text.trim();
    if (subdomain.isNotEmpty) {
      headers['x-organization-subdomain'] = subdomain;
    }
    return headers;
  }

  Future<void> loginUser() async {
    setState(() => _isLoading = true);
    try {
      const String apiUrl = '$Api_Link/api/users/login';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: _buildHeaders(),
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        await StorageService.saveToken(data['token']);
        await StorageService.saveUserId(data["userId"].toString());
        await StorageService.saveUserType("user");
        final subdomain = orgSubdomainController.text.trim();
        if (subdomain.isNotEmpty) {
          await StorageService.saveOrgSubdomain(subdomain);
        }
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      } else if (response.statusCode == 404) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const OrgErrorScreen(errorType: OrgErrorType.notFound),
          ),
        );
      } else if (response.statusCode == 403) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const OrgErrorScreen(
                errorType: OrgErrorType.subscriptionInactive),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: CustomSnackBarWidget(errorText: "Invalid Credentials"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) print(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> loginFacilitator() async {
    setState(() => _isLoading = true);
    try {
      const String apiUrl = '$Api_Link/api/facilitators/login';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: _buildHeaders(),
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        await StorageService.saveToken(data['token']);
        await StorageService.saveUserId(data["userId"].toString());
        await StorageService.saveUserType("facilitator");
        final subdomain = orgSubdomainController.text.trim();
        if (subdomain.isNotEmpty) {
          await StorageService.saveOrgSubdomain(subdomain);
        }
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      } else if (response.statusCode == 404) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const OrgErrorScreen(errorType: OrgErrorType.notFound),
          ),
        );
      } else if (response.statusCode == 403) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const OrgErrorScreen(
                errorType: OrgErrorType.subscriptionInactive),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: CustomSnackBarWidget(errorText: "Invalid Credentials"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) print(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Role selector
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF0F5),
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          ),
          child: Row(
            children: [
              _RoleTab(
                label: 'User',
                icon: Icons.person_rounded,
                isSelected: currentSwitchIndex == 0,
                onTap: () => setState(() => currentSwitchIndex = 0),
              ),
              _RoleTab(
                label: 'Facilitator',
                icon: Icons.shield_rounded,
                isSelected: currentSwitchIndex == 1,
                onTap: () => setState(() => currentSwitchIndex = 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Organization subdomain
        TextFormField(
          controller: orgSubdomainController,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            labelText: 'Organization (optional)',
            hintText: 'e.g. nypd',
            prefixIcon: Icon(Icons.business_rounded),
          ),
        ),
        const SizedBox(height: 16),

        // Email
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email address',
            hintText: 'you@example.com',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 16),

        // Password
        TextFormField(
          controller: passwordController,
          obscureText: _obscureText,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () => setState(() => _obscureText = !_obscureText),
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Login button
        _GradientButton(
          onPressed: _isLoading
              ? null
              : () {
                  if (currentSwitchIndex == 0) {
                    loginUser();
                  } else {
                    loginFacilitator();
                  }
                },
          isLoading: _isLoading,
          label: 'Sign In',
        ),
        const SizedBox(height: 24),

        // Sign-up link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => currentSwitchIndex == 0
                        ? const UserSignupScreen()
                        : const FacilitatorSignupScreen(),
                  ),
                );
              },
              child: Text(
                'Create account',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleTab extends StatelessWidget {
  const _RoleTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: isSelected ? AppTheme.cardShadow : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color:
                      isSelected ? AppTheme.primary : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 54,
        decoration: BoxDecoration(
          gradient: onPressed != null
              ? AppTheme.brandGradient
              : const LinearGradient(
                  colors: [Color(0xFFCCCCCC), Color(0xFFBBBBBB)]),
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          boxShadow: onPressed != null ? AppTheme.elevatedShadow : [],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}

class LinearGradientMask extends StatelessWidget {
  const LinearGradientMask({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => AppTheme.brandGradient.createShader(bounds),
      child: child,
    );
  }
}
