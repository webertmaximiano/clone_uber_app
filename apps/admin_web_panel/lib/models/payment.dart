/// Modelo que representa um pagamento no sistema.
class Payment {
  final String id;
  final String rideId;
  final String userId;
  final String driverId;
  final double amount;
  final String paymentMethod; // 'card', 'wallet', 'cash'
  final String status; // 'pending', 'completed', 'failed', 'refunded'
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? failureReason;

  Payment({
    required this.id,
    required this.rideId,
    required this.userId,
    required this.driverId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.processedAt,
    this.failureReason,
  });

  /// Converte um Payment para um Map (útil para salvar no Firestore).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rideId': rideId,
      'userId': userId,
      'driverId': driverId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'failureReason': failureReason,
    };
  }

  /// Cria um Payment a partir de um Map (útil para ler do Firestore).
  factory Payment.fromMap(Map<String, dynamic> map, String documentId) {
    return Payment(
      id: documentId,
      rideId: map['rideId'] ?? '',
      userId: map['userId'] ?? '',
      driverId: map['driverId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? 'card',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      processedAt: map['processedAt'] != null
          ? DateTime.parse(map['processedAt'])
          : null,
      failureReason: map['failureReason'],
    );
  }

  /// Cria uma cópia do Payment com campos opcionais atualizados.
  Payment copyWith({
    String? id,
    String? rideId,
    String? userId,
    String? driverId,
    double? amount,
    String? paymentMethod,
    String? status,
    DateTime? createdAt,
    DateTime? processedAt,
    String? failureReason,
  }) {
    return Payment(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      userId: userId ?? this.userId,
      driverId: driverId ?? this.driverId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      failureReason: failureReason ?? this.failureReason,
    );
  }

  @override
  String toString() {
    return 'Payment(id: $id, rideId: $rideId, amount: $amount, status: $status)';
  }
}
