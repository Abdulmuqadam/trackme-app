import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:frontend_app_flutter/core/storage/storage_service.dart';
import 'const.dart';

class UserService {
  /// Builds common headers including org context when available.
  static Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{'content-type': 'application/json'};
    final subdomain = await StorageService.getOrgSubdomain();
    if (subdomain != null && subdomain.isNotEmpty) {
      headers['x-organization-subdomain'] = subdomain;
    }
    final token = await StorageService.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, String>> getUserInfo() async {
    try {
      final user = await StorageService.getUserType();
      final userIdStr = await StorageService.getUserId();
      final userId = int.tryParse(userIdStr ?? '');

      if (userId == null) {
        if (kDebugMode) {
          print("userId is not found");
        }
        return {}; // Return an empty map if user ID is not found
      }

      String apiUrl = '$Api_Link/api/users/getuser';
      if (user == "facilitator") {
        apiUrl = '$Api_Link/api/facilitators/getfacilitator';
      }

      final headers = await _buildHeaders();
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (kDebugMode) {
          print("Data is retrieved successfully");
        }
        final String username = data["firstname"] + " " + data["lastname"];
        final String email = data["email"];

        // Save username to secure storage
        await StorageService.saveUsername(username);
        if (kDebugMode) {
          print({'email': email, 'username': username});
        }
        return {'email': email, 'username': username};
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in getting user data: $e");
      }
      return {};
    }
  }
}
