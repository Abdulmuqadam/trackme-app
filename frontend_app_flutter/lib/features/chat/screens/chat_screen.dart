import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_app_flutter/misc/const.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:frontend_app_flutter/core/storage/storage_service.dart';

class Message {
  final String message;
  final String senderUsername;
  final DateTime sentAt;

  Message({
    required this.message,
    required this.senderUsername,
    required this.sentAt,
  });

  factory Message.fromJson(Map<String, dynamic> message) {
    return Message(
      message: message['message'],
      senderUsername: message['senderUsername'],
      sentAt: DateTime.fromMillisecondsSinceEpoch(message['sentAt'] * 1000),
    );
  }
}

/// GetX controller – replaces the old ChangeNotifier-based MessageProvider.
class MessageController extends GetxController {
  final messages = <Message>[].obs;

  List<Message> get reversedMessages => messages.reversed.toList();

  void addNewMessage(Message message) {
    messages.add(message);
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late io.Socket socket;
  late String username;
  late String userType;
  late int recipientId;
  final TextEditingController messageInputController = TextEditingController();

  // Controller is registered in initState and deleted in dispose so it is
  // properly scoped to the ChatScreen widget's lifecycle.
  late final MessageController _messageController;

  void connectionSocket() {
    socket = io.io(
      Api_Link,
      io.OptionBuilder().setTransports(["websocket"]).setQuery(
        {"username": username},
      ).build(),
    );

    socket.onConnect((data) {
      if (kDebugMode) print("Connect established");
    });
    socket.onConnectError((data) {
      if (kDebugMode) print("Connect Error:$data");
    });
    socket.onDisconnect((data) {
      if (kDebugMode) print("Socket.io server disconnected");
    });
    socket.on(
      "message",
      (data) => _messageController.addNewMessage(Message.fromJson(data)),
    );
  }

  void sendMessage() {
    try {
      socket.emit("message", {
        "message": messageInputController.text.trim(),
        "username": username,
      });
      messageInputController.clear();
    } catch (e) {
      if (kDebugMode) {
        print("error in sending:$e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _messageController = Get.put(MessageController());
    _initializePreferences();
  }

  void _initializePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    username = await StorageService.getUsername() ?? "";
    userType = await StorageService.getUserType() ?? "";
    recipientId = prefs.getInt("facilitator_id") ?? 0;
    connectionSocket();
  }

  @override
  void dispose() {
    Get.delete<MessageController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          "Messages",
          style: TextStyle(
            color: Color.fromRGBO(14, 116, 57, 1),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              // Obx replaces Consumer<MessageProvider>
              child: Obx(() {
                final msgs = _messageController.reversedMessages;
                return ListView.builder(
                  reverse: true,
                  itemCount: msgs.length,
                  itemBuilder: (context, index) {
                    final Message message = msgs[index];
                    final bool isSentByCurrentUser =
                        message.senderUsername == username;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 8.0,
                      ),
                      child: Row(
                        mainAxisAlignment: isSentByCurrentUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: isSentByCurrentUser
                                    ? secondaryColor
                                    : Colors.deepOrangeAccent,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 4.0,
                                    height: 4.0,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    message.message,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    DateFormat('hh:mm a')
                                        .format(message.sentAt),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10.0),
                padding: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(96, 100, 100, 100)
                          .withOpacity(0.7),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: buildTextComposer(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: secondaryColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: messageInputController,
                decoration: const InputDecoration.collapsed(
                  hintText: "Send a message",
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send_rounded),
                onPressed: () {
                  if (messageInputController.text.trim().isNotEmpty) {
                    sendMessage();
                  } else {
                    if (kDebugMode) {
                      print("error in input controller");
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
