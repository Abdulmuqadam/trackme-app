import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../misc/const.dart';

class LocationFetcher {
  final Location _location = Location();
  late final SharedPreferences _preferences;

  StreamSubscription<LocationData>? _locationSubscription;
  Timer? _locationTimer;
  LatLng? _currentPosition;

  LocationFetcher() {
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    _preferences = await SharedPreferences.getInstance();
  }

  void startFetchingLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    try {
      serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          return; // Handle the case where the user denies enabling location services
        }
      }

      permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return; // Handle the case where the user denies granting location permission
        }
      }

      if (_locationSubscription != null) {
        _locationSubscription!.cancel();
      }

      _locationSubscription =
          _location.onLocationChanged.listen((LocationData currentLocation) {
        if (currentLocation.latitude != null &&
            currentLocation.longitude != null) {
          _currentPosition =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _saveLocationToPreferences(_currentPosition!);
        }
      });

      // Start sending location to the backend periodically
      if (_preferences.getString('user_type') == 'facilitator') {
        _startSendingLocation();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching location updates: $e');
      }
    }
  }

  void _startSendingLocation() {
    const duration = Duration(seconds: 15);
    _locationTimer = Timer.periodic(duration, (_) {
      if (_currentPosition != null) {
        _sendLocationToBackend(_currentPosition!);
      }
    });
  }

  void _saveLocationToPreferences(LatLng position) {
    _preferences.setString(
        "location", "${position.latitude},${position.longitude}");
  }

  Future<void> _sendLocationToBackend(LatLng position) async {
    final userId = _preferences.getInt("user_id");
    if (userId == null) return;

    const url = '$Api_Link/api/queries/updatelocation';
    final Map<String, dynamic> data = {
      "userId": userId,
      "location": "${position.latitude}, ${position.longitude}"
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );
      if (kDebugMode) {
        print(data);
      }
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Location sent successfully");
        }
      } else {
        if (kDebugMode) {
          print("Failed to send location: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error sending location: $e");
      }
    }
  }
}
