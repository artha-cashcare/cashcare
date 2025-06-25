class GoalNotification {
  final int id;
  final int goalId;
  final String type;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  GoalNotification({
    required this.id,
    required this.goalId,
    required this.type,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory GoalNotification.fromJson(Map<String, dynamic> json) {
    return GoalNotification(
      id: json['id'],
      goalId: json['goal'],
      type: json['type'],
      message: json['message'],
      isRead: json['is_read'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}