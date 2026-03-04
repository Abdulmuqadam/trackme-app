import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend_app_flutter/core/theme/app_theme.dart';
import 'package:frontend_app_flutter/misc/const.dart';
import 'package:frontend_app_flutter/screens/terms_and_conditions.dart';
import 'package:frontend_app_flutter/screens/update_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:frontend_app_flutter/core/storage/storage_service.dart';
import 'package:frontend_app_flutter/features/support/screens/help_and_support.dart';
import 'package:frontend_app_flutter/features/auth/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String email = '';
  String username = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  Future<void> getUserInfo() async {
    String apiUrl;
    final user = await StorageService.getUserType();
    if (user == 'facilitator') {
      apiUrl = '$Api_Link/api/facilitators/getfacilitator';
    } else {
      apiUrl = '$Api_Link/api/users/getuser';
    }
    final userIdStr = await StorageService.getUserId();
    final userId = int.tryParse(userIdStr ?? '');
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        await StorageService.saveUsername(
            '${data["firstname"]} ${data["lastname"]}');
        setState(() {
          email = data['email'] ?? '';
          username = '${data["firstname"]} ${data["lastname"]}';
          _loading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) print('error fetching user: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _initials {
    final parts = username.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  Future<void> _logOut() async {
    await StorageService.clearSession();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LogInScreen()),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _logOut();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
            child: const Text('Sign Out',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const UpdateProfile()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // ── Avatar banner ────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.navyGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      children: [
                        // Avatar circle
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.brandGradient,
                            boxShadow: AppTheme.elevatedShadow,
                          ),
                          child: Center(
                            child: Text(
                              _initials,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          username.isEmpty ? 'Your Name' : username,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email.isEmpty ? 'your@email.com' : email,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.65),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Edit profile button
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (_) => const UpdateProfile()),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusXl),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            child: const Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Menu section ────────────────────────────────────────
                  _SectionHeader(label: 'Support'),
                  _MenuTile(
                    icon: Icons.help_outline_rounded,
                    label: 'Help and Support',
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (_) => const HelpSupportPage()),
                    ),
                  ),
                  _MenuTile(
                    icon: Icons.article_outlined,
                    label: 'Terms and Conditions',
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (_) => const TermConditionPage()),
                    ),
                  ),

                  _SectionHeader(label: 'Account'),
                  _MenuTile(
                    icon: Icons.logout_rounded,
                    label: 'Sign Out',
                    showChevron: false,
                    iconColor: AppTheme.primary,
                    labelColor: AppTheme.primary,
                    onTap: _showLogoutDialog,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showChevron = true,
    this.iconColor,
    this.labelColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showChevron;
  final Color? iconColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final iColor = iconColor ?? AppTheme.textPrimary;
    final lColor = labelColor ?? AppTheme.textPrimary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: lColor,
                    ),
                  ),
                ),
                if (showChevron)
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppTheme.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Compatibility shim kept for other screens that reference ProfileMenuWidget
class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return _MenuTile(
      icon: icon,
      label: title,
      onTap: onPress,
      showChevron: endIcon,
      labelColor: textColor,
    );
  }
}
