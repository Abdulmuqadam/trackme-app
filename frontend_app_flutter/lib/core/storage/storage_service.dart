import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_app_flutter/core/constants/app_constants.dart';

/// Abstraction layer over [FlutterSecureStorage].
///
/// All sensitive data (JWT token, user ID, user type) is stored in the
/// platform's secure enclave (Keychain on iOS, EncryptedSharedPreferences
/// on Android) instead of plain SharedPreferences.
///
/// Non-sensitive data (e.g., last known location) can continue to use
/// SharedPreferences via [shared_preferences].
class StorageService {
  StorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ── Token ─────────────────────────────────────────────────────────────────

  static Future<void> saveToken(String token) =>
      _storage.write(key: AppConstants.keyJwtToken, value: token);

  static Future<String?> getToken() =>
      _storage.read(key: AppConstants.keyJwtToken);

  static Future<void> deleteToken() =>
      _storage.delete(key: AppConstants.keyJwtToken);

  // ── User identity ─────────────────────────────────────────────────────────

  static Future<void> saveUserId(String id) =>
      _storage.write(key: AppConstants.keyUserId, value: id);

  static Future<String?> getUserId() =>
      _storage.read(key: AppConstants.keyUserId);

  static Future<void> saveUserType(String type) =>
      _storage.write(key: AppConstants.keyUserType, value: type);

  static Future<String?> getUserType() =>
      _storage.read(key: AppConstants.keyUserType);

  static Future<void> saveUsername(String username) =>
      _storage.write(key: AppConstants.keyUsername, value: username);

  static Future<String?> getUsername() =>
      _storage.read(key: AppConstants.keyUsername);

  // ── Session management ────────────────────────────────────────────────────

  /// Removes all secured session data (call on logout).
  static Future<void> clearSession() async {
    await _storage.delete(key: AppConstants.keyJwtToken);
    await _storage.delete(key: AppConstants.keyUserId);
    await _storage.delete(key: AppConstants.keyUserType);
    await _storage.delete(key: AppConstants.keyUsername);
  }
}
