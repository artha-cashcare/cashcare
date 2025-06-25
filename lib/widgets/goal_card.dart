import 'package:flutter/material.dart';
import 'package:cashcare/models/goal_model.dart';
class GoalCard extends StatelessWidget {
  final Goal goal;

  GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        title: Text(goal.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progress: ${goal.progressPercentage.toStringAsFixed(1)}%'),
            Text('Days left: ${goal.daysRemaining}'),
          ],
        ),
        trailing: Icon(
          goal.isCompleted
              ? Icons.check_circle
              : goal.isFailed
              ? Icons.cancel
              : Icons.timelapse,
          color: goal.isCompleted
              ? Colors.green
              : goal.isFailed
              ? Colors.red
              : Colors.blue,
        ),
      ),
    );
  }
}
