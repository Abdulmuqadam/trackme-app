import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend_app_flutter/misc/const.dart';
import 'package:frontend_app_flutter/screens/profile_screen.dart';
import 'package:frontend_app_flutter/screens/queries_list.dart';
import 'package:frontend_app_flutter/screens/query_send.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../misc/user_service.dart';
import 'facilitator_home.dart';
import 'location_fetcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<String?> _userTypeFuture;
  final LocationFetcher _locationFetcher = LocationFetcher();

  @override
  void initState() {
    super.initState();
    UserService.getUserInfo();
    _startFetchingLocation();
    _userTypeFuture = choseUser();
  }

  void _startFetchingLocation() {
    _locationFetcher.startFetchingLocationUpdates();
  }

  Future<String?> choseUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString("user_type");
    return userType;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
        future: _userTypeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return const Scaffold(
              body: Center(
                child: Text("Error fetching user"),
              ),
            );
          } else {
            final usertype = snapshot.data;
            if (usertype == "facilitator") {
              return const FacilitatorHomeContent();
            } else {
              return const UserHomeContent();
            }
          }
        });
  }
}

class UserHomeContent extends StatefulWidget {
  const UserHomeContent({super.key});

  @override
  State<UserHomeContent> createState() => _UserHomeContentState();
}

class _UserHomeContentState extends State<UserHomeContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Queries',
          style: TextStyle(
            color: secondaryColor,
            fontSize: 35,
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins",
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 10,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const QueriesListPage()),
              );
            },
            icon: const Icon(
              CupertinoIcons.square_favorites_fill,
              size: 30,
            ),
          ),
        ],
      ),
      body: const UserCardView(),
    );
  }
}

class User {
  final String image;
  final String name;
  final List colors;

  User(this.colors, this.image, this.name);
}

List<User> user = [
  User([Colors.grey, Colors.blueAccent], 'assets/images/homeinvasion.jpg',
      'Home Invasion'),
  User([Colors.blueAccent, Colors.blueAccent], 'assets/images/medicalhelp.jpg',
      'Medical Help'),
  User([Colors.redAccent, Colors.blueAccent],
      'assets/images/fireextinguisher.jpg', 'Fire Extinguisher'),
  User([Colors.greenAccent, Colors.blueAccent],
      'assets/images/travelemergency.png', 'Travel Emergency'),
];

class UserCardView extends StatelessWidget {
  const UserCardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                Container(
                  width: constraints.maxWidth * 1.0,
                  height: constraints.maxHeight * 1.0,
                  padding: const EdgeInsets.only(top: 7.0),
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: user.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 7.0),
                        child: Square(
                            colors: user[index].colors,
                            name: user[index].name,
                            image: user[index].image,
                            onPressed: () {
                              Navigator.of(context)
                                  .pushReplacement(MaterialPageRoute(
                                      builder: (context) => QuerySendPage(
                                            user: user[index],
                                          )));
                              if (kDebugMode) {
                                print("Card is Pressed");
                              }
                            }),
                      );
                    },
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

class Square extends StatelessWidget {
  final String name;
  final String image;
  final List colors;
  final VoidCallback? onPressed;

  const Square(
      {super.key,
      required this.name,
      required this.image,
      required this.colors,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
        child: Card(
          color: colors.first,
          elevation: 10,
          shadowColor: Colors.black,
          child: SizedBox(
            height: 125,
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
                        image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
