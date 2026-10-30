import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend_app_flutter/core/theme/app_theme.dart';
import 'package:frontend_app_flutter/screens/queries_list.dart';
import 'package:frontend_app_flutter/screens/query_send.dart';

import 'package:frontend_app_flutter/core/storage/storage_service.dart';
import 'package:frontend_app_flutter/misc/user_service.dart';
import 'package:frontend_app_flutter/features/facilitator/screens/facilitator_home.dart';
import 'package:frontend_app_flutter/features/location/services/location_fetcher.dart';

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
    _locationFetcher.startFetchingLocationUpdates();
    _userTypeFuture = StorageService.getUserType();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _userTypeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == 'facilitator') {
          return const FacilitatorHomeContent();
        }
        return const UserHomeContent();
      },
    );
  }
}

// ── Emergency query model ──────────────────────────────────────────────────

class User {
  final String image;
  final String name;
  final List colors;

  User(this.colors, this.image, this.name);
}

List<User> user = [
  User(
    [Colors.grey, Colors.blueAccent],
    'assets/images/homeinvasion.jpg',
    'Home Invasion',
  ),
  User(
    [Colors.blueAccent, Colors.blueAccent],
    'assets/images/medicalhelp.jpg',
    'Medical Help',
  ),
  User(
    [Colors.redAccent, Colors.blueAccent],
    'assets/images/fireextinguisher.jpg',
    'Fire Extinguisher',
  ),
  User(
    [Colors.greenAccent, Colors.blueAccent],
    'assets/images/travelemergency.png',
    'Travel Emergency',
  ),
];

// Per-card gradient pairs
const List<List<Color>> _cardGradients = [
  [Color(0xFF2D2D6B), Color(0xFF1A1A4E)], // Home Invasion – deep indigo
  [Color(0xFF1B6CA8), Color(0xFF0D3F6B)], // Medical Help – ocean blue
  [Color(0xFFBF2626), Color(0xFF7A1515)], // Fire – deep red
  [Color(0xFF167C55), Color(0xFF0B4E35)], // Travel – deep green
];

const List<IconData> _cardIcons = [
  Icons.home_outlined,
  Icons.local_hospital_outlined,
  Icons.local_fire_department_outlined,
  Icons.directions_car_outlined,
];

// ── User home content ──────────────────────────────────────────────────────

class UserHomeContent extends StatelessWidget {
  const UserHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Emergency'),
        actions: [
          IconButton(
            tooltip: 'My Queries',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const QueriesListPage(),
                ),
              );
            },
            icon: const Icon(CupertinoIcons.square_favorites_fill, size: 22),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.navyGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Need Help?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select your emergency type below',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.emergency_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Emergency Types',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: user.length,
              itemBuilder:
                  (context, index) => _EmergencyCard(
                    user: user[index],
                    gradient: _cardGradients[index],
                    icon: _cardIcons[index],
                    onTap: () {
                      if (kDebugMode)
                        print('Card pressed: ${user[index].name}');
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder:
                              (context) => QuerySendPage(user: user[index]),
                        ),
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Emergency card ─────────────────────────────────────────────────────────

class _EmergencyCard extends StatelessWidget {
  const _EmergencyCard({
    required this.user,
    required this.gradient,
    required this.icon,
    required this.onTap,
  });

  final User user;
  final List<Color> gradient;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: SizedBox(
                width: 68,
                height: 68,
                child: Image.asset(user.image, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 16),
            // Label
            Expanded(
              child: Text(
                user.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            // Arrow badge
            Container(
              margin: const EdgeInsets.only(right: 16),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Keep Square class for backward compatibility with QuerySendPage references
class Square extends StatelessWidget {
  final String name;
  final String image;
  final List colors;
  final VoidCallback? onPressed;

  const Square({
    super.key,
    required this.name,
    required this.image,
    required this.colors,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 100,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.first as Color, colors.last as Color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: SizedBox(
                width: 68,
                height: 68,
                child: Image.asset(image, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Keep UserCardView for backward compatibility
class UserCardView extends StatelessWidget {
  const UserCardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppTheme.surface,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: user.length,
          itemBuilder:
              (context, index) => _EmergencyCard(
                user: user[index],
                gradient: _cardGradients[index],
                icon: _cardIcons[index],
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => QuerySendPage(user: user[index]),
                    ),
                  );
                },
              ),
        ),
      ),
    );
  }
}
