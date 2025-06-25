class Goal {
  final int id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final bool isCompleted;
  final bool isFailed;
  final List<GoalRule> rules;
  final double progressPercentage;
  final int? daysRemaining;

  Goal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.isCompleted,
    required this.isFailed,
    required this.rules,
    required this.progressPercentage,
    this.daysRemaining,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      targetAmount: double.parse(json['target_amount'].toString()),
      currentAmount: double.parse(json['current_amount'].toString()),
      deadline: DateTime.parse(json['deadline']),
      isCompleted: json['is_completed'],
      isFailed: json['is_failed'],
      rules: (json['rules'] as List<dynamic>)
          .map((ruleJson) => GoalRule.fromJson(ruleJson))
          .toList(),
      progressPercentage: double.parse(json['progress_percentage'].toString()),
      daysRemaining: json['days_remaining'],
    );
  }
}

class GoalRule {
  final String incomeCategory;
  final double percentage;

  GoalRule({
    required this.incomeCategory,
    required this.percentage,
  });

  factory GoalRule.fromJson(Map<String, dynamic> json) {
    return GoalRule(
      incomeCategory: json['income_category'],
      percentage: double.parse(json['percentage'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'income_category': incomeCategory,
    'percentage': percentage,
  };
}
