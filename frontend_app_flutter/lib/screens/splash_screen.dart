import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_app_flutter/main.dart';
import 'package:frontend_app_flutter/misc/const.dart';
import 'package:frontend_app_flutter/screens/location_fetcher.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_app_flutter/screens/login_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../core/storage/storage_service.dart';
import '../misc/flash_message_screen.dart';
import '../misc/user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late ConnectivityResult _connectivityResult;
  final LocationFetcher _locationFetcher = LocationFetcher();

  Future<void> checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    final connectivityResult =
        results.isNotEmpty ? results.first : ConnectivityResult.none;
    setState(() {
      _connectivityResult = connectivityResult;
    });
    if (_connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomSnackBarWidget(errorText: "Check Network Connection"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
    }
  }

  Future<dynamic> sendUserJwtTokenAndSaveResponse() async {
    const apiUrl = '$Api_Link/api/users/verify';
    try {
      final jwtToken = await StorageService.getToken();
      if (jwtToken == null) {
        Future.delayed(
          const Duration(seconds: 5),
          () {
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const LogInScreen(),
              ),
            );
          },
        );
      } else {
        final response = await http.post(
          Uri.parse(apiUrl),
          body: {'token': jwtToken},
        );

        final responseData = response.body;
        final data = jsonDecode(responseData);
        if (response.statusCode == 200) {
          final userId = (data["userId"] as num?)?.toInt();
          if (userId != null) {
            await StorageService.saveUserId(userId.toString());
          }
          Future.delayed(
            const Duration(seconds: 5),
            () {
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const MainPage(),
                ),
              );
            },
          );
        } else {
          Future.delayed(
            const Duration(seconds: 2),
            () {
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LogInScreen(),
                ),
              );
            },
          );
        }
      }
    } catch (e) {
      // Handle errors
      if (kDebugMode) {
        print("error in login :$e");
      }
      return null;
    }
  }

  Future<dynamic> sendFacilitatorJwtTokenAndSaveResponse() async {
    const apiUrl = '$Api_Link/api/facilitators/verify';
    try {
      final jwtToken = await StorageService.getToken();
      if (jwtToken == null) {
        Future.delayed(
          const Duration(seconds: 5),
          () {
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const LogInScreen(),
              ),
            );
          },
        );
      } else {
        final response = await http.post(
          Uri.parse(apiUrl),
          body: {'token': jwtToken},
        );

        final responseData = response.body;
        final data = jsonDecode(responseData);
        if (response.statusCode == 200) {
          final userId = (data["userId"] as num?)?.toInt();
          if (userId != null) {
            await StorageService.saveUserId(userId.toString());
          }
          Future.delayed(
            const Duration(seconds: 5),
            () {
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const MainPage(),
                ),
              );
            },
          );
        } else {
          Future.delayed(
            const Duration(seconds: 2),
            () {
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LogInScreen(),
                ),
              );
            },
          );
        }
      }
    } catch (e) {
      // Handle errors
      if (kDebugMode) {
        print("error in login :$e");
      }
      return null;
    }
  }

  Future<String?> choseUser() async {
    final userType = await StorageService.getUserType();
    return userType;
  }

  Future<void> initializeUserType() async {
    final userType = await choseUser();
    if (userType == "facilitator") {
      sendFacilitatorJwtTokenAndSaveResponse();
    } else {
      sendUserJwtTokenAndSaveResponse();
    }
  }

  @override
  void initState() {
    super.initState();
    // checkConnectivity();
    UserService.getUserInfo();
    _startFetchingLocation();
    initializeUserType();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void _startFetchingLocation() {
    _locationFetcher.startFetchingLocationUpdates();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0E3460), Color(0xFF08203E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Logo / icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFED2939)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFED2939).withOpacity(0.35),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 52,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'TrackMe',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your safety, always connected',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.6),
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(flex: 2),
              // Loading indicator at bottom
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFFFFD700).withOpacity(0.8),
                  ),
                  strokeWidth: 2.5,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class LinearGradientMask extends StatelessWidget {
  const LinearGradientMask({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color.fromRGBO(160, 241, 234, 1)],
          tileMode: TileMode.mirror,
        ).createShader(bounds);
      },
      child: child,
    );
  }
}
