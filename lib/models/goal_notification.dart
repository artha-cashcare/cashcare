class GoalNotification {
  final int id;
  final int? goalId;     // 👈 nullable
  final int? paymentId;  // 👈 new: also nullable
  final String type;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  GoalNotification({
    required this.id,
    required this.goalId,
    required this.paymentId,
    required this.type,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory GoalNotification.fromJson(Map<String, dynamic> json) {
    return GoalNotification(
      id: json['id'],
      goalId: json['goal'],           // may be null
      paymentId: json['payment'],     // may be null
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      isRead: json['read'] ?? false,  // keep `read` not `isRead` if API sends `read`
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
