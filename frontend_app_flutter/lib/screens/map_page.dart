import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../misc/const.dart';
import 'package:custom_info_window/custom_info_window.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class Coordinate {
  final double latitude;
  final double longitude;

  Coordinate(this.latitude, this.longitude);
}

class DistanceTimeCalculator {
  static const double AVERAGE_SPEED = 50.0; // in km/h

  static double degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }

  static double distanceBetweenPoints(Coordinate point1, Coordinate point2) {
    const double earthRadiusKm = 6371.0;

    double lat1 = degreesToRadians(point1.latitude);
    double lon1 = degreesToRadians(point1.longitude);
    double lat2 = degreesToRadians(point2.latitude);
    double lon2 = degreesToRadians(point2.longitude);

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  static double estimatedTravelTime(
      Coordinate startPoint, Coordinate endPoint) {
    double distance = distanceBetweenPoints(startPoint, endPoint);
    double timeInHours = distance / AVERAGE_SPEED;
    return timeInHours;
  }
}

class _MapPageState extends State<MapPage> {
  final Location _locationController = Location();
  LatLng? _currentPosition;
  final List<LatLng> _polylineCoordinates = [];
  final Set<Polyline> _polylines = {};
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();
  late StreamSubscription<LocationData?> _locationSubscription;
  late SharedPreferences _preferences;
  late Timer _locationTimer;
  late LatLng _source;
  late String username;
  late String complainername;
  bool _isPreferencesInitialized = false;

  @override
  void initState() {
    super.initState();
    _locationTimer =
        Timer(Duration.zero, () {}); // Initialize with a dummy value
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializePreferences();
      if (_isPreferencesInitialized) {
        facilitatorLocation(); // Call facilitatorLocation here
        _initializeMap();
        _initializeUsername();
        _refreshMap();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isPreferencesInitialized) {
      _refreshMap();
    }
  }

  Future<void> _initializePreferences() async {
    _preferences = await SharedPreferences.getInstance();
    _isPreferencesInitialized = true;
  }

  void _refreshMap() {
    facilitatorLocation(); // Refresh facilitator's location
    _startSendingLocationIfFacilitator();
    _fetchLocationUpdates();
    _initializeUsername();
    _addPolylines(_currentPosition);
  }

  void _initializeMap() {
    _fetchLocationUpdates();
    _addPolylines(_currentPosition);
  }

  void _startSendingLocationIfFacilitator() {
    if (_preferences.getString('user_type') == 'facilitator') {
      _startSendingLocation();
    }
  }

  void facilitatorLocation() {
    String? locationString = _preferences.getString("facilitator_location");
    if (locationString != null) {
      List<String> coordinates = locationString.split(',');
      double latitude = double.tryParse(coordinates[0]) ?? 0.0;
      double longitude = double.tryParse(coordinates[1]) ?? 0.0;
      _source = LatLng(latitude, longitude);
      if (kDebugMode) {
        print(_source);
      }
    } else {
      _source = _currentPosition ?? const LatLng(0.0, 0.0);
    }
  }

  // void distanceAndTime(){
  //   Coordinate startPoint = _currentPosition;
  // }

  void _initializeUsername() {
    final username = _preferences.getString("username") ?? "";
    final complainername = _preferences.getString("complainer_name") ?? "";
    setState(() {
      this.username = username;
      this.complainername = complainername;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Navigation",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: secondaryColor,
          ),
        ),
      ),
      body: _currentPosition == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 13.5,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _customInfoWindowController.googleMapController =
                        controller;
                  },
                  polylines: _polylines,
                  markers: {
                    Marker(
                      markerId: const MarkerId("destinationLocation"),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueAzure),
                      position: _source,
                      onTap: () {
                        _showInfoWindow(_source, complainername);
                      },
                    ),
                    Marker(
                      markerId: const MarkerId("currentLocation"),
                      icon: BitmapDescriptor.defaultMarker,
                      position: _currentPosition!,
                      onTap: () {
                        _showInfoWindow(_currentPosition!, username);
                      },
                    ),
                  },
                  onTap: (_) {
                    _customInfoWindowController.hideInfoWindow!();
                  },
                  onCameraMove: (_) {
                    _customInfoWindowController.onCameraMove!();
                  },
                ),
                CustomInfoWindow(
                  controller: _customInfoWindowController,
                  height: 135,
                  width: 145,
                  offset: 40,
                )
              ],
            ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: FloatingActionButton(
              heroTag: "btn_1",
              onPressed: _refreshMap,
              splashColor: mainColor,
              foregroundColor: Colors.white,
              backgroundColor: secondaryColor,
              child: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
    );
  }

  void _fetchLocationUpdates() async {
    bool serviceEnabled = await _locationController.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
    }

    PermissionStatus permissionGranted =
        await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationSubscription = _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentPosition =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _addPolylines(_currentPosition);
        });
        _preferences.setString("location",
            "${currentLocation.latitude},${currentLocation.longitude}");
      }
    });
  }

  void _startSendingLocation() {
    const duration = Duration(seconds: 15);
    _locationTimer = Timer.periodic(duration, (_) {
      if (_currentPosition != null) {
        _sendLocationToBackend();
      }
    });
  }

  Future<void> _sendLocationToBackend() async {
    final userId = _preferences.getInt("user_id");
    if (userId == null) return;

    const url = '$Api_Link/api/queries/updatelocation';
    final Map<String, dynamic> data = {
      "userId": userId,
      "location":
          "${_currentPosition!.latitude}, ${_currentPosition!.longitude}"
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

  void _addPolylines(LatLng? currentPosition) {
    if (currentPosition != null) {
      _polylineCoordinates.clear();
      _polylineCoordinates.add(_source);
      _polylineCoordinates.add(currentPosition);

      setState(() {
        _polylines.clear(); // Clear existing polylines
        _polylines.add(
          Polyline(
            polylineId: const PolylineId("1"),
            color: Colors.blue,
            points: _polylineCoordinates,
            width: 3,
          ),
        );
      });
    }
  }

  void _showInfoWindow(LatLng position, String title) {
    _customInfoWindowController.addInfoWindow!(
      Container(
        height: 300,
        width: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: secondaryColor),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      position,
    );
  }

  void _rearrangeCameraPosition() {
    // You can set a new LatLng here to rearrange the camera position
    LatLng newPosition =
        _currentPosition!; // Example: Set it to current position
    _customInfoWindowController.googleMapController
        ?.animateCamera(CameraUpdate.newLatLng(newPosition));
  }

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    _locationSubscription.cancel();
    _locationTimer.cancel();
    super.dispose();
  }
}
