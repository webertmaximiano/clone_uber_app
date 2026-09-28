/// Modelo que representa um motorista no sistema.
class Driver {
  final String id;
  final String email;
  final String name;
  final String phoneNumber;
  final String profileImageUrl;
  final String vehicleType;
  final String licensePlate;
  final double rating;
  final int totalRides;
  final int totalEarnings;
  final DateTime createdAt;
  final DateTime? lastActive;
  final bool isActive;
  final bool isOnline;
  final double? currentLatitude;
  final double? currentLongitude;

  Driver({
    required this.id,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.profileImageUrl,
    required this.vehicleType,
    required this.licensePlate,
    required this.rating,
    required this.totalRides,
    required this.totalEarnings,
    required this.createdAt,
    this.lastActive,
    required this.isActive,
    required this.isOnline,
    this.currentLatitude,
    this.currentLongitude,
  });

  /// Converte um Driver para um Map (útil para salvar no Firestore).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'vehicleType': vehicleType,
      'licensePlate': licensePlate,
      'rating': rating,
      'totalRides': totalRides,
      'totalEarnings': totalEarnings,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive?.toIso8601String(),
      'isActive': isActive,
      'isOnline': isOnline,
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
    };
  }

  /// Cria um Driver a partir de um Map (útil para ler do Firestore).
  factory Driver.fromMap(Map<String, dynamic> map, String documentId) {
    return Driver(
      id: documentId,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      vehicleType: map['vehicleType'] ?? '',
      licensePlate: map['licensePlate'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      totalRides: map['totalRides'] ?? 0,
      totalEarnings: map['totalEarnings'] ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      lastActive: map['lastActive'] != null
          ? DateTime.parse(map['lastActive'])
          : null,
      isActive: map['isActive'] ?? true,
      isOnline: map['isOnline'] ?? false,
      currentLatitude: (map['currentLatitude'] as num?)?.toDouble(),
      currentLongitude: (map['currentLongitude'] as num?)?.toDouble(),
    );
  }

  /// Cria uma cópia do Driver com campos opcionais atualizados.
  Driver copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
    String? vehicleType,
    String? licensePlate,
    double? rating,
    int? totalRides,
    int? totalEarnings,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? isActive,
    bool? isOnline,
    double? currentLatitude,
    double? currentLongitude,
  }) {
    return Driver(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      vehicleType: vehicleType ?? this.vehicleType,
      licensePlate: licensePlate ?? this.licensePlate,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      isActive: isActive ?? this.isActive,
      isOnline: isOnline ?? this.isOnline,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
    );
  }

  @override
  String toString() {
    return 'Driver(id: $id, email: $email, name: $name, totalRides: $totalRides, rating: $rating, isOnline: $isOnline)';
  }
}
