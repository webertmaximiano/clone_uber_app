class PaymentMethod {
  final String id;
  final String userId;
  final String type; // card, wallet, cash
  final String? cardNumber; // últimos 4 dígitos
  final String? cardholderName;
  final String? expiryDate;
  final bool isDefault;
  final double walletBalance; // para tipo wallet
  final DateTime createdAt;

  PaymentMethod({
    required this.id,
    required this.userId,
    required this.type,
    this.cardNumber,
    this.cardholderName,
    this.expiryDate,
    required this.isDefault,
    this.walletBalance = 0.0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'cardNumber': cardNumber,
      'cardholderName': cardholderName,
      'expiryDate': expiryDate,
      'isDefault': isDefault,
      'walletBalance': walletBalance,
      'createdAt': createdAt,
    };
  }

  factory PaymentMethod.fromMap(Map<String, dynamic> map, String id) {
    return PaymentMethod(
      id: id,
      userId: map['userId'] ?? '',
      type: map['type'] ?? 'card',
      cardNumber: map['cardNumber'],
      cardholderName: map['cardholderName'],
      expiryDate: map['expiryDate'],
      isDefault: map['isDefault'] ?? false,
      walletBalance: (map['walletBalance'] ?? 0.0).toDouble(),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  @override
  String toString() => 'PaymentMethod(type: $type, isDefault: $isDefault)';
}
