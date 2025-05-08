import 'package:cashcare/auth/login_screen.dart';
import 'package:cashcare/screens/add_expense.dart';
import 'package:cashcare/screens/add_income.dart';
import 'package:cashcare/screens/receipt_scan.dart';
import 'package:cashcare/services/auth_service.dart';
import 'package:cashcare/widgets/home_button_container.dart';
import 'package:cashcare/widgets/row_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  String userName = '';
  bool isAmountVisible = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await _authService.getUsername();
    setState(() => userName = name ?? 'Guest');
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await _authService.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueGrey, width: 2),
            color: Colors.red,
            borderRadius: BorderRadius.circular(50),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(
              'assets/images/home_avatar.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          'Hi, $userName',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(IconlyBold.notification, color: Colors.black87),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: theme.cardColor,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Balance',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'NPR ',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor,
                          ),
                        ),
                        Text(
                          isAmountVisible ? '3,590.00' : '••••••',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => setState(() => isAmountVisible = !isAmountVisible),
                          icon: Icon(
                            isAmountVisible ? Icons.visibility : Icons.visibility_off,
                            color: theme.primaryColor,
                          ),
                          splashRadius: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Income/Expense Summary
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryItem(
                            context,
                            title: 'Income',
                            amount: '4,500.00',
                            icon: Icons.arrow_upward,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryItem(
                            context,
                            title: 'Expense',
                            amount: '910.00',
                            icon: Icons.arrow_downward,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          const Padding(
            padding: EdgeInsets.fromLTRB(11, 0, 0, 0),
            child: Text(
              'What would you like to do next?',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 25,
                crossAxisSpacing: 15,
                childAspectRatio: 0.78,
                children: [
                  HomeContainer(
                    title: 'Add Income',
                    imagePath: 'assets/images/add_money.png',
                    color: Colors.greenAccent,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddIncomeScreen()),
                    ),
                  ),
                  HomeContainer(
                    title: 'Add Expense',
                    imagePath: 'assets/images/addexpence.png',
                    color: Colors.deepOrangeAccent[100],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddExpenseScreen()),
                    ),
                  ),
                  HomeContainer(
                    title: 'Scan Receipt',
                    imagePath: 'assets/images/receipt1.jpg',
                    color: Colors.purple[100],
                    onTap: ()=>Navigator.push(context,MaterialPageRoute(builder: (context)=>ReceiptScanPage())),
                  ),
                  HomeContainer(
                    title: 'Goals',
                    imagePath: 'assets/images/goal.jpg',
                    color: Colors.lightBlue[50],
                  ),
                  HomeContainer(
                    title: 'Prediction',
                    imagePath: 'assets/images/prediction.jpg',
                    color: Colors.cyan[50],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildSummaryItem(
    BuildContext context, {
      required String title,
      required String amount,
      required IconData icon,
      required Color color,
    }) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          'NPR $amount',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    ),
  );
}
