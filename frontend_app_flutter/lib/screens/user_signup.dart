import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../misc/const.dart';
import 'login_screen.dart';

class UserSignupScreen extends StatelessWidget {
  const UserSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const UserSignupContent();
  }
}

class UserSignupContent extends StatelessWidget {
  const UserSignupContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LogInScreen()),
              );
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      backgroundColor: Colors.white,
      body: const SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(children: [
                SizedBox(
                  height: 10,
                ),
                LinearGradientMask(
                  child: Icon(
                    Icons.online_prediction_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                LinearGradientMask(
                  child: Text(
                    "Create account as User",
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
                  "Create your account as user",
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                UserSignUpForm(),
              ]),
            ),
          ),
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
  String selectedGender = "Male";
  bool _obscureText = true;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  void _onGenderChanged(String? newValue) {
    setState(() {
      selectedGender = newValue!;
    });
  }

  bool areControllersFilled() {
    return firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        phoneNumberController.text.isNotEmpty;
  }

  bool isPasswordValid(String password) {
    if (password.length < 8) {
      return false;
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return false;
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return false;
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return false;
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return false;
    }
    return true;
  }

  bool isEmailValid(String email) {
    final emialRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emialRegex.hasMatch(email);
  }

  Future<void> checkEmailExists(String email) async {
    try {
      if (kDebugMode) {
        print(email);
      }
      final response = await http
          .post(Uri.parse("$Api_Link/api/users/emailchecker?email=$email"));
      Map<String, dynamic> body = jsonDecode(response.body);
      bool emailExists = body['emailExists'];
      if (emailExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "User already signed up with this email \nPlease Try any other one",
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      } else {
        if (kDebugMode) {
          print("create user $email");
        }
        createUser();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "An error occurred while checking email",
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> createUser() async {
    const String apiUrl = '$Api_Link/api/users/signup';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstname': firstNameController.text,
          'lastname': lastNameController.text,
          'gender': selectedGender,
          'email': emailController.text.trim(),
          'password': passwordController.text,
          'number': phoneNumberController.text,
          'profilepic': "",
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String token = data['token'];
        final String message = data['message'];
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('jwt_token', token);
        prefs.setInt("user_id", data["userId"]);
        if (kDebugMode) {
          print(data["userId"]);
        }
        prefs.setString('message', message);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LogInScreen()),
        );
      } else {
        throw Exception('Failed to create user: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to create user: $e"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First Name and Last Name in a Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      labelText: "First Name",
                      hintText: "First Name",
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
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(14, 116, 57, 1)),
                        gapPadding: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: TextFormField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: "Last Name",
                      hintText: "Last Name",
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
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(14, 116, 57, 1)),
                        gapPadding: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: phoneNumberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      hintText: "+92-0300-00000",
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
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(14, 116, 57, 1)),
                        gapPadding: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedGender,
                    onChanged: _onGenderChanged,
                    decoration: InputDecoration(
                      labelText: "Gender",
                      hintText: "Male",
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
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(14, 116, 57, 1)),
                        gapPadding: 10,
                      ),
                    ),
                    items: ['Male', 'Female', 'Other']
                        .map<DropdownMenuItem<String>>(
                          (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            // Other Fields in a Column
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
              ),
            ),
            const SizedBox(height: 16.0),
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
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Sign-Up Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    width: 1.0,
                    color: Colors.black,
                  ),
                  gradient: LinearGradient(
                    colors: [mainColor, secondaryColor],
                    begin: Alignment.centerRight,
                    end: Alignment.bottomLeft,
                    tileMode: TileMode.clamp,
                    stops: const [0.0, 10.0],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (areControllersFilled()) {
                      if (isEmailValid(emailController.text.trim())) {
                        if (!isPasswordValid(passwordController.text.trim())) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Password must be at least 8 characters long \nand contain at least one uppercase letter,\n one lowercase letter, one digit,\n and one special character."),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          checkEmailExists(emailController.text.trim());
                          if (kDebugMode) {
                            print("User is creating");
                          }
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Please use the correct email format \nLike this example@example.com"),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("All fields are required"),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 4,
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
