import 'package:flutter/material.dart';
import 'package:frontend_app_flutter/misc/const.dart';
import 'package:frontend_app_flutter/screens/profile_screen.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          icon: const Icon(LineAwesomeIcons.angle_left),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          "Help and Support",
          style: TextStyle(
            color: secondaryColor,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Help and Support",
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(),
                  Text(
                    "Welcome to TrackMe! These Terms and Conditions govern your use of the TrackMe mobile application, provided to you by TrackMe Technologies. By downloading, installing, or using the App, you agree to be bound by these Terms and Conditions. If you do not agree to these Terms and Conditions, please do not use the App.",
                    style: TextStyle(
                      color: thirdColor,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "1. Description of Service:",
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "TrackMe is a mobile application designed to assist individuals in emergency situations by sending their location to predetermined emergency contacts or services based on the user's emergency query.",
                    style: TextStyle(
                      color: thirdColor,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "2. User Responsibilities:",
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "a. You must be at least 18 years old to use the App. By using the App, you affirm that you are at least 18 years old.\nb. You are responsible for providing accurate and up-to-date information when setting up your emergency contacts and preferences within the App.\nc. You agree not to misuse the App, including but not limited to using it for illegal purposes or in a manner that violates the rights of others.",
                    style: TextStyle(
                      color: thirdColor,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "3. Emergency Services:",
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "a. TrackMe does not provide emergency services. In the event of an emergency, you should contact local emergency services immediately.\nb. TrackMe sends your location information to designated emergency contacts or services based on the emergency query provided by you. However, we do not guarantee the accuracy or timeliness of such transmissions, as they may be affected by various factors such as network connectivity, device limitations, and GPS accuracy.",
                    style: TextStyle(
                      color: thirdColor,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "4. Privacy Policy:",
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "a. Your privacy is important to us. Please refer to our Privacy Policy [link to privacy policy] for information on how we collect, use, and disclose your personal information.\nb. By using the App, you consent to the collection, use, and disclosure of your personal information as described in our Privacy Policy.",
                    style: TextStyle(
                      color: thirdColor,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "5. Limitation of Liability:",
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "a. To the fullest extent permitted by law, TrackMe shall not be liable for any direct, indirect, incidental, special, consequential, or punitive damages arising out of or relating to your use of the App, including but not limited to damages for loss of profits, goodwill, use, data, or other intangible losses.\nb. In no event shall TrackMe's total liability to you exceed the amount paid by you, if any, for using the App.",
                    style: TextStyle(
                      color: thirdColor,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "6. Indemnification:",
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "You agree to indemnify and hold harmless TrackMe, its affiliates, officers, directors, employees, agents, and licensors from and against any and all claims, liabilities, damages, losses, costs, expenses, or fees (including reasonable attorneys' fees) arising out of or relating to your use of the App or violation of these Terms and Conditions.",
                    style: TextStyle(
                      color: thirdColor,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "7. Modifications:",
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "We reserve the right to modify or update these Terms and Conditions at any time without prior notice. Your continued use of the App after any such modifications or updates constitutes your acceptance of the revised Terms and Conditions.",
                    style: TextStyle(
                      color: thirdColor,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "By using the TrackMe App, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.",
                    style: TextStyle(
                      color: thirdColor,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
