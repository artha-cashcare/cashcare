class TransactionModel {
  final double amount;
  final String title;
  final DateTime timestamp;
  final bool isIncome;
  final String source;
  final int? referenceId;

  TransactionModel({
    required this.amount,
    required this.title,
    required this.timestamp,
    required this.isIncome,
    required this.source,
    this.referenceId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      amount: double.parse(json['amount'].toString()),
      title: json['category'] ?? 'Unknown',
      timestamp: _parseDateTime(json['timestamp']),
      isIncome: json['type'] == 'income',
      source: json['source'] ?? 'manual',
      referenceId: json['reference_id'],
    );
  }

  static DateTime _parseDateTime(String timestamp) {
    return DateTime.parse(timestamp).toLocal();
  }
}