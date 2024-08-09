import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:frontend_app_flutter/misc/const.dart';
import 'package:frontend_app_flutter/screens/user_home.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../misc/flash_message_screen.dart';

class QuerySendPage extends StatelessWidget {
  final User user;
  const QuerySendPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
          icon: const Icon(LineAwesomeIcons.angle_left),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          user.name,
          style: TextStyle(
            color: secondaryColor,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 150,
                width: double.infinity,
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    return Square(
                      colors: user.colors,
                      name: user.name,
                      image: user.image,
                      onPressed: () {},
                    );
                  },
                ),
              ),
              const SizedBox(height: 2),
              TextBox(
                user: user,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

class TextBox extends StatefulWidget {
  const TextBox({super.key, required this.user});
  final User user;

  @override
  State<TextBox> createState() => _TextBoxState();
}

class _TextBoxState extends State<TextBox> {
  PhoneContact? phoneContact;
  final recorder = FlutterSoundRecorder();
  late FlutterSoundPlayer _player;
  bool isRecording = false;
  bool isPlaying = false;
  late String filePath;
  late String? _selectedContact;

  @override
  void initState() {
    initRecorder();
    _player = FlutterSoundPlayer();
    super.initState();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw "Microphone Permission not granted";
    }

    try {
      await recorder.openRecorder();
    } catch (e) {
      if (kDebugMode) {
        print("error in initializing : $e");
      }
    }
  }

  Future<void> record() async {
    if (!isRecording) {
      // Check if recording is not already in progress
      try {
        await recorder.startRecorder(toFile: "audio");

        recorder.setSubscriptionDuration(
          const Duration(milliseconds: 500),
        );
        setState(() {
          isRecording = true;
        }); // Update recording state
      } catch (e) {
        if (kDebugMode) {
          print("Error starting recording: $e");
        }
      }
    } else {
      if (kDebugMode) {
        print("Recording is already in progress.");
      }
    }
  }

  Future<void> stop() async {
    if (isRecording) {
      try {
        // Stop recording
        final path = await recorder.stopRecorder();
        final audioFile = File(path!);

        // Save the recorded file to storage
        final appDocDir = await getApplicationDocumentsDirectory();
        final savedFilePath =
            '${appDocDir.path}/recorded_audio.mp3'; // Adjust file name and format as needed
        await audioFile.copy(savedFilePath);

        if (kDebugMode) {
          print("Recorded Audio Path: $savedFilePath");
        }

        setState(() {
          isRecording = false;
          filePath = savedFilePath;
        });
        if (kDebugMode) {
          print("saved path: $filePath");
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error stopping or saving recording: $e");
        }
      }
    } else {
      if (kDebugMode) {
        print("Recording is not in progress.");
      }
    }
  }

  Future<void> play() async {
    if (!isPlaying) {
      try {
        await _player.openPlayer();
        await _player.startPlayer(fromURI: filePath);
        setState(() {
          isPlaying = true;
        });
      } catch (e) {
        if (kDebugMode) {
          print("Error playing audio: $e");
        }
      }
    } else {
      if (kDebugMode) {
        print("Audio is already playing");
      }
    }
  }

  Future<void> stopPlaying() async {
    if (isPlaying) {
      try {
        await _player.stopPlayer();
        await _player.closePlayer();
        setState(() {
          isPlaying = false;
        });
      } catch (e) {
        if (kDebugMode) {
          print("Error stopping audio playback: $e");
        }
      }
    } else {
      if (kDebugMode) {
        print("No audio is currently playing");
      }
    }
  }

  TextEditingController textController = TextEditingController();

  void sendData(
    BuildContext context,
    String filePath,
    User user,
  ) async {
    const String apiUrl = '$Api_Link/api/queries/save';
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final username = prefs.getString("username");
    final location = prefs.getString("location");
    if (kDebugMode) {
      print(username);
    }
    final File audiofile = File(filePath);

    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.fields['text'] = textController.text;
    request.fields['querytype'] = user.name;
    request.fields['postedBy'] = username!;
    request.fields['location'] = location!;
    request.fields['assignedTo'] = "";
    request.fields['completed'] = "0";

    request.files
        .add(await http.MultipartFile.fromPath('audio', audiofile.path));

    var response = await request.send();

    if (response.statusCode == 201) {
      try {
        final responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> data = jsonDecode(responseBody);
        prefs.setString("facilitator_location", data['location']);
        prefs.setInt("facilitator_id", data['facilitator_id']);
        final location = prefs.getString("facilitator_location");
        final facilitator_id = prefs.getInt("facilitator_id");
        if (kDebugMode) {
          print(data);
          print(location);
          print(facilitator_id);
        }
        textController.clear();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              elevation: 5,
              title: Text(
                "Request is Sent",
                style: TextStyle(
                  color: thirdColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                "Query has been sent \nyou can see on map about your Facilitator or \nyou can send message to your facilitator",
                style: TextStyle(
                  color: thirdColor,
                  fontSize: 17,
                  fontWeight: FontWeight.normal,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Ok",
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
      } catch (e) {
        if (kDebugMode) {
          print("response:$e");
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: CustomSnackBarWidget(
              errorText: "Error in Sending Data",
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        );
      }
    } else {
      if (kDebugMode) {
        print('Failed to send request with status: ${response.statusCode}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      left: true,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Write the Description:",
                style: TextStyle(
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
                textAlign: TextAlign.left, // Align text to the left
              ),
              const SizedBox(height: 10),
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  hintText: 'Write a little description on current scenario',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.greenAccent),
                  ),
                  hintStyle: const TextStyle(fontWeight: FontWeight.w400),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.green)),
                ),
                minLines: 6,
                keyboardType: TextInputType.multiline,
                maxLines: null,
              ),
              const SizedBox(height: 10),
              const Text(
                "You wanna describe in voice:",
                style: TextStyle(
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
                textAlign: TextAlign.left, // Align text to the left
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      if (recorder.isRecording) {
                        await stop();
                      } else {
                        await record();
                      }
                    },
                    icon: isRecording
                        ? const Icon(Icons.mic)
                        : const Icon(Icons.mic_off_rounded),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromRGBO(14, 116, 57, 1),
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: isPlaying
                              ? () {
                                  stopPlaying();
                                }
                              : () {
                                  play();
                                },
                          icon:
                              Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                        ),
                        StreamBuilder<RecordingDisposition>(
                          stream: recorder.onProgress,
                          builder: (context, snapshot) {
                            final duration = snapshot.hasData
                                ? snapshot.data!.duration
                                : Duration.zero;
                            String twoDigits(int n) => n.toString().padLeft(1);
                            final twoDigitMinutes =
                                twoDigits(duration.inMinutes.remainder(60));
                            final twoDigitSeconds =
                                twoDigits(duration.inSeconds.remainder(60));
                            return Text(
                              "$twoDigitMinutes:$twoDigitSeconds",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: Center(
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
                        end: Alignment.centerLeft,
                        tileMode: TileMode.decal,
                        stops: const [0.0, 10.0],
                      ),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        sendData(context, filePath, widget.user);
                      },
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Send",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(width: 1.0, color: Colors.black),
                    gradient: LinearGradient(
                      colors: [mainColor, secondaryColor],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      stops: const [0.0, 10.0],
                    ),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      pickContact();
                    },
                    icon: const Icon(Icons.contact_emergency_rounded),
                    label: const Text(
                      "Send to the friend and the family too.",
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> pickContact() async {
    bool permission = await FlutterContactPicker.requestPermission();

    if (permission) {
      final phoneContact = await FlutterContactPicker.pickPhoneContact();
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final location = prefs.getString("location");
      String link = "https://www.google.com/maps/place/$location";
      if (phoneContact != null) {
        setState(() {
          _selectedContact = phoneContact.phoneNumber?.number;
        });
        if (kDebugMode) {
          print(_selectedContact);
        }
        String message = textController.text;
        final Uri url = Uri(
            scheme: "sms",
            path: _selectedContact,
            query: 'body=Message: $message.  my location is :$link');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          if (kDebugMode) {
            print("Cannot launch this URL");
          }
        }
      } else {
        // Handle case where user cancels contact picking
        if (kDebugMode) {
          print('Contact picking cancelled');
        }
      }
    } else {
      // Handle permission denied
      if (kDebugMode) {
        print('Permission denied');
      }
    }
  }
}
