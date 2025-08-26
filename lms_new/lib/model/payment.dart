class Payment {
  final int id;
  final int userId;
  final int courseId;
  final double amount;
  final String method;
  final String status;
  final DateTime paidAt;

  Payment({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.amount,
    required this.method,
    required this.status,
    required this.paidAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int,
      userId: json['user'] as int,
      courseId: json['course'] as int,
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : double.tryParse(json['amount'].toString()) ?? 0.0,
      method: json['method'] ?? '',
      status: json['status'] ?? '',
      paidAt: DateTime.tryParse(json['paid_at'] ?? '') ?? DateTime.now(),
    );
  }
}
