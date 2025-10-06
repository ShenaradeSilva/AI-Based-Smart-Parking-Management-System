class UserData {
  // ---------------- Core user data ----------------
  static Map<String, dynamic> _userData = {
    'name': 'John David',
    'email': 'johndavid@gmail.com',
    'phone': '+94 765923452',
    'vehicle': 'CAE-4326', // Legacy field - kept for backward compatibility
    'license': 'D123456789',
    'profileImage': null, // file path (mobile/desktop)
    'profileImageBase64': null, // base64-encoded bytes (web-safe)
    'vehicles': [
      {
        'id': '1',
        'plate_number': 'CAE-4326',
        'type': 'Sedan',
        'is_primary': true,
      }
    ],
  };

  // ---------------- User session token (nullable for guests) ----------------
  static String? token;

  // ---------------- Getters ----------------
  static Map<String, dynamic> get userData => _userData;

  static String get name => _userData['name'] ?? 'User';
  static String get email => _userData['email'] ?? '';
  static String get phone => _userData['phone'] ?? '';
  static String get vehicle => _userData['vehicle'] ?? '';
  static List<Map<String, dynamic>> get vehicles =>
      List<Map<String, dynamic>>.from(_userData['vehicles'] ?? []);

  static Map<String, dynamic>? getPrimaryVehicle() {
    final vehiclesList = vehicles;
    return vehiclesList.isNotEmpty
        ? vehiclesList.firstWhere(
            (v) => v['is_primary'] == true,
            orElse: () => vehiclesList.first)
        : null;
  }

  static String? getProfileImage() => _userData['profileImage'];
  static String? getProfileImageBase64() => _userData['profileImageBase64'];

  // ---------------- Setters / Updaters ----------------
  static void updateUserData(Map<String, dynamic> newData) {
    _userData.addAll(newData);
  }

  static void addVehicle(Map<String, dynamic> vehicle) {
    final vehiclesList = vehicles;

    if (vehiclesList.isEmpty) {
      vehicle['is_primary'] = true;
    } else {
      vehicle['is_primary'] = false;
    }

    if (!vehicle.containsKey('id')) {
      vehicle['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    }

    vehiclesList.add(vehicle);
    _userData['vehicles'] = vehiclesList;

    final primaryVehicle = getPrimaryVehicle();
    if (primaryVehicle != null) {
      _userData['vehicle'] = primaryVehicle['plate_number'];
    }
  }

  static void updateVehicle(String id, Map<String, dynamic> updates) {
    final vehiclesList = vehicles;
    final index = vehiclesList.indexWhere((v) => v['id'] == id);

    if (index != -1) {
      updates.remove('is_primary');

      if (vehiclesList[index]['is_primary'] == true &&
          updates.containsKey('plate_number')) {
        updates.remove('plate_number');
      }

      vehiclesList[index] = {...vehiclesList[index], ...updates};
      _userData['vehicles'] = vehiclesList;

      if (vehiclesList[index]['is_primary'] == true) {
        _userData['vehicle'] = vehiclesList[index]['plate_number'];
      }
    }
  }

  static void removeVehicle(String id) {
    final vehiclesList = vehicles;
    final index = vehiclesList.indexWhere((v) => v['id'] == id);

    if (index != -1 && vehiclesList[index]['is_primary'] != true) {
      vehiclesList.removeAt(index);
      _userData['vehicles'] = vehiclesList;
    }
  }

  static void setPrimaryVehicle(String id) {
    final vehiclesList = vehicles;

    for (var vehicle in vehiclesList) {
      vehicle['is_primary'] = false;
    }

    final index = vehiclesList.indexWhere((v) => v['id'] == id);
    if (index != -1) {
      vehiclesList[index]['is_primary'] = true;
      _userData['vehicle'] = vehiclesList[index]['plate_number'];
    }

    _userData['vehicles'] = vehiclesList;
  }

  static void setVehicles(List<Map<String, dynamic>> vehicleList) {
    final vehiclesWithId = vehicleList.map((v) {
      final vehicle = Map<String, dynamic>.from(v);
      if (!vehicle.containsKey('id')) {
        vehicle['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      }
      return vehicle;
    }).toList();

    _userData['vehicles'] = vehiclesWithId;

    final primary = getPrimaryVehicle();
    if (primary != null) {
      _userData['vehicle'] = primary['plate_number'];
    }
  }

  static void setProfileImage(String? imagePath) {
    _userData['profileImage'] = imagePath;
  }

  static void setProfileImageBase64(String? base64) {
    _userData['profileImageBase64'] = base64;
  }

  static void setToken(String? userToken) {
    token = userToken;
  }

  // ---------------- Clear all user data ----------------
  static void clearUserData() {
    _userData = {
      'name': 'John David',
      'email': 'johndavid@gmail.com',
      'phone': '+94 765923452',
      'vehicle': 'CAE-4326',
      'license': 'D123456789',
      'profileImage': null,
      'profileImageBase64': null,
      'vehicles': [
        {
          'id': '1',
          'plate_number': 'CAE-4326',
          'type': 'Sedan',
          'is_primary': true,
        }
      ],
    };
    token = null;
  }

  // ---------------- Preferences (Optional) ----------------
  static dynamic getPreference(String key, {dynamic defaultValue}) {
    return _userData[key] ?? defaultValue;
  }

  static void setPreference(String key, dynamic value) {
    _userData[key] = value;
  }
}
