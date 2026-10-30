import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:frontend_app_flutter/core/storage/storage_service.dart';
import 'package:frontend_app_flutter/core/theme/app_theme.dart';
import 'package:frontend_app_flutter/misc/const.dart';
import 'package:frontend_app_flutter/features/auth/screens/login_screen.dart';

class UserSignupScreen extends StatelessWidget {
  const UserSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LogInScreen()),
          ),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Create Account'),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: UserSignUpForm(),
        ),
      ),
    );
  }
}

class UserSignUpForm extends StatefulWidget {
  const UserSignUpForm({super.key});

  @override
  State<UserSignUpForm> createState() => _UserSignUpFormState();
}

class _UserSignUpFormState extends State<UserSignUpForm> {
  String selectedGender = 'Male';
  bool _obscureText = true;
  bool _isLoading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneNumberController = TextEditingController();

  void _onGenderChanged(String? v) => setState(() => selectedGender = v!);

  bool _areControllersFilled() =>
      firstNameController.text.isNotEmpty &&
      lastNameController.text.isNotEmpty &&
      emailController.text.isNotEmpty &&
      passwordController.text.isNotEmpty &&
      phoneNumberController.text.isNotEmpty;

  bool _isPasswordValid(String pw) =>
      pw.length >= 8 &&
      pw.contains(RegExp(r'[A-Z]')) &&
      pw.contains(RegExp(r'[a-z]')) &&
      pw.contains(RegExp(r'[0-9]')) &&
      pw.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

  bool _isEmailValid(String e) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(e);

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  Future<void> _checkAndCreate() async {
    if (!_areControllersFilled()) {
      _showError('All fields are required');
      return;
    }
    if (!_isEmailValid(emailController.text.trim())) {
      _showError('Please enter a valid email (e.g. you@example.com)');
      return;
    }
    if (!_isPasswordValid(passwordController.text.trim())) {
      _showError(
          'Password must be ≥ 8 chars with uppercase, lowercase, digit & special character');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final emailCheckRes = await http.post(
        Uri.parse('$Api_Link/api/users/emailchecker?email=${Uri.encodeQueryComponent(emailController.text.trim())}'),
      );
      final emailBody = jsonDecode(emailCheckRes.body) as Map<String, dynamic>;
      if (emailBody['emailExists'] == true) {
        _showError('This email is already registered');
        return;
      }
      await _createUser();
    } catch (e) {
      if (kDebugMode) print(e);
      _showError('An error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createUser() async {
    final response = await http.post(
      Uri.parse('$Api_Link/api/users/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstname': firstNameController.text,
        'lastname': lastNameController.text,
        'gender': selectedGender,
        'email': emailController.text.trim(),
        'password': passwordController.text,
        'number': phoneNumberController.text,
        'profilepic': '',
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      await StorageService.saveToken(data['token']);
      await StorageService.saveUserId(data['userId'].toString());
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LogInScreen()),
      );
    } else {
      _showError('Failed to create account. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Text(
          'Join TrackMe',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Create your user account',
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 28),

        // First + Last Name row
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Phone + Gender row
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: selectedGender,
                onChanged: _onGenderChanged,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.wc_rounded),
                ),
                items: ['Male', 'Female', 'Other']
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email address',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: passwordController,
          obscureText: _obscureText,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              icon: Icon(_obscureText
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscureText = !_obscureText),
            ),
          ),
        ),
        const SizedBox(height: 28),

        _SignupButton(onPressed: _isLoading ? null : _checkAndCreate,
            isLoading: _isLoading),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Already have an account? ',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
            GestureDetector(
              onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LogInScreen())),
              child: Text('Sign In',
                  style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ],
    );
  }
}

class _SignupButton extends StatelessWidget {
  const _SignupButton({required this.onPressed, this.isLoading = false});
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
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
                      color: Colors.white, strokeWidth: 2.5),
                )
              : const Text(
                  'Create Account',
                  style: TextStyle(
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
