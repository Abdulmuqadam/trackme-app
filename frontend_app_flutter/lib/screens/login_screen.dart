import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend_app_flutter/misc/const.dart';
import 'package:frontend_app_flutter/main.dart';
import 'package:frontend_app_flutter/screens/facilitator_signup.dart';
import 'package:frontend_app_flutter/screens/user_signup.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../misc/flash_message_screen.dart';
import '../misc/user_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LogInScreen extends StatelessWidget {
  const LogInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserBloc(),
      child: const LogInScreenContent(),
    );
  }
}

class LogInScreenContent extends StatelessWidget {
  const LogInScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(children: [
                SizedBox(
                  height: 20,
                ),
                LinearGradientMask(
                  child: Icon(
                    Icons.online_prediction_rounded,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                LinearGradientMask(
                  child: Text(
                    "Log in to your account",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 35,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Sign in with your email and password \nor create new account if you are not a user,",
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 15,
                ),
                LogInForm(),
              ]),
            ),
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
  // Main APi Calling Functions
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> loginUser() async {
    try {
      const String apiUrl = '$Api_Link/api/users/login';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String token = data['token'];
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('jwt_token', token);
        prefs.setInt("user_id", data["userId"]);
        if (kDebugMode) {
          print(data["userId"]);
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      } else {
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
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> loginFacilitator() async {
    try {
      const String apiUrl = '$Api_Link/api/facilitators/login';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String token = data['token'];
        prefs.setInt("user_id", data["userId"]);
        prefs.setString("jwt_token", token);
        prefs.setString("user_type", "facilitator");
        if (kDebugMode) {
          print(data["userId"]);
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      } else {
        if (kDebugMode) {
          print("");
        }
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
      if (kDebugMode) {
        print(e);
      }
    }
  }

  // Usefully Variables
  bool _obscureText = true;
  int currentSwitchIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserType>(builder: (context, userType) {
      return Form(
          child: Column(
        children: [
          // Toggle Switch
          ToggleSwitch(
            minWidth: 200.0,
            cornerRadius: 20.0,
            fontSize: 18,
            borderColor: const [Colors.black],
            borderWidth: 1.0,
            activeBgColors: [
              [secondaryColor],
              [secondaryColor]
            ],
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.amberAccent,
            inactiveFgColor: Colors.white,
            initialLabelIndex: 0,
            totalSwitches: 2,
            labels: const ['User', 'Facilitator'],
            radiusStyle: true,
            onToggle: (index) {
              currentSwitchIndex = index!;
            },
          ),
          const SizedBox(
            height: 20,
          ),

          // Email field
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
                labelText: "Email",
                hintText: "Enter the Email",
                floatingLabelBehavior: FloatingLabelBehavior.always,
                floatingLabelStyle: const TextStyle(
                  color: Color.fromRGBO(14, 116, 57, 1),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: const BorderSide(color: Colors.black),
                  gapPadding: 10,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide:
                      const BorderSide(color: Color.fromRGBO(14, 116, 57, 1)),
                  gapPadding: 10,
                ),
                suffixIcon: const Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 20, 20),
                  child: Icon(
                    Icons.email_rounded,
                  ),
                )),
          ),
          const SizedBox(
            height: 20,
          ),

          // password field
          TextFormField(
            obscureText: _obscureText,
            controller: passwordController,
            decoration: InputDecoration(
                labelText: "Password",
                hintText: "Enter the password",
                floatingLabelBehavior: FloatingLabelBehavior.always,
                floatingLabelStyle: const TextStyle(
                  color: Color.fromRGBO(14, 116, 57, 1),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: const BorderSide(color: Colors.black),
                  gapPadding: 10,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide:
                      const BorderSide(color: Color.fromRGBO(14, 116, 57, 1)),
                  gapPadding: 10,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                  child: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                )),
          ),
          //   login button
          const SizedBox(
            height: 20,
          ),

          // Login Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Container(
              height: 50,
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
                  if (currentSwitchIndex == 0) {
                    if (kDebugMode) {
                      print("user");
                    }
                    loginUser();
                  } else {
                    loginFacilitator();
                  }
                },
                style: ElevatedButton.styleFrom(
                  elevation: 4,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          const Text(
            "If you do have a account",
            style: TextStyle(fontSize: 18),
          ),
          GestureDetector(
            onTap: () {
              if (currentSwitchIndex == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserSignupScreen()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FacilitatorSignupScreen()),
                );
              }
            },
            child: const Text(
              "Create a new account",
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ));
    });
  }
}

class LinearGradientMask extends StatelessWidget {
  const LinearGradientMask({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          colors: [mainColor, secondaryColor],
          tileMode: TileMode.mirror,
        ).createShader(bounds);
      },
      child: child,
    );
  }
}
