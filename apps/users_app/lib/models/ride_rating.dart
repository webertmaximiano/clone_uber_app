class RideRating {
  final String id;
  final String rideId;
  final String userId;
  final String driverId;
  final double rating; // 1-5
  final String comment;
  final DateTime createdAt;

  RideRating({
    required this.id,
    required this.rideId,
    required this.userId,
    required this.driverId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rideId': rideId,
      'userId': userId,
      'driverId': driverId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }

  factory RideRating.fromMap(Map<String, dynamic> map, String id) {
    return RideRating(
      id: id,
      rideId: map['rideId'] ?? '',
      userId: map['userId'] ?? '',
      driverId: map['driverId'] ?? '',
      rating: (map['rating'] ?? 5.0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  @override
  String toString() => 'RideRating(rideId: $rideId, rating: $rating)';
}
