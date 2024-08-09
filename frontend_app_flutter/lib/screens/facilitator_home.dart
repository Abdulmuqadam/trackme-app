import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../misc/const.dart';
import '../misc/user_service.dart';
import 'location_fetcher.dart';

class FacilitatorHomeContent extends StatefulWidget {
  const FacilitatorHomeContent({super.key});

  @override
  _FacilitatorHomeContentState createState() => _FacilitatorHomeContentState();
}

class _FacilitatorHomeContentState extends State<FacilitatorHomeContent> {
  final LocationFetcher _locationFetcher = LocationFetcher();
  List<Queries> queryData = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    UserService.getUserInfo();
    getQueryDataByFacilitatorId();
    _startFetchingLocation();
  }

  void _startFetchingLocation() {
    _locationFetcher.startFetchingLocationUpdates();
  }

  Future<void> getQueryDataByFacilitatorId() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final userId = preferences.getInt("user_id");
    if (userId == null) return;

    const url = '$Api_Link/api/queries/getQueryByFacilitatorId';
    final Map<String, dynamic> data = {
      "facilitatorID": userId,
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
          print("Got Queries");
        }
        final responseData = jsonDecode(response.body);
        if (responseData['message'] == 'Queries found') {
          final List<dynamic> queryList = responseData['queries'];
          setState(() {
            isLoading = false;
            queryData = queryList.map((item) {
              final id = item['id'] ?? 0;
              final image = item['image'] ?? 'assets/images/help.png';
              final queryType = item['querytype'] ?? '';
              final postedBy = item['postedBy'] ?? '';
              final message = item['text'] ?? '';
              final location = item['location'] ?? '';
              final completed = item['completed'] ?? false;
              final audioData = item['audio'] ?? '';
              return Queries(
                id,
                [
                  secondaryColor,
                  mainColor,
                ],
                image,
                queryType,
                postedBy,
                message,
                location,
                completed,
                audioData,
              );
            }).toList();
          });
        } else {
          throw Exception("Unexpected message: ${responseData['message']}");
        }

        if (kDebugMode) {
          print(queryData);
        }
      } else {
        if (kDebugMode) {
          print("Failed to fetch queries: ${response.statusCode}");
        }
        throw Exception('Failed to load query data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    } finally {
      setState(() {
        isLoading = false; // Set isLoading to false after fetching data
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      queryData = []; // Clear existing data
    });
    await getQueryDataByFacilitatorId(); // Fetch new data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Operations',
          style: TextStyle(
            color: secondaryColor,
            fontSize: 35,
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins",
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black), // Icon color
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : FacilitatorCardView(queryData: queryData),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: FloatingActionButton(
              onPressed: _refreshData,
              tooltip: 'Refresh',
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
}

class FacilitatorCardView extends StatelessWidget {
  final List<Queries> queryData;
  const FacilitatorCardView({super.key, required this.queryData});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        itemCount: queryData.length,
        itemBuilder: (context, index) {
          final query = queryData[index];
          return FacilitatorCards(
            id: query.id,
            colors: query.colors,
            name: query.name,
            image: query.image,
            postedBy: query.postedBy,
            message: query.message,
            location: query.location,
            completed: query.completed,
            audioData: query.audioData,
            onPressed: () {},
          );
        },
      ),
    );
  }
}

class FacilitatorCards extends StatefulWidget {
  const FacilitatorCards({
    super.key,
    required this.id,
    required this.name,
    required this.image,
    required this.colors,
    required this.postedBy,
    required this.message,
    required this.location,
    required this.audioData,
    required this.completed,
    required this.onPressed,
  });

  final int id;
  final String name;
  final String image;
  final List<Color> colors;
  final String postedBy;
  final String message;
  final String location;
  final String audioData;
  final bool completed;
  final VoidCallback onPressed;

  @override
  _FacilitatorCardsState createState() => _FacilitatorCardsState();
}

class _FacilitatorCardsState extends State<FacilitatorCards> {
  late bool _isComplete;
  bool isPlaying = false;
  AudioPlayer player = AudioPlayer();
  String? localFilePath;

  @override
  void initState() {
    super.initState();
    _isComplete = widget.completed;
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> downloadAudio(String url) async {
    try {
      Dio dio = Dio();
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${url.split('/').last}';
      await dio.download(url, filePath);
      setState(() {
        localFilePath = filePath;
      });
      if (kDebugMode) {
        print("File downloaded to $filePath");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error downloading audio file: $e");
      }
    }
  }

  Future<void> playAudio() async {
    if (localFilePath != null) {
      try {
        await player.play(DeviceFileSource(localFilePath!));
        setState(() {
          isPlaying = true;
        });
      } catch (e) {
        if (kDebugMode) {
          print("Error playing audio file: $e");
        }
      }
    } else {
      if (kDebugMode) {
        print("Audio file path is null");
      }
    }
  }

  Future<void> stopAudio() async {
    try {
      await player.stop();
      setState(() {
        isPlaying = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error stopping audio file: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showInfoDialog(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          color: widget.colors.first,
          elevation: 10,
          shadowColor: Colors.black,
          child: SizedBox(
            height: 145,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: SizedBox(
                      height: 120,
                      width: 120,
                      child: Image.asset(
                        widget.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0, bottom: 5),
                        child: Text(
                          widget.name,
                          style: const TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Divider(),
                      Row(
                        children: [
                          Text(
                            "Query By: ${widget.postedBy}",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Spacer(),
                          Switch(
                            value: _isComplete,
                            onChanged: (value) {
                              setState(() {
                                _isComplete = value;
                                updateQueryCompletionStatus(
                                    widget.id, _isComplete);
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Additional Information',
            style: TextStyle(
              color: thirdColor,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Message: ${widget.message}',
                  style: TextStyle(
                    fontSize: 16,
                    color: thirdColor,
                  ),
                ),
                Text(
                  'Posted By: ${widget.postedBy}',
                  style: TextStyle(
                    fontSize: 16,
                    color: thirdColor,
                  ),
                ),
                Text(
                  'Location: ${widget.location}',
                  style: TextStyle(
                    fontSize: 16,
                    color: thirdColor,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "Audio:",
                      style: TextStyle(
                        fontSize: 16,
                        color: thirdColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await downloadAudio(
                            "https://backend.prometheansempiremedia.com/${widget.audioData}");
                        await playAudio();
                      },
                      icon: const Icon(
                        Icons.play_arrow_rounded,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        stopAudio();
                      },
                      icon: const Icon(Icons.pause_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Close',
                style: TextStyle(
                  color: thirdColor,
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Ok',
                style: TextStyle(
                  color: thirdColor,
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                _saveLocation();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveLocation() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('facilitator_location', widget.location);
    await prefs.setString('complainer_name', widget.postedBy);
  }

  Future<void> updateQueryCompletionStatus(int id, bool completed) async {
    const apiUrl = '$Api_Link/api/queries/updatequerycomplete';

    final Map<String, dynamic> data = {
      "id": id,
      "completed": completed,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Query completion status updated successfully");
        }
      } else {
        if (kDebugMode) {
          print(
              "Error in updating query completion status: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating query completion status: $e");
      }
    }
  }
}

class Queries {
  final int id;
  final String image;
  final String name;
  final String message;
  final String postedBy;
  final String location;
  final String audioData;
  final bool completed;
  final List<Color> colors;

  Queries(this.id, this.colors, this.image, this.name, this.postedBy,
      this.message, this.location, this.completed, this.audioData);
}
