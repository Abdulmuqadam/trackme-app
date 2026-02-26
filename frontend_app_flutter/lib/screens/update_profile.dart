import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend_app_flutter/misc/const.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend_app_flutter/screens/profile_screen.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  File? _image;

  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        if (kDebugMode) {
          print("No Image selected");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          icon: const Icon(LineAwesomeIcons.angle_left),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: _image == null
                          ? Image.network(Profile_Image)
                          : Image.file(_image!),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: secondaryColor,
                        ),
                        child: IconButton(
                          onPressed: () {
                            getImage();
                          },
                          icon: const Icon(
                            LineAwesomeIcons.camera,
                            color: Colors.white,
                            size: 25.0,
                          ),
                        )),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const UpdateUserForm()
            ],
          ),
        ),
      ),
    );
  }
}

Widget bottomSheet() {
  return Container(
    height: 100,
    width: double.infinity,
    margin: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 20,
    ),
    child: Column(
      children: <Widget>[
        const Text(
          "Choose Profile Photo",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: <Widget>[
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.camera),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.image),
            ),
          ],
        )
      ],
    ),
  );
}

class UpdateUserForm extends StatefulWidget {
  const UpdateUserForm({super.key});

  @override
  State<UpdateUserForm> createState() => _UpdateUserFormState();
}

class _UpdateUserFormState extends State<UpdateUserForm> {
  String _user = '';
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userIdentification();
  }

  void userIdentification() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final user = prefs.getString("user_type");
    if (user != null) {
      if (kDebugMode) {
        print("hello");
      }
    }
    setState(() {
      _user = user!;
    });
    if (kDebugMode) {
      print(_user);
    }
  }

  Future<void> updateUser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("user_id");
      String apiUrl = "$Api_Link/api/users/update/$userId";

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstname': firstNameController.text,
          'lastname': lastNameController.text,
          'gender': genderController.text,
          'number': phoneNumberController.text,
        }),
      );
      if (response.statusCode == 201) {
        if (kDebugMode) {
          print("hello");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("error in updating: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
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
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    onChanged: (String? value) {},
                    decoration: InputDecoration(
                      labelText: "Gender",
                      hintText: "Male",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      floatingLabelStyle: const TextStyle(
                        color: Color.fromRGBO(14, 116, 57, 1),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 28,
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
                const SizedBox(width: 10.0),
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
              ],
            ),
          ),
          // Other Fields in a Column

          const SizedBox(height: 16.0),

          // Sign-Up Button
          Center(
            child: SizedBox(
              width: 120,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(width: 2.0, color: Colors.black),
                  gradient: LinearGradient(
                    colors: [mainColor, secondaryColor],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (_user == 'facilitator') {
                      if (kDebugMode) {
                        print("hello");
                      }
                    } else {
                      updateUser();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 4,
                  ),
                  child: const Text(
                    "Update",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UpdateFacilitatorForm extends StatefulWidget {
  const UpdateFacilitatorForm({super.key});

  @override
  _UpdateFacilitatorFormState createState() => _UpdateFacilitatorFormState();
}

class _UpdateFacilitatorFormState extends State<UpdateUserForm> {
  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First Name and Last Name in a Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "User Name",
                    hintText: "User Name",
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
            ],
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Role",
                      hintText: "Police",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      floatingLabelStyle: const TextStyle(
                        color: Color.fromRGBO(14, 116, 57, 1),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 28,
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
                    items: ['Police', 'Ambulance', 'Road Assistance', 'Rescue']
                        .map<DropdownMenuItem<String>>(
                          (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (String? value) {},
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    onChanged: (String? value) {},
                    decoration: InputDecoration(
                      labelText: "Gender",
                      hintText: "Male",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      floatingLabelStyle: const TextStyle(
                        color: Color.fromRGBO(14, 116, 57, 1),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 28,
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
          ),

          const SizedBox(height: 16.0),
          // Other Fields in a Column
          TextFormField(
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
              suffixIcon: const Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // Sign-Up Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(14, 116, 57, 1),
                elevation: 4,
              ),
              child: const Text(
                "Sign Up",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
