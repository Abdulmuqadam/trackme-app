import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'const.dart';

class UserService {
  static Future<Map<String, String>> getUserInfo() async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final user = preferences.getString("user_type");
      final userId = preferences.getInt("user_id");

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

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (kDebugMode) {
          print("Data is retrieved successfully");
        }
        final String username = data["firstname"] + " " + data["lastname"];
        final String email = data["email"];

        // Save username to SharedPreferences
        preferences.setString("username", username);
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
