import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_app_flutter/core/theme/app_theme.dart';
import 'package:frontend_app_flutter/features/chat/screens/chat_screen.dart';
import 'package:frontend_app_flutter/features/map/screens/map_page.dart';
import 'package:frontend_app_flutter/features/user/screens/profile_screen.dart';
import 'package:frontend_app_flutter/screens/splash_screen.dart';
import 'package:frontend_app_flutter/features/user/screens/user_home.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ByteData data =
      await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext
      .setTrustedCertificatesBytes(data.buffer.asUint8List());

  await SentryFlutter.init(
    (options) {
      options.dsn = const String.fromEnvironment(
        'SENTRY_DSN',
        defaultValue: '',
      );
      options.tracesSampleRate = 0.2;
      options.environment =
          const String.fromEnvironment('APP_ENV', defaultValue: 'development');
    },
    appRunner: () => runApp(const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
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
        inactiveColor: const Color(0xFFB0B8C1),
        backgroundColor: Colors.white,
        activeColor: AppTheme.primary,
        border: const Border(
          top: BorderSide(color: Color(0xFFE4E6EB), width: 0.5),
        ),
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
              builder: (_) =>
                  const CupertinoPageScaffold(child: HomeScreen()),
            );
          case 1:
            return CupertinoTabView(
              builder: (_) =>
                  const CupertinoPageScaffold(child: MapPage()),
            );
          case 2:
            return CupertinoTabView(
              builder: (_) =>
                  const CupertinoPageScaffold(child: ChatScreen()),
            );
          case 3:
            return CupertinoTabView(
              builder: (_) =>
                  const CupertinoPageScaffold(child: ProfileScreen()),
            );
        }
        return Container();
      },
    );
  }
}
