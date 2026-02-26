import 'package:flutter/material.dart';
import 'package:frontend_app_flutter/screens/profile_screen.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../misc/const.dart';

class TermConditionPage extends StatelessWidget {
  const TermConditionPage({super.key});

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
          "Term and Condition",
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
                      "Term and Condition",
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(),
                  Text(
                    "Welcome to the TrackMe Help and Support page. Here, you'll find resources to assist you in using the TrackMe mobile application effectively and efficiently. Whether you have questions about setting up the app, encountering technical issues, or need assistance with any aspect of TrackMe, we're here to help.",
                    style: TextStyle(
                      color: thirdColor,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "1. Frequently Asked Questions (FAQs):",
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Visit our FAQ section to find answers to common questions about TrackMe. We've compiled a list of frequently asked questions along with detailed answers to provide you with quick solutions to your inquiries.",
                    style: TextStyle(
                      color: thirdColor,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "2. User Guide:",
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Explore our comprehensive User Guide for detailed instructions on how to use all the features and functionalities of the TrackMe app. From setting up emergency contacts to initiating emergency queries, you'll find step-by-step guides to help you navigate the app effortlessly.",
                    style: TextStyle(
                      color: thirdColor,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "3. Contact Support:",
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "If you can't find the answers you're looking for in our FAQs or User Guide, don't hesitate to reach out to our dedicated support team. You can contact us directly through the app or via email at [support email]. Our support team is available to assist you with any questions, concerns, or technical issues you may encounter.",
                    style: TextStyle(
                      color: thirdColor,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "4. Feedback and Suggestions:",
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "We value your feedback and suggestions for improving the TrackMe app. If you have any ideas for new features, enhancements, or general feedback about your experience with TrackMe, please let us know. Your input helps us continually enhance and optimize the app to better serve your needs.",
                    style: TextStyle(
                      color: thirdColor,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "5. Privacy and Security:",
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "At TrackMe, we prioritize the privacy and security of our users. If you have any concerns about your privacy or the security measures implemented in the app, please refer to our Privacy Policy or contact our support team for assistance.",
                    style: TextStyle(
                      color: thirdColor,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "6. Stay Updated:",
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Stay informed about the latest news, updates, and announcements related to the TrackMe app by following our social media channels and checking our website regularly. We'll keep you posted on any new features, improvements, or important information regarding the app.",
                    style: TextStyle(
                      color: thirdColor,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "7. Community Forum:",
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Join our community forum to connect with other TrackMe users, share experiences, and exchange tips and advice on using the app effectively. Our community forum is a great place to engage with fellow users and learn from each other's experiences.",
                    style: TextStyle(
                      color: thirdColor,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "We're here to ensure that your experience with the TrackMe app is seamless and hassle-free. If you need assistance or have any questions, please don't hesitate to reach out to us. Thank you for choosing TrackMe!",
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
