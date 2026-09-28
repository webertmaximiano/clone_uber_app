class RideRequest {
  final String id;
  final String userId;
  final String? driverId;
  final String originAddress;
  final double originLatitude;
  final double originLongitude;
  final String destinationAddress;
  final double destinationLatitude;
  final double destinationLongitude;
  final double estimatedDistance;
  final double estimatedFare;
  final String rideType; // economy, comfort, executive
  final String status; // pending, assigned, in_progress, completed, cancelled
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int estimatedDurationMinutes;

  RideRequest({
    required this.id,
    required this.userId,
    this.driverId,
    required this.originAddress,
    required this.originLatitude,
    required this.originLongitude,
    required this.destinationAddress,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.estimatedDistance,
    required this.estimatedFare,
    required this.rideType,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    required this.estimatedDurationMinutes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'driverId': driverId,
      'originAddress': originAddress,
      'originLatitude': originLatitude,
      'originLongitude': originLongitude,
      'destinationAddress': destinationAddress,
      'destinationLatitude': destinationLatitude,
      'destinationLongitude': destinationLongitude,
      'estimatedDistance': estimatedDistance,
      'estimatedFare': estimatedFare,
      'rideType': rideType,
      'status': status,
      'createdAt': createdAt,
      'startedAt': startedAt,
      'completedAt': completedAt,
      'estimatedDurationMinutes': estimatedDurationMinutes,
    };
  }

  factory RideRequest.fromMap(Map<String, dynamic> map, String id) {
    return RideRequest(
      id: id,
      userId: map['userId'] ?? '',
      driverId: map['driverId'],
      originAddress: map['originAddress'] ?? '',
      originLatitude: (map['originLatitude'] ?? 0.0).toDouble(),
      originLongitude: (map['originLongitude'] ?? 0.0).toDouble(),
      destinationAddress: map['destinationAddress'] ?? '',
      destinationLatitude: (map['destinationLatitude'] ?? 0.0).toDouble(),
      destinationLongitude: (map['destinationLongitude'] ?? 0.0).toDouble(),
      estimatedDistance: (map['estimatedDistance'] ?? 0.0).toDouble(),
      estimatedFare: (map['estimatedFare'] ?? 0.0).toDouble(),
      rideType: map['rideType'] ?? 'economy',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      startedAt: map['startedAt']?.toDate(),
      completedAt: map['completedAt']?.toDate(),
      estimatedDurationMinutes: map['estimatedDurationMinutes'] ?? 0,
    );
  }

  @override
  String toString() => 'RideRequest(id: $id, status: $status, fare: $estimatedFare)';
}
