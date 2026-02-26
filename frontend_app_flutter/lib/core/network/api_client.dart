import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend_app_flutter/core/constants/app_constants.dart';
import 'package:frontend_app_flutter/core/storage/storage_service.dart';

/// Centralised HTTP client for all REST API calls.
///
/// Automatically attaches the JWT Authorization header to every request
/// when a token is present in secure storage.
///
/// Usage:
/// ```dart
/// final client = ApiClient();
/// final response = await client.post('/users/login', body: {...});
/// ```
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final String _baseUrl = AppConstants.apiBaseUrl;

  // ── Internal helpers ──────────────────────────────────────────────────────

  Future<Map<String, String>> _buildHeaders({bool auth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await StorageService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  // ── Public methods ────────────────────────────────────────────────────────

  /// Sends an authenticated POST request.
  Future<http.Response> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final headers = await _buildHeaders(auth: auth);
    return _client.post(
      _uri(path),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// Sends an authenticated GET request.
  Future<http.Response> get(
    String path, {
    Map<String, String>? queryParams,
    bool auth = true,
  }) async {
    final headers = await _buildHeaders(auth: auth);
    final uri = queryParams != null
        ? _uri(path).replace(queryParameters: queryParams)
        : _uri(path);
    return _client.get(uri, headers: headers);
  }

  void dispose() => _client.close();
}
