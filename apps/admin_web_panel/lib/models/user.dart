/// Modelo que representa um usuário passageiro no sistema.
class User {
  final String id;
  final String email;
  final String name;
  final String phoneNumber;
  final String profileImageUrl;
  final double rating;
  final int totalRides;
  final DateTime createdAt;
  final DateTime? lastActive;
  final bool isActive;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.profileImageUrl,
    required this.rating,
    required this.totalRides,
    required this.createdAt,
    this.lastActive,
    required this.isActive,
  });

  /// Converte um User para um Map (útil para salvar no Firestore).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'rating': rating,
      'totalRides': totalRides,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive?.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Cria um User a partir de um Map (útil para ler do Firestore).
  factory User.fromMap(Map<String, dynamic> map, String documentId) {
    return User(
      id: documentId,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      totalRides: map['totalRides'] ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      lastActive: map['lastActive'] != null
          ? DateTime.parse(map['lastActive'])
          : null,
      isActive: map['isActive'] ?? true,
    );
  }

  /// Cria uma cópia do User com campos opcionais atualizados.
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
    double? rating,
    int? totalRides,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, totalRides: $totalRides, rating: $rating)';
  }
}
