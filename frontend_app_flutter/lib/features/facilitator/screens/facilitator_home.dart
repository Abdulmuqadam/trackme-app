import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend_app_flutter/core/theme/app_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_app_flutter/core/storage/storage_service.dart';
import 'package:frontend_app_flutter/misc/const.dart';
import 'package:frontend_app_flutter/misc/user_service.dart';
import 'package:frontend_app_flutter/features/location/services/location_fetcher.dart';

class FacilitatorHomeContent extends StatefulWidget {
  const FacilitatorHomeContent({super.key});

  @override
  FacilitatorHomeContentState createState() => FacilitatorHomeContentState();
}

class FacilitatorHomeContentState extends State<FacilitatorHomeContent> {
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
    final userIdStr = await StorageService.getUserId();
    final userId = int.tryParse(userIdStr ?? '');
    if (userId == null) return;

    const url = '$Api_Link/api/queries/getQueryByFacilitatorId';
    final Map<String, dynamic> data = {"facilitatorID": userId};

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
            queryData =
                queryList.map((item) {
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
                    [secondaryColor, mainColor],
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
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Operations'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : FacilitatorCardView(queryData: queryData),
    );
  }
}

class FacilitatorCardView extends StatelessWidget {
  final List<Queries> queryData;
  const FacilitatorCardView({super.key, required this.queryData});

  @override
  Widget build(BuildContext context) {
    if (queryData.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 56,
              color: AppTheme.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              'No operations assigned',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
  FacilitatorCardsState createState() => FacilitatorCardsState();
}

class FacilitatorCardsState extends State<FacilitatorCards> {
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
      onTap: () => _showInfoDialog(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top colored banner
            Container(
              height: 6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.colors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusLg),
                  topRight: Radius.circular(AppTheme.radiusLg),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    child: SizedBox(
                      width: 68,
                      height: 68,
                      child: Image.asset(widget.image, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 13,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.postedBy,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Completion switch
                  Column(
                    children: [
                      Switch(
                        value: _isComplete,
                        activeThumbColor: const Color(0xFF22C55E),
                        onChanged: (value) {
                          setState(() {
                            _isComplete = value;
                            updateQueryCompletionStatus(widget.id, _isComplete);
                          });
                        },
                      ),
                      Text(
                        _isComplete ? 'Done' : 'Open',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color:
                              _isComplete
                                  ? const Color(0xFF22C55E)
                                  : AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(widget.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(icon: Icons.message_outlined, label: widget.message),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.person_outline_rounded,
                  label: 'By: ${widget.postedBy}',
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: widget.location,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Audio: ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.play_circle_fill_rounded,
                        color: AppTheme.primary,
                        size: 30,
                      ),
                      onPressed: () async {
                        await downloadAudio('$Api_Link/${widget.audioData}');
                        await playAudio();
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.stop_circle_rounded,
                        color: AppTheme.textSecondary,
                        size: 30,
                      ),
                      onPressed: stopAudio,
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                _saveLocation();
                Navigator.of(ctx).pop();
              },
              child: const Text('OK'),
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

    final Map<String, dynamic> data = {"id": id, "completed": completed};

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
            "Error in updating query completion status: ${response.statusCode}",
          );
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

  Queries(
    this.id,
    this.colors,
    this.image,
    this.name,
    this.postedBy,
    this.message,
    this.location,
    this.completed,
    this.audioData,
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
