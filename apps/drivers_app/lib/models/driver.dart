class Driver {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final String vehicleType; // bike, car, van
  final String vehiclePlate;
  final double rating; // 1-5 stars
  final int totalRides;
  final bool isOnline;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  Driver({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.vehicleType,
    required this.vehiclePlate,
    this.rating = 5.0,
    this.totalRides = 0,
    this.isOnline = false,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  // Converter para Map (para Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'vehicleType': vehicleType,
      'vehiclePlate': vehiclePlate,
      'rating': rating,
      'totalRides': totalRides,
      'isOnline': isOnline,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Converter de Map (do Firestore)
  factory Driver.fromMap(Map<String, dynamic> map, String id) {
    return Driver(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      vehicleType: map['vehicleType'] ?? 'car',
      vehiclePlate: map['vehiclePlate'] ?? '',
      rating: (map['rating'] ?? 5.0).toDouble(),
      totalRides: map['totalRides'] ?? 0,
      isOnline: map['isOnline'] ?? false,
      latitude: map['latitude'],
      longitude: map['longitude'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Driver{id: $id, name: $name, email: $email, vehicleType: $vehicleType, '
        'vehiclePlate: $vehiclePlate, rating: $rating, isOnline: $isOnline}';
  }
}
