import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend_app_flutter/misc/const.dart';
import 'package:frontend_app_flutter/screens/terms_and_conditions.dart';
import 'package:frontend_app_flutter/screens/update_profile.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'help_and_support.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String email = '';
  String username = '';

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  Future<void> getUserInfo() async {
    String apiUrl;
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final user = preferences.getString("user_type");
    if (user == "facilitator") {
      apiUrl = '$Api_Link/api/facilitators/getfacilitator';
    } else {
      apiUrl = '$Api_Link/api/users/getuser';
    }
    final userId = preferences.getInt("user_id");
    if (kDebugMode) {
      print(userId);
    }
    if (userId == null) {
      if (kDebugMode) {
        print("userId is not found");
      }
    } else {
      try {
        final response = await http.post(Uri.parse(apiUrl),
            headers: {'content-type': 'application/json'},
            body: jsonEncode({'userId': userId}));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          if (kDebugMode) {
            print("data is got successfully");
          }
          preferences.setString(
              "username", data["firstname"] + "" + data["lastname"]);
          setState(() {
            email = data["email"];
            username = data["firstname"] + " " + data["lastname"];
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print("error in getting user data: $e");
        }
      }
    }
  }

  void showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          elevation: 5,
          title: Text(
            "Logout",
            style: TextStyle(
              color: thirdColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: TextStyle(
              color: thirdColor,
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: thirdColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                logOut(context);
              },
              child: Text(
                "Logout",
                style: TextStyle(
                  color: thirdColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void logOut(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LogInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile Settings",
          style: TextStyle(
            color: secondaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset(profile_image),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: secondaryColor,
                    ),
                    child: const Icon(
                      LineAwesomeIcons.pen,
                      color: Colors.white,
                      size: 15.0,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Text(
              username,
              style:
                  (const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Text(
              email,
              style:
                  (const TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 200,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(width: 1.0, color: Colors.black),
                  gradient: LinearGradient(
                    colors: [mainColor, secondaryColor],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                ),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const UpdateProfile(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(fontSize: 20),
                    )),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              color: Colors.white,
            ),
            // Menu
            ProfileMenuWidget(
              title: "Help and Support",
              icon: LineAwesomeIcons.helping_hands,
              onPress: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const HelpSupportPage(),
                  ),
                );
              },
            ),
            ProfileMenuWidget(
              title: "Terms and Conditions",
              icon: LineAwesomeIcons.alternate_shield,
              onPress: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const TermConditionPage(),
                  ),
                );
              },
            ),
            ProfileMenuWidget(
              title: "Log Out",
              icon: LineAwesomeIcons.door_open,
              endIcon: false,
              onPress: () {
                showLogoutConfirmationDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

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
    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: secondaryColor.withOpacity(0.1),
        ),
        child: Icon(
          icon,
          color: secondaryColor,
          size: 25,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: endIcon
          ? Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: secondaryColor.withOpacity(0.1),
              ),
              child: Icon(
                LineAwesomeIcons.angle_right,
                color: secondaryColor,
                size: 15.0,
              ),
            )
          : null,
    );
  }
}
