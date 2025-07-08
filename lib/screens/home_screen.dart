import 'package:cashcare/auth/login_screen.dart';
import 'package:cashcare/features/Insights/screens/dashboard_screen.dart';
import 'package:cashcare/features/goals/goal_list_screen.dart';
import 'package:cashcare/features/sms_parsing/screens/sms_uploader_screen.dart';
import 'package:cashcare/screens/add_expense.dart';
import 'package:cashcare/screens/add_income.dart';
import 'package:cashcare/screens/home_screen.dart';
import 'package:cashcare/screens/notification_screen.dart';
import 'package:cashcare/screens/receipt_scan.dart';
import 'package:cashcare/screens/stats_screen.dart';
import 'package:cashcare/services/auth_service.dart';
import 'package:cashcare/services/income_expense_services.dart';
import 'package:cashcare/services/profile_service.dart';
import 'package:cashcare/widgets/home_button_container.dart';
import 'package:cashcare/widgets/homescreen_loader.dart';
import 'package:cashcare/widgets/row_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:cashcare/features/goals/goal_list_screen.dart';

class HomeScreen extends StatefulWidget {

  @override
  State<HomeScreen> createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  String userName = '';
  bool isAmountVisible = true;
  bool isLoading = true;

  double totalIncome = 0.0;
  double totalExpense = 0.0;
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final results = await Future.wait([
        ProfileService.getProfile(),
        _authService.getUsername(),
        ApiService().getTotalIncome(),
        ApiService().getTotalExpense(),
      ]);

      setState(() {
        _userProfile = results[0] as Map<String, dynamic>?;
        userName = _userProfile?['first_name'] ?? 'Guest';
        totalIncome = results[2] as double;
        totalExpense = results[3] as double;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Failed to load data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: FloatingDotLoading(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, $userName!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Welcome back to your finances",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.green.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.green,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : "G",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3DAE81), Color(0xFF50C878)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Balance",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => isAmountVisible = !isAmountVisible),
                          child: Icon(
                            isAmountVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      isAmountVisible
                          ? "NPR ${(totalIncome - totalExpense).toStringAsFixed(2)}"
                          : "••••••",
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAmountIndicator(
                          icon: Icons.arrow_upward,
                          color: Colors.white,
                          title: "Income",
                          amount: "NPR ${totalIncome.toStringAsFixed(2)}",
                        ),
                        _buildAmountIndicator(
                          icon: Icons.arrow_downward,
                          color: Colors.orange[200]!,
                          title: "Expenses",
                          amount: "NPR ${totalExpense.toStringAsFixed(2)}",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.add,
                      color: Colors.green,
                      text: "Add Income",
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddIncomeScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.remove,
                      color: const Color(0xFFF56565),
                      text: "Add Expense",
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddExpenseScreen(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  "Financial Tools",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(height: 15),

              Expanded(
                child: GridView(
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  children: [
                    ToolCard(
                      icon: Icons.document_scanner_outlined,
                      color: const Color(0xFF3DAE81),
                      title: "Receipt Scan",
                      subtitle: "Track your spending",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReceiptScanPage(),
                        ),
                      ),
                    ),
                    ToolCard(
                      icon: Icons.timeline_rounded,
                      color: const Color(0xFF4FD1C5),
                      title: "Goals",
                      subtitle: "Manage your goals",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GoalListScreen(),
                        ),
                      ),
                    ),

                    ToolCard(
                      icon: Icons.account_balance_wallet,
                      color: const Color(0xFFF6AD55),
                      title: "Prediction",
                      subtitle: "Control your money",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StatsScreen(),
                        ),
                      )
                    ),
                    ToolCard(
                      icon: Icons.list_alt,
                      color: Colors.green,
                      title: "Parse SMS",
                      subtitle: "Finance Extractor",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SmsUploaderScreen(),
                        ),
                      ),
                    ),
                    ToolCard(
                        icon: Icons.insights,
                        color: Colors.indigo,
                        title: "Insights",
                        subtitle: "Track Compare Improve",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InsighScreen(),
                          ),
                        )
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountIndicator({
    required IconData icon,
    required Color color,
    required String title,
    required String amount,
  }) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          height: 40,
          width: 40,
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String text,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    );
  }
}

class ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const ToolCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}