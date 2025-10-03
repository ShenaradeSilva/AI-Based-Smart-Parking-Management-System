import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:smart_parking_app/Views/reservation/my_reservations_screen.dart';

import 'widgets/pf_logo.dart';
import 'qr_code_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'reservation/booking_history_screen.dart';
import 'parking/parking_map_screen.dart';
import 'waitlist_screen.dart';
import 'location_search_screen.dart';
import '../Models/user_data.dart';

// Professional brand palette (aligned with app theme in main.dart)
const Color kPrimary = Color(0xFF1E3A8A); // Navy blue
const Color kPrimaryLight = Color(0xFF3156B3); // Lighter navy for cards/headers
const Color kBg = Color(0xFFF5F7FB); // Soft neutral background
const Color kSuccess = Color(0xFF10B981); // Emerald for success/available
const Color kDanger = Color(0xFFDC2626); // Red for danger/occupied
const Color kWarning = Color(0xFFF59E0B); // Amber for warnings/highlight

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Weather state
  double? _currentTempC;
  String? _currentWeatherText;
  DateTime _lastWeatherUpdated = DateTime.now();

  final Map<String, int> _parkingStats = {
    'total': 12,
    'occupied': 5,
    'available': 7
  };
  List<Map<String, dynamic>> get _activeReservations => [
    {
      'id': '1',
      'slotNumber': 'A1',
      'date': DateTime.now().add(const Duration(days: 1)),
      'startTime': '10:00',
      'endTime': '14:00',
      'price': 20.0,
      'status': 'Active',
      'zone': 'A',
      'location': 'One Galle Face, City Center',
      'imageAsset': 'assets/locations/OGF.jpg'
    },
    {
      'id': '2',
      'slotNumber': 'B3',
      'date': DateTime.now().add(const Duration(days: 2)),
      'startTime': '13:00',
      'endTime': '17:00',
      'status': 'Active',
      'zone': 'B',
      'location': 'Marino Mall, Sea Avenue',
      'imageAsset': 'assets/locations/MC.jpg'
    }
  ];

  // Fetch real-time weather from Open-Meteo for Colombo by default
  Future<void> _fetchWeather() async {
    try {
      // Colombo, LK (adjust later to user's location if desired)
      const lat = 6.9271;
      const lon = 79.8612;
      final uri = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,weather_code&timezone=auto');
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final current = (data['current'] ?? {}) as Map<String, dynamic>;
        final temp = (current['temperature_2m'] as num?)?.toDouble();
        final code = (current['weather_code'] as num?)?.toInt();
        setState(() {
          _currentTempC = temp;
          _currentWeatherText = _weatherCodeToText(code);
          _lastWeatherUpdated = DateTime.now();
        });
      }
    } catch (_) {
      // Leave previous values; UI will show fallback
    }
  }

  String _weatherCodeToText(int? code) {
    if (code == null) return 'Weather';
    // Simplified mapping
    if ({0}.contains(code)) return 'Clear';
    if ({1, 2, 3}.contains(code)) return 'Partly cloudy';
    if ({45, 48}.contains(code)) return 'Foggy';
    if ({51, 53, 55, 56, 57}.contains(code)) return 'Drizzle';
    if ({61, 63, 65, 66, 67}.contains(code)) return 'Rain';
    if ({71, 73, 75, 77}.contains(code)) return 'Snow';
    if ({80, 81, 82}.contains(code)) return 'Showers';
    if ({95, 96, 99}.contains(code)) return 'Thunderstorm';
    return 'Weather';
  }

  // Resolve a location image path by checking multiple candidate asset paths.
  Future<String> _bestLocationImagePath(Map<String, dynamic> reservation) async {
    final loc = _parseLocation(reservation['location'], name: reservation['locationName'], area: reservation['locationArea']);
    final name = (loc['name'] ?? '').toLowerCase();
    String inferred = 'CCC.jpg';
    if (name.contains('one galle face')) inferred = 'OGF.jpg';
    if (name.contains('marino mall')) inferred = 'MC.jpg';

    final candidates = <String?>[
      (reservation['imageAsset'] ?? reservation['locationImage'])?.toString(),
      'assets/locations/$inferred',
      // 'assets/images/$inferred',
      // 'assets/$inferred',
      'assets/locations/CCC.jpg',
      // 'assets/images/CCC.jpg',
      // 'assets/CCC.jpg',
    ];
    for (final p in candidates) {
      if (p == null || p.isEmpty) continue;
      try {
        await rootBundle.load(p);
        return p;
      } catch (_) {
        continue;
      }
    }
    return 'assets/locations/CCC.jpg';
  }

  ImageProvider? _avatarImageProvider() {
    // Prefer base64 image stored in UserData
    final base64Data = UserData.getProfileImageBase64();
    if (base64Data != null && base64Data.isNotEmpty) {
      try {
        return MemoryImage(base64Decode(base64Data));
      } catch (_) {}
    }
    // Fallback to bundled asset image (ensure it's listed in pubspec.yaml)
    return const AssetImage('assets/images/avatar_placeholder.png');
  }

  String _userInitials() {
    final name = (UserData.name ?? '').trim();
    if (name.isEmpty) return 'U';
    final parts = name.split(RegExp(r"\s+")).where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  // Format helpers to align with My Reservations
  String _formatSlot(dynamic slot) {
    final s = (slot ?? '').toString().trim();
    return s.toUpperCase();
  }

  Map<String, String> _parseLocation(dynamic location, {dynamic name, dynamic area}) {
    final explicitName = (name ?? '').toString().trim();
    final explicitArea = (area ?? '').toString().trim();
    if (explicitName.isNotEmpty || explicitArea.isNotEmpty) {
      return {'name': explicitName, 'area': explicitArea};
    }
    final raw = (location ?? '').toString().trim();
    if (raw.isEmpty) return {'name': '', 'area': ''};
    final parts = raw.split(',');
    final namePart = parts.isNotEmpty ? parts.first.trim() : '';
    final areaPart = parts.length > 1 ? parts.sublist(1).join(',').trim() : '';
    return {'name': namePart, 'area': areaPart};
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic));

    _fadeController.forward();

    // Fetch initial weather
    _fetchWeather();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value * 20,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Drawer _buildSidebar(BuildContext context) {
    final selectedColor = Theme.of(context).colorScheme.primary.withOpacity(0.08);
    final selectedIconColor = Theme.of(context).colorScheme.primary;
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: kPrimary),
              child: Row(
                children: [
                  const PFLogo(size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Parking Flow', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          UserData.name ?? 'Guest',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_rounded),
              title: const Text('Dashboard'),
              selected: _currentIndex == 0,
              selectedTileColor: selectedColor,
              iconColor: _currentIndex == 0 ? selectedIconColor : null,
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.map_rounded),
              title: const Text('Parking Map'),
              selected: _currentIndex == 1,
              selectedTileColor: selectedColor,
              iconColor: _currentIndex == 1 ? selectedIconColor : null,
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search Locations'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationSearchScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_note_rounded),
              title: const Text('Booking History'),
              selected: _currentIndex == 2,
              selectedTileColor: selectedColor,
              iconColor: _currentIndex == 2 ? selectedIconColor : null,
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              selected: _currentIndex == 3,
              selectedTileColor: selectedColor,
              iconColor: _currentIndex == 3 ? selectedIconColor : null,
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 3);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.book_online),
              title: const Text('My Reservations'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyReservationsScreen(activeReservations: _activeReservations),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner_rounded),
              title: const Text('QR Code'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QrCodeScreen(
                      reservation: _activeReservations.isNotEmpty ? _activeReservations[0] : {},
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.hourglass_top_rounded),
              title: const Text('Waitlist'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WaitlistScreen()),
                );
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                // TODO: hook into auth sign-out flow if available
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out')),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'v1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab(BuildContext context) {
    final userName = UserData.name ?? 'User'; // Added null check
    final currentHour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (currentHour >= 12 && currentHour < 17) {
      greeting = 'Good Afternoon';
    } else if (currentHour >= 17) {
      greeting = 'Good Evening';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: _slideAnimation.value * 30,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: kPrimaryLight,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          spreadRadius: 0,
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.white.withOpacity(0.25),
                              foregroundImage: _avatarImageProvider(),
                              child: const Icon(Icons.person, color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$greeting,', style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
                                  Text(userName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.local_parking_rounded, color: Colors.white, size: 22),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (_, animation, __) => ParkingMapScreen(),
                                transitionsBuilder: (_, animation, __, child) {
                                  final offsetAnimation = Tween<Offset>(
                                    begin: const Offset(1.0, 0.0),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
                                  return SlideTransition(position: offsetAnimation, child: child);
                                },
                                transitionDuration: const Duration(milliseconds: 350),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.12),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on_rounded, color: Colors.white70, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Available slots nearby',
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(color: kSuccess, borderRadius: BorderRadius.circular(20)),
                                  child: Text(
                                    '${_parkingStats['available']} available',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          
          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Slots',
                  _parkingStats['total'].toString(),
                  kPrimary,
                  Icons.local_parking_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Occupied',
                  _parkingStats['occupied'].toString(),
                  kDanger,
                  Icons.directions_car_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Available',
                  _parkingStats['available'].toString(),
                  kSuccess,
                  Icons.check_circle_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Quick Actions Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        'My Reservations',
                        Icons.event_note_rounded,
                        kPrimary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyReservationsScreen(
                                activeReservations: _activeReservations,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionCard(
                        'Find Parking',
                        Icons.location_on_rounded,
                        kSuccess,
                        () {
                          setState(() {
                            _currentIndex = 1;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionCard(
                        'QR Code',
                        Icons.qr_code_scanner_rounded,
                        kWarning,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QrCodeScreen(
                                  reservation: _activeReservations.isNotEmpty
                                      ? _activeReservations[0]
                                      : {}),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Weather and Waitlist Row
          Row(
            children: [
              Expanded(child: _buildWeatherWidget()),
              const SizedBox(width: 12),
              Expanded(child: _buildWaitlistButton()),
            ],
          ),
          const SizedBox(height: 20),

          // Active Reservations
          _buildActiveReservations(),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value * 10,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherWidget() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value * 10,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          (_currentWeatherText ?? 'Clear').contains('Rain')
                              ? Icons.umbrella_rounded
                              : (_currentWeatherText ?? 'Clear').contains('Cloud')
                                  ? Icons.cloud_rounded
                                  : Icons.wb_sunny_rounded,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Weather',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          DateFormat('EEE, MMM d • h:mm a').format(_lastWeatherUpdated),
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _currentTempC != null ? '${_currentTempC!.toStringAsFixed(0)}°C' : '--°C',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  Text(
                    _currentWeatherText ?? 'Fetching...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        tooltip: 'Refresh weather',
                        onPressed: _fetchWeather,
                        icon: const Icon(Icons.refresh, size: 18, color: Colors.grey),
                      ),
                      Text('Refresh', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(width: 4),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaitlistButton() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value * 10,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WaitlistScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.hourglass_top_rounded,
                            color: Colors.purple,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Waitlist',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Join Now',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveReservations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Reservations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        _activeReservations.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'No active reservations',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _activeReservations.length,
                itemBuilder: (context, index) {
                  final reservation = _activeReservations[index];
                  return _buildReservationCard(reservation);
                },
              ),
      ],
    );
  }

  Widget _buildReservationCard(Map<String, dynamic> reservation) {
    final formattedDate = DateFormat.MMMd().format(reservation['date']);

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value * 10,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    FutureBuilder<String>(
                      future: _bestLocationImagePath(reservation),
                      builder: (context, snap) {
                        final path = snap.data;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: path == null
                              ? Container(
                                  width: 48,
                                  height: 48,
                                  color: Colors.grey.withOpacity(0.1),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.location_on_rounded, color: Colors.grey, size: 20),
                                )
                              : Image.asset(
                                  path,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stack) => Container(
                                    width: 48,
                                    height: 48,
                                    color: Colors.grey.withOpacity(0.1),
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.location_on_rounded, color: Colors.grey, size: 20),
                                  ),
                                ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Builder(
                            builder: (_) {
                              final loc = _parseLocation(
                                reservation['location'],
                                name: reservation['locationName'],
                                area: reservation['locationArea'],
                              );
                              final name = loc['name'] ?? '';
                              return Text(
                                name.isNotEmpty ? name : 'Slot ${_formatSlot(reservation['slotNumber'])}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF1a1a1a),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Slot: ${_formatSlot(reservation['slotNumber'])}',
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$formattedDate • ${reservation['startTime']} - ${reservation['endTime']}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: kSuccess.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Active',
                              style: TextStyle(
                                color: kSuccess,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: kWarning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: kWarning,
                          size: 20,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QrCodeScreen(reservation: reservation),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildDashboardTab(context),
      ParkingMapScreen(showAppBar: false),
      BookingHistoryScreen(),
      const ProfileScreen(),
    ];
    final List<String> titles = const [
      'Dashboard',
      'Parking Map',
      'History',
      'Profile',
    ];

    final bool isWide = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kPrimary,
        title: Text(
          titles[_currentIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        leading: isWide
            ? Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const PFLogo(size: 24),
              )
            : IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                setState(() {
                  _currentIndex = 3; // Navigate to Profile tab
                });
              },
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.9), width: 2),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundImage: _avatarImageProvider(),
                  child: _avatarImageProvider() == null
                      ? Text(
                          _userInitials(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: isWide ? null : _buildSidebar(context),
      body: isWide
          ? Row(
              children: [
                _buildNavRail(),
                const VerticalDivider(width: 1),
                Expanded(child: screens[_currentIndex]),
              ],
            )
          : screens[_currentIndex],
      bottomNavigationBar: isWide
          ? null
          : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard_rounded),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.location_on_rounded),
                    label: 'Parking',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.event_note_rounded),
                    label: 'History',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    label: 'Profile',
                  ),
                ],
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: kPrimary,
                unselectedItemColor: Colors.grey[600]!,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
    );
  }

  Widget _buildNavRail() {
    return NavigationRail(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) => setState(() => _currentIndex = index),
      labelType: NavigationRailLabelType.all,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: const PFLogo(size: 32),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map_rounded),
          label: Text('Parking'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.event_note_outlined),
          selectedIcon: Icon(Icons.event_note_rounded),
          label: Text('History'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: Text('Profile'),
        ),
      ],
    );
  }
    }
    