class UserData {
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

  static Map<String, dynamic> get userData => _userData;

  static String get name => _userData['name'] ?? 'User';

  static String get email => _userData['email'] ?? '';

  static String get phone => _userData['phone'] ?? '';

  static String get vehicle => _userData['vehicle'] ?? '';

  static void updateUserData(Map<String, dynamic> newData) {
    _userData.addAll(newData);
  }

  static List<Map<String, dynamic>> get vehicles {
    return List<Map<String, dynamic>>.from(_userData['vehicles'] ?? []);
  }

  static Map<String, dynamic>? getPrimaryVehicle() {
    final vehiclesList = vehicles;
    return vehiclesList.isNotEmpty
        ? vehiclesList.firstWhere((v) => v['is_primary'] == true,
            orElse: () => vehiclesList.first)
        : null;
  }

  static void addVehicle(Map<String, dynamic> vehicle) {
    final vehiclesList = vehicles;

    // If this is the first vehicle, mark it as primary
    if (vehiclesList.isEmpty) {
      vehicle['is_primary'] = true;
    } else {
      vehicle['is_primary'] = false;
    }

    // Generate a unique ID if not provided
    if (!vehicle.containsKey('id')) {
      vehicle['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    }

    vehiclesList.add(vehicle);
    _userData['vehicles'] = vehiclesList;

    // Update the legacy vehicle field with the primary vehicle's plate number
    final primaryVehicle = getPrimaryVehicle();
    if (primaryVehicle != null) {
      _userData['vehicle'] = primaryVehicle['plate_number'];
    }
  }

  static void updateVehicle(String id, Map<String, dynamic> updates) {
    final vehiclesList = vehicles;
    final index = vehiclesList.indexWhere((v) => v['id'] == id);

    if (index != -1) {
      // Don't allow changing is_primary status through this method
      updates.remove('is_primary');

      // Don't allow updating primary vehicle's plate number
      if (vehiclesList[index]['is_primary'] == true &&
          updates.containsKey('plate_number')) {
        // Remove plate_number from updates for primary vehicle
        updates.remove('plate_number');
      }

      vehiclesList[index] = {...vehiclesList[index], ...updates};
      _userData['vehicles'] = vehiclesList;

      // Update the legacy vehicle field if this is the primary vehicle and we're updating other fields
      if (vehiclesList[index]['is_primary'] == true) {
        _userData['vehicle'] = vehiclesList[index]['plate_number'];
      }
    }
  }

  static void removeVehicle(String id) {
    final vehiclesList = vehicles;
    final index = vehiclesList.indexWhere((v) => v['id'] == id);

    if (index != -1) {
      // Don't allow removing primary vehicle
      if (vehiclesList[index]['is_primary'] == true) {
        return;
      }

      vehiclesList.removeAt(index);
      _userData['vehicles'] = vehiclesList;
    }
  }

  static void setPrimaryVehicle(String id) {
    final vehiclesList = vehicles;

    // First set all vehicles to non-primary
    for (var vehicle in vehiclesList) {
      vehicle['is_primary'] = false;
    }

    // Then set the selected vehicle as primary
    final index = vehiclesList.indexWhere((v) => v['id'] == id);
    if (index != -1) {
      vehiclesList[index]['is_primary'] = true;
      _userData['vehicle'] = vehiclesList[index]['plate_number'];
    }

    _userData['vehicles'] = vehiclesList;
  }

  static void setVehicles(List<Map<String, dynamic>> vehicleList) {
    // Ensure each vehicle has an 'id'
    final vehiclesWithId = vehicleList.map((v) {
      final vehicle = Map<String, dynamic>.from(v);
      if (!vehicle.containsKey('id')) {
        vehicle['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      }
      return vehicle;
    }).toList();

    _userData['vehicles'] = vehiclesWithId;

    // Update legacy 'vehicle' field with primary plate number
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

  static String? getProfileImage() {
    return _userData['profileImage'];
  }

  static String? getProfileImageBase64() {
    return _userData['profileImageBase64'];
  }

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
  }

  static getPreference(String s, bool value) {}
}
