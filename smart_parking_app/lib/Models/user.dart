class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String vehicleNumber;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.vehicleNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'vehicleNumber': vehicleNumber,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      vehicleNumber: json['vehicleNumber'],
    );
  }
}