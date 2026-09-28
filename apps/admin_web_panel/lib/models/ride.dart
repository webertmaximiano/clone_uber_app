/// Modelo que representa uma corrida no sistema.
class Ride {
  final String id;
  final String userId;
  final String? driverId;
  final String originAddress;
  final String destinationAddress;
  final double originLatitude;
  final double originLongitude;
  final double destinationLatitude;
  final double destinationLongitude;
  final String status; // 'pending', 'accepted', 'in_progress', 'completed', 'cancelled'
  final double fare;
  final double distance;
  final int estimatedDuration; // em minutos
  final int actualDuration; // em minutos (null se não concluído)
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double? userRating;
  final double? driverRating;

  Ride({
    required this.id,
    required this.userId,
    this.driverId,
    required this.originAddress,
    required this.destinationAddress,
    required this.originLatitude,
    required this.originLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.status,
    required this.fare,
    required this.distance,
    required this.estimatedDuration,
    required this.actualDuration,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.userRating,
    this.driverRating,
  });

  /// Converte um Ride para um Map (útil para salvar no Firestore).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'driverId': driverId,
      'originAddress': originAddress,
      'destinationAddress': destinationAddress,
      'originLatitude': originLatitude,
      'originLongitude': originLongitude,
      'destinationLatitude': destinationLatitude,
      'destinationLongitude': destinationLongitude,
      'status': status,
      'fare': fare,
      'distance': distance,
      'estimatedDuration': estimatedDuration,
      'actualDuration': actualDuration,
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'userRating': userRating,
      'driverRating': driverRating,
    };
  }

  /// Cria um Ride a partir de um Map (útil para ler do Firestore).
  factory Ride.fromMap(Map<String, dynamic> map, String documentId) {
    return Ride(
      id: documentId,
      userId: map['userId'] ?? '',
      driverId: map['driverId'],
      originAddress: map['originAddress'] ?? '',
      destinationAddress: map['destinationAddress'] ?? '',
      originLatitude: (map['originLatitude'] ?? 0).toDouble(),
      originLongitude: (map['originLongitude'] ?? 0).toDouble(),
      destinationLatitude: (map['destinationLatitude'] ?? 0).toDouble(),
      destinationLongitude: (map['destinationLongitude'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      fare: (map['fare'] ?? 0).toDouble(),
      distance: (map['distance'] ?? 0).toDouble(),
      estimatedDuration: map['estimatedDuration'] ?? 0,
      actualDuration: map['actualDuration'] ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      startedAt: map['startedAt'] != null ? DateTime.parse(map['startedAt']) : null,
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
      userRating: (map['userRating'] as num?)?.toDouble(),
      driverRating: (map['driverRating'] as num?)?.toDouble(),
    );
  }

  /// Cria uma cópia do Ride com campos opcionais atualizados.
  Ride copyWith({
    String? id,
    String? userId,
    String? driverId,
    String? originAddress,
    String? destinationAddress,
    double? originLatitude,
    double? originLongitude,
    double? destinationLatitude,
    double? destinationLongitude,
    String? status,
    double? fare,
    double? distance,
    int? estimatedDuration,
    int? actualDuration,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    double? userRating,
    double? driverRating,
  }) {
    return Ride(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      driverId: driverId ?? this.driverId,
      originAddress: originAddress ?? this.originAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      originLatitude: originLatitude ?? this.originLatitude,
      originLongitude: originLongitude ?? this.originLongitude,
      destinationLatitude: destinationLatitude ?? this.destinationLatitude,
      destinationLongitude: destinationLongitude ?? this.destinationLongitude,
      status: status ?? this.status,
      fare: fare ?? this.fare,
      distance: distance ?? this.distance,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      userRating: userRating ?? this.userRating,
      driverRating: driverRating ?? this.driverRating,
    );
  }

  @override
  String toString() {
    return 'Ride(id: $id, status: $status, fare: $fare, distance: $distance)';
  }
}
