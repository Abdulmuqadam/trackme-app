import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_app_flutter/misc/const.dart';
import 'package:frontend_app_flutter/screens/chat_screen.dart';
import 'package:frontend_app_flutter/screens/map_page.dart';
import 'package:frontend_app_flutter/screens/profile_screen.dart';
import 'package:frontend_app_flutter/screens/splash_screen.dart';
import 'package:frontend_app_flutter/screens/user_home.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ByteData data =
      await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext
      .setTrustedCertificatesBytes(data.buffer.asUint8List());

  runApp(ChangeNotifierProvider(
    create: (context) => MessageProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: "Poppins"),
      home: const SplashScreen(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        inactiveColor: Colors.black,
        backgroundColor: Colors.white,
        activeColor: secondaryColor,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house_fill),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.map_fill),
            label: 'Location',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_2_fill),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_alt),
            label: 'Account',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (context) {
                return const CupertinoPageScaffold(child: HomeScreen());
              },
            );
          case 1:
            return CupertinoTabView(
              builder: (context) {
                return const CupertinoPageScaffold(child: MapPage());
              },
            );
          case 2:
            return CupertinoTabView(
              builder: (context) {
                return const CupertinoPageScaffold(child: ChatScreen());
              },
            );
          case 3:
            return CupertinoTabView(
              builder: (context) {
                return const CupertinoPageScaffold(child: ProfileScreen());
              },
            );
        }
        return Container();
      },
    );
  }
}
