import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';
import 'auth/login_screen.dart';
import 'dashboard_screen.dart';
import 'payment_screen.dart';
import 'reservation/booking_history_screen.dart';
import 'notification_screen.dart';
import '../Models/user_data.dart';
import 'legal/privacy_policy_screen.dart';
import 'legal/terms_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  // Navy blue theme colors to match the design
  static const Color primaryColor =
      Color.fromARGB(255, 12, 36, 102); // Navy blue primary
  static const Color secondaryColor = Color(0xFF3B82F6); // Blue secondary
  static const Color backgroundColor = Colors.white; // White background
  static const Color cardColor = Colors.white; // White cards
  static const Color textColor = Color(0xFF1F2937); // Dark text
  static const Color textSecondaryColor = Color(0xFF6B7280); // Gray text
  // Professional accent (charm) for action tiles
  static const Color charm = Color(0xFF8B5CF6); // Violet

  Map<String, dynamic> _userProfile = {};
  bool _isEditing = false;
  String? _profileImagePath;
  Uint8List? _profileImageBytes;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _pushEnabled = false;

  // Notification data
  final List<Map<String, dynamic>> _notifications = [
    {
      'date': 'Today',
      'items': [
        {
          'title': 'Meeting Zoom Call',
          'description': 'Landing page Admin Panel Meeting.',
          'time': '10:30 AM',
        },
        {
          'title': 'Task Complete',
          'description': 'You have successfully completed your task.',
          'time': '09:15 AM',
        },
      ],
    },
    {
      'date': 'Yesterday',
      'items': [
        {
          'title': 'Progress Report',
          'description': 'Progress rate for your task see your task..',
          'time': '04:45 PM',
        },
        {
          'title': 'Task Complete',
          'description': 'You have successfully completed your task.',
          'time': '02:30 PM',
        },
        {
          'title': 'Update App',
          'description': 'John has made a payment on helical.',
          'time': '11:20 AM',
        },
      ],
    },
    {
      'date': '28 June, 2025',
      'items': [
        {
          'title': 'Al Create Task',
          'description': 'You have successfully completed your task.',
          'time': '03:15 PM',
          'isImportant': true,
        },
        {
          'title': 'Update App',
          'description': 'John has made a payment on helical.',
          'time': '10:45 AM',
          'isImportant': true,
        },
      ],
    },
  ];

  int _currentTabIndex = 0; // 0 for Notifications, 1 for Profile

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserData();
    _initializeAnimations();
    _initNotifications();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
    _animationController.repeat();
  }

  void _initNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool('pushEnabled') ?? false;
    setState(() {
      _pushEnabled = saved;
    });
  }

  void _onTogglePush(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _pushEnabled = value);
    await prefs.setBool('pushEnabled', value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value
            ? 'Push notifications turned on'
            : 'Push notifications turned off'),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _animationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _loadUserData() async {
    final result = await UserService.getProfile();
    if (result['success']) {
      final data = result['data'];
      setState(() {
        _userProfile = data;
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
      });

      _syncVehiclesFromBackend(data);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to load profile')),
      );
    }
  }

  void _syncVehiclesFromBackend(Map<String, dynamic> data) {
    final vn = data['vehicle_number'];
    final vt = data['vehicle_type'];

    if (vn != null &&
        vn is String &&
        vn.isNotEmpty &&
        vn != 'N/A' &&
        vt != null &&
        vt is String &&
        vt.isNotEmpty &&
        vt != 'N/A') {
      UserData.setVehicles([
        {
          'plate_number': vn,
          'type': vt,
          'is_primary': true,
          'id': '1',
        }
      ]);
    } else {
      UserData.setVehicles([]);
    }
  }

  // Pick profile image from gallery
  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    try {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        if (bytes.isEmpty) throw Exception('Selected image is empty');
        setState(() {
          _profileImageBytes = bytes;
          _profileImagePath = null;
        });
        UserData.setProfileImageBase64(base64Encode(bytes));
        UserData.setProfileImage(null);
      } else {
        setState(() {
          _profileImagePath = image.path;
          _profileImageBytes = null;
        });
        UserData.setProfileImage(image.path);
        final bytes = await File(image.path).readAsBytes();
        if (bytes.isNotEmpty) {
          UserData.setProfileImageBase64(base64Encode(bytes));
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Profile picture updated successfully'),
              ],
            ),
            backgroundColor: secondaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile picture: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  ImageProvider _buildProfileImageProvider() {
    if (kIsWeb) {
      if (_profileImageBytes != null && _profileImageBytes!.isNotEmpty) {
        return MemoryImage(_profileImageBytes!);
      }
      final base64Data = UserData.getProfileImageBase64();
      if (base64Data != null && base64Data.isNotEmpty) {
        try {
          return MemoryImage(base64Decode(base64Data));
        } catch (_) {}
      }
      return const AssetImage('assets/images/avatar_placeholder.png');
    }

    if (_profileImagePath != null && _profileImagePath!.isNotEmpty) {
      try {
        return FileImage(File(_profileImagePath!));
      } catch (_) {}
    }
    final base64Data = UserData.getProfileImageBase64();
    if (base64Data != null && base64Data.isNotEmpty) {
      try {
        return MemoryImage(base64Decode(base64Data));
      } catch (_) {}
    }
    final path = UserData.getProfileImage();
    try {
      if (path != null && path.isNotEmpty && File(path).existsSync()) {
        return FileImage(File(path));
      }
    } catch (_) {}
    return const AssetImage('assets/images/avatar_placeholder.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cardColor,
        foregroundColor: textColor,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: textColor),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: textColor),
            onPressed: _navigateToNotifications,
          ),
        ],
      ),
      body: _buildProfileTab(),
    );
  }

  Widget _buildNotificationsTab() {
    return ListView.builder(
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notificationGroup = _notifications[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                notificationGroup['date'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...notificationGroup['items'].map<Widget>((item) {
              return _buildNotificationItem(item);
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: item['isImportant'] == true
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: item['isImportant'] == true
                        ? Colors.blue
                        : Colors.black,
                  ),
                ),
              ),
              Text(
                item['time'],
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item['description'],
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildStatsCards(),
          const SizedBox(height: 24),
          _buildPersonalInfoCard(),
          const SizedBox(height: 24),
          _buildQuickActionsGrid(),
          const SizedBox(height: 24),
          _buildSettingsCard(),
          const SizedBox(height: 24),
          _buildLogoutButton(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return AnimatedBuilder(
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
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, primaryColor],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: _buildProfileImageProvider(),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickProfileImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: secondaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hello, ${(_userProfile['name'] ?? '')}! 👋',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _userProfile['email'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
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

  Widget _buildStatsCards() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value * 20,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Bookings',
                    '24',
                    Icons.event_note_rounded,
                    primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Saved Spots',
                    '8',
                    Icons.bookmark_rounded,
                    primaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value * 20,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: _isEditing ? secondaryColor : primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isEditing
                                  ? Icons.save_rounded
                                  : Icons.edit_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: _isEditing ? _saveInfo : _editInfo,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildModernField(
                      label: 'Full Name',
                      icon: Icons.person_outline_rounded,
                      controller: _nameController,
                    ),
                    const SizedBox(height: 16),
                    _buildModernField(
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 16),
                    _buildModernField(
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      controller: _phoneController,
                    ),
                    const SizedBox(height: 16),
                    _buildVehicleSection(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _isEditing ? Colors.white : Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isEditing
                  ? primaryColor.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: TextFormField(
            controller: controller,
            enabled: _isEditing,
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: primaryColor, size: 20),
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleSection() {
    final primary = UserData.getPrimaryVehicle();
    final others =
        UserData.vehicles.where((v) => v['is_primary'] != true).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vehicle Registration',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Primary (non-editable)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.directions_car_rounded, color: primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Primary Registration',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      primary != null ? primary['plate_number'] : 'Not set',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Primary', style: TextStyle(color: primaryColor)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Additional vehicles list
        if (others.isNotEmpty)
          ...others.map((v) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_offer_outlined, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        v['plate_number'],
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        UserData.removeVehicle(v['id']);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              )),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _showAddVehicleDialog,
            style: TextButton.styleFrom(
              backgroundColor: secondaryColor.withOpacity(0.1),
              foregroundColor: secondaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add Vehicle'),
          ),
        ),
      ],
    );
  }

  void _showAddVehicleDialog() {
    final plateController = TextEditingController();
    String type = 'Car';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Vehicle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: plateController,
                decoration: const InputDecoration(
                  labelText: 'Registration Number',
                  hintText: 'e.g. CAE-4326',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: 'Car', child: Text('Car')),
                  DropdownMenuItem(value: 'Jeep', child: Text('Jeep')),
                  DropdownMenuItem(value: 'Van', child: Text('Van')),
                  DropdownMenuItem(value: 'Bike', child: Text('Bike')),
                ],
                onChanged: (v) => type = v ?? 'Car',
                decoration: const InputDecoration(labelText: 'Type'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final plate = plateController.text.trim();
                if (plate.isEmpty) return;
                UserData.addVehicle({
                  'plate_number': plate,
                  'type': type,
                });
                setState(() {});
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vehicle added')),
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActionsGrid() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value * 20,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        'Payment Methods',
                        Icons.payment_rounded,
                        const Color.fromARGB(255, 28, 68, 124),
                        () => _navigateToPayment(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionCard(
                        'Booking History',
                        Icons.history_rounded,
                        const Color.fromARGB(255, 28, 68, 124),
                        () => _navigateToHistory(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        'Notifications',
                        Icons.notifications_rounded,
                        const Color.fromARGB(255, 28, 68, 124),
                        () => _navigateToNotifications(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionCard(
                        'Settings',
                        Icons.settings_rounded,
                        const Color.fromARGB(255, 28, 68, 124),
                        () => _navigateToSettings(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
            offset: _slideAnimation.value * 20,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Preferences',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildPreferenceItem(
                        'Dark Mode',
                        'Switch to dark theme',
                        Icons.dark_mode_rounded,
                        false,
                        (value) {},
                      ),
                      const SizedBox(height: 16),
                      _buildPreferenceItem(
                        'Push Notifications',
                        'Receive parking updates',
                        Icons.notifications_active_rounded,
                        _pushEnabled,
                        _onTogglePush,
                      ),
                      const SizedBox(height: 16),
                      _buildPreferenceItem(
                        'Location Services',
                        'Enable GPS tracking',
                        Icons.location_on_rounded,
                        true,
                        (value) {},
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrivacyPolicyScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.privacy_tip_outlined),
                        label: const Text('Privacy Policy'),
                        style: TextButton.styleFrom(
                          foregroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TermsAndConditionsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.article_outlined),
                        label: const Text('Terms & Conditions'),
                        style: TextButton.styleFrom(
                          foregroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
      },
    );
  }

  Widget _buildPreferenceItem(String title, String subtitle, IconData icon,
      bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value * 20,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  shadowColor: Colors.red.withOpacity(0.3),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  'Log Out',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PaymentScreen(),
      ),
    );
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BookingHistoryScreen(),
      ),
    );
  }

  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationScreen(),
      ),
    );
  }

  void _editInfo() {
    setState(() {
      _isEditing = true;
    });
  }

  void _saveInfo() async {
    setState(() => _isEditing = false);

    final primaryVehicle = UserData.getPrimaryVehicle();
    final result = await UserService.updateProfile(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      vehicleNumber: primaryVehicle?['plate_number'],
      vehicleType: primaryVehicle?['type'],
    );

    if (result['success']) {
      final newData = result['data'];
      setState(() {
        _userProfile = newData;
        _nameController.text = newData['name'] ?? '';
        _emailController.text = newData['email'] ?? '';
        _phoneController.text = newData['phone'] ?? '';
      });

      _syncVehiclesFromBackend(newData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } else {
      // Revert on failure
      setState(() {
        _isEditing = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Update failed')),
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: primaryColor,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Are you sure you want to log out?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          UserData.clearUserData();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Log Out',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToSettings() {}
}
