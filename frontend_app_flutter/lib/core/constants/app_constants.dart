// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';

/// Central place for all application-wide constants.
/// Use environment-based configuration in production by
/// replacing the values via --dart-define at build time:
///   flutter build apk --dart-define=API_BASE_URL=https://api.example.com
class AppConstants {
  AppConstants._();

  // ── API ────────────────────────────────────────────────────────────────────
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://backend.prometheansempiremedia.com',
  );

  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  // ── Assets ─────────────────────────────────────────────────────────────────
  static const String profileImagePlaceholder =
      'assets/images/profile_pic.jpeg';
  static const String appLogo = 'assets/images/logo.png';

  // ── Query types ────────────────────────────────────────────────────────────
  static const String queryTypeHomeInvasion = 'Home Invasion';
  static const String queryTypeMedicalHelp = 'Medical Help';
  static const String queryTypeFireExtinguisher = 'Fire Extinguisher';
  static const String queryTypeTravelEmergency = 'Travel Emergency';

  // ── SharedPreferences / SecureStorage keys ─────────────────────────────────
  static const String keyJwtToken = 'jwt_token';
  static const String keyUserId = 'user_id';
  static const String keyUserType = 'user_type';
  static const String keyUsername = 'username';
  static const String keyUserLocation = 'location';

  // ── Multi-org keys ──────────────────────────────────────────────────────────
  static const String keyOrgSubdomain = 'org_subdomain';
  static const String keyOrgId = 'org_id';
  static const String keyOrgName = 'org_name';
  static const String keyOrgApiKey = 'org_api_key';
}

// ── Colours ───────────────────────────────────────────────────────────────────

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

final Color mainColor = HexColor('#FFD700');
final Color secondaryColor = HexColor('#ED2939');
final Color thirdColor = HexColor('#08203e');
final Color txtColMain = HexColor('#d3f3f1');
final Color txtColSec = HexColor('#e9b7ce');
