import 'package:flutter/material.dart';
import 'package:cashcare/models/goal_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:intl/intl.dart';

class GoalDetailScreen extends StatelessWidget {
  final Goal goal;

  const GoalDetailScreen({Key? key, required this.goal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final daysLeft = goal.daysRemaining ?? 0;
    final safeDaysLeft = daysLeft > 0 ? daysLeft : 1;
    final dailyTarget = (goal.targetAmount - goal.currentAmount) / safeDaysLeft;
    final formattedDeadline = DateFormat('MMM dd, yyyy').format(goal.deadline);

    final isOverdue = daysLeft <= 0 && !goal.isCompleted;

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Goal Details',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 20,fontFamily: 'poppins'
          ),
        ),
        leading: IconButton(
          icon: Icon(IconlyBold.arrowLeftSquare, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _infoCard(
              title: goal.title,
              subtitle: 'Target Date: $formattedDeadline',
              icon: Icons.flag,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            _progressCard(goal),
            SizedBox(height: 16),
            _pieChartCard(goal),

            SizedBox(height: 16),
            _infoCard(
              title: 'Target Amount: Rs.${goal.targetAmount.toStringAsFixed(0)}',
              subtitle: 'Saved: Rs.${goal.currentAmount.toStringAsFixed(0)}',
              icon: Icons.savings,
              color: Colors.indigo,
            ),
            SizedBox(height: 16),
            _infoCard(
              title: isOverdue
                  ? 'Deadline Passed'
                  : 'Daily Target: Rs.${dailyTarget.toStringAsFixed(2)}',
              subtitle: isOverdue
                  ? 'You missed the goal deadline.'
                  : 'You need to save within $safeDaysLeft more day(s)',
              icon: Icons.calendar_today,
              color: isOverdue ? Colors.red : Colors.orange,
            ),
            SizedBox(height: 16),
            if (goal.isCompleted)
              _statusCard("🎉 Goal Completed!", Colors.green)
            else if (goal.isFailed)
              _statusCard("❌ Goal Failed", Colors.red)
            else if (daysLeft <= 0)
                _statusCard("⚠️ Deadline Passed", Colors.orangeAccent)
              else
                _statusCard("🚀 Keep Going!", Colors.blueAccent),
          ],
        ),
      ),
    );
  }

  Widget _pieChartCard(Goal goal) {
    final saved = goal.currentAmount;
    final remaining = (goal.targetAmount - goal.currentAmount).clamp(0, double.infinity).toDouble();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Savings Distribution', style: _titleStyle()),
          SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: Color(0xFF4CAF50),
                    value: saved,
                    title: 'Saved\n${saved.toStringAsFixed(0)}',
                    radius: 60,
                    titleStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.red,
                    value: remaining,
                    title: 'Rem.\n${remaining.toStringAsFixed(0)}',
                    radius: 60,
                    titleStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressCard(Goal goal) {
    final percentage = goal.progressPercentage;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progress', style: _titleStyle()),
          SizedBox(height: 10),
          LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 14,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(percentage)),
          ),
          SizedBox(height: 10),
          Text(
            '${percentage.toStringAsFixed(1)}% completed',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard(String message, Color color) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
    );
  }

  TextStyle _titleStyle() => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.grey[800],
  );

  Color _getProgressColor(double percentage) {
    if (percentage >= 100) return Color(0xFF4CAF50);
    if (percentage >= 75) return Color(0xFF8BC34A);
    if (percentage >= 50) return Color(0xFFCDDC39);
    if (percentage >= 25) return Color(0xFFFFC107);
    return Color(0xFFFF9800);
  }
}
