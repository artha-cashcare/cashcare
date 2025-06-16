class Receipt {
  final int id;
  final String filePath;
  final String scannedText;
  final double amount;
  final DateTime timestamp;

  Receipt({required this.id, required this.filePath, required this.scannedText, required this.amount, required this.timestamp});

  factory Receipt.fromJson(Map<String, dynamic> json) => Receipt(
    id: json['id'],
    filePath: json['file_path'],
    scannedText: json['scanned_text'],
    amount: double.parse(json['amount'].toString()),
    timestamp: DateTime.parse(json['timestamp']),
  );
}
