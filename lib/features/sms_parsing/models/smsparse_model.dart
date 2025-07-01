class SmsTransaction {
  final double amount;
  final String parsedType;
  final String category;
  final DateTime timestamp;

  SmsTransaction({
    required this.amount,
    required this.parsedType,
    required this.category,
    required this.timestamp,
  });

  factory SmsTransaction.fromJson(Map<String, dynamic> json) {
    return SmsTransaction(
      amount: double.parse(json['amount'].toString()),
      parsedType: json['parsed_type'] ?? 'unknown',
      category: json['category'] ?? 'Other',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'parsed_type': parsedType,
      'category': category,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}