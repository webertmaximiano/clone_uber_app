/// Modelo que representa um usuário admin.
class AdminUser {
  final String id;
  final String email;
  final String name;
  final String role; // 'admin', 'moderator', etc.
  final DateTime createdAt;
  final DateTime? lastLogin;

  AdminUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    this.lastLogin,
  });

  /// Converte um AdminUser para um Map (útil para salvar no Firestore).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  /// Cria um AdminUser a partir de um Map (útil para ler do Firestore).
  factory AdminUser.fromMap(Map<String, dynamic> map, String documentId) {
    return AdminUser(
      id: documentId,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'admin',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      lastLogin: map['lastLogin'] != null
          ? DateTime.parse(map['lastLogin'])
          : null,
    );
  }

  /// Cria uma cópia do AdminUser com campos opcionais atualizados.
  AdminUser copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return AdminUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  String toString() {
    return 'AdminUser(id: $id, email: $email, name: $name, role: $role)';
  }
}
