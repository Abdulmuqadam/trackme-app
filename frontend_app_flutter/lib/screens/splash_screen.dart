import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_app_flutter/main.dart';
import 'package:frontend_app_flutter/misc/const.dart';
import 'package:frontend_app_flutter/screens/location_fetcher.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_app_flutter/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';

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
    var connectivityResult = await Connectivity().checkConnectivity();
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
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final jwtToken = prefs.getString('jwt_token');
      if (jwtToken == null) {
        Future.delayed(
          const Duration(seconds: 5),
          () {
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
        prefs.setInt("user_id", data["userId"]);

        if (response.statusCode == 200) {
          Future.delayed(
            const Duration(seconds: 5),
            () {
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
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final jwtToken = prefs.getString('jwt_token');
      if (jwtToken == null) {
        Future.delayed(
          const Duration(seconds: 5),
          () {
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
        prefs.setInt("user_id", data["userId"]);

        if (response.statusCode == 200) {
          Future.delayed(
            const Duration(seconds: 5),
            () {
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString("user_type");
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
      body: Center(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [mainColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/icons/icon.png',
                  width: 300,
                  height: 100,
                ),
              ),
              // LinearGradientMask(
              //   child: Icon(
              //     Icons.online_prediction,
              //     size: 175,
              //     color: Colors.white,
              //   ),
              // ),
              const SizedBox(height: 10),
              const LinearGradientMask(
                  child: Text(
                "Track Me",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  fontSize: 40,
                ),
              )),
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
