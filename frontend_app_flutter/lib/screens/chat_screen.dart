import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_app_flutter/misc/const.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

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

class MessageProvider extends ChangeNotifier {
  final List<Message> _messages = [];
  List<Message> get messages => _messages.reversed.toList();

  MessageProvider();

  void addNewMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  late io.Socket socket;
  late SharedPreferences preferences;
  late String username;
  late String userType;
  late int recipientId;
  final TextEditingController messageInputController = TextEditingController();

  void connectionSocket() {
    socket = io.io(
      Api_Link,
      io.OptionBuilder().setTransports(["websocket"]).setQuery(
        {"username": username},
      ).build(),
    );

    socket.onConnect((data) => print("Connect established"));
    socket.onConnectError((data) => print("Connect Error:$data"));
    socket.onDisconnect((data) => print("Socket.io server disconnected"));
    socket.on(
      "message",
      (data) =>
          Provider.of<MessageProvider>(context, listen: false).addNewMessage(
        Message.fromJson(data),
      ),
    );
  }

  void sendMessage() {
    try {
      // int recipientId
      socket.emit("message", {
        "message": messageInputController.text.trim(),
        "username": username,
        // "recipientId": recipientId
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
    _initializePreferences();
  }

  void _initializePreferences() async {
    preferences = await SharedPreferences.getInstance();
    username = preferences.getString("username") ?? ""; // Initialize username
    userType = preferences.getString("user_type") ?? "";
    recipientId = preferences.getInt("facilitator_id") ??
        0; // Use a default value if facilitator_id is not set
    connectionSocket(); // Call connectionSocket() after username is initialized
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
              child: Consumer<MessageProvider>(
                builder: (context, messageProvider, _) {
                  return ListView.builder(
                    reverse: true,
                    itemCount: messageProvider.messages.length,
                    itemBuilder: (context, index) {
                      final Message message = messageProvider.messages[index];
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
                },
              ),
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
                      offset: const Offset(0, 2), // changes position of shadow
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
                  // handleSubmitted(messageInputController.text);
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
