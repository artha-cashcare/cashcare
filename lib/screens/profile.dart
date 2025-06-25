import 'package:cashcare/auth/login_screen.dart';
import 'package:cashcare/models/navbar_provider.dart';
import 'package:cashcare/screens/edit_profile.dart';
import 'package:cashcare/services/auth_interceptor.dart';
import 'package:cashcare/services/auth_service.dart';
import 'package:cashcare/services/income_expense_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import 'package:cashcare/providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  double totalIncome = 0.0;
  double totalExpense = 0.0;
  double savings = 0.0;
  double savingsRate = 0.0;
  bool isLoadingFinancialData = false;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
    });
    _fetchFinancialData();
  }

  Future<void> _fetchFinancialData() async {
    setState(() {
      isLoadingFinancialData = true;
    });

    try {
      final income = await _apiService.getTotalIncome();
      final expense = await _apiService.getTotalExpense();
      final savings = income - expense;
      final savingsRate = income > 0 ? (savings / income) * 100 : 0;

      setState(() {
        this.totalIncome = income;
        this.totalExpense = expense;
        this.savings = savings;
        this.savingsRate = savingsRate.toDouble();
      });
    } catch (e) {
      print('Error fetching financial data: $e');
    } finally {
      setState(() {
        isLoadingFinancialData = false;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await _authService.logout();
      if (!mounted) return;

      final navProvider = Provider.of<BottomNavProvider>(context, listen: false);
      navProvider.resetToHome();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${e.toString()}'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.grey,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        final profile = profileProvider.profile;
        final firstName = profile?['first_name'] ?? 'Guest';
        final lastName = profile?['last_name'] ?? '';
        final email = profile?['email'] ?? 'Not provided';
        final phone = profile?['phone'] ?? 'Not provided';
        final address = profile?['address'] ?? 'Not provided';
        final profileImage = profile?['profile_image'] ??
            'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRzQbUNMS6JcPMKa7LJWV1SGxAh97jvFHxJT_RPNHbfZdARf4p5XVxNA1DAqAIvdL4nCN9sLGV8oOqekgGtfLrQZw';

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: Text(
              'Account',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(onPressed: (){_logout(context);}, icon: Icon(Icons.logout))
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(0.0),
              child: Container(
                color: Colors.grey.shade500,
                height: 1.0,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProfileScreen(),
                                    ),
                                  ),
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.green.shade50,
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Icon(IconlyBold.edit, color: Colors.green),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Stack(
                                children: [
                                  Container(
                                    height: 120,
                                    width: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: Colors.green.shade50,
                                      border: Border.all(color: Colors.green, width: 5),
                                    ),
                                    child: Center(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(100),
                                        child: Image.network(
                                          profileImage,
                                          fit: BoxFit.cover,
                                          height: 100,
                                          width: 100,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Icon(Icons.person, size: 60, color: Colors.green),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 1,
                                    right: 5,
                                    child: _buildVerifiedBadge(),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text(
                                '$firstName $lastName',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,fontFamily: 'Poppins'
                                ),
                              ),
                              SizedBox(height: 10),
                              _buildPremiumBadge(),
                              SizedBox(height: 15),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildDetailRow(Icons.email_outlined, email),
                                      _buildDetailRow(Icons.phone, phone),
                                      _buildDetailRow(Icons.location_on_outlined, address),
                                      SizedBox(height: 30),
                                      Text(
                                        'Financial Overview',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      _buildFinancialCard(),
                                      SizedBox(height: 20),
                                      Text(
                                        'Account Options',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      _buildMenuOption(Icons.settings, 'Settings'),
                                      _buildMenuOption(Icons.rule, 'Terms And Conditions'),
                                      _buildMenuOption(Icons.history_outlined, 'History'),
                                      _buildMenuOption(Icons.info_outline, 'About Us'),
                                      SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerifiedBadge() {
    return Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Center(
        child: Container(
          height: 20,
          width: 20,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumBadge() {
    return Container(
      width: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.green.shade700,
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.star,
              color: Colors.amberAccent,
              size: 17,
            ),
          ),
          Text(
            'PREMIUM MEMBER',
            style: TextStyle(
              color: Colors.amberAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey[600]),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.grey.shade700,fontFamily: 'Poppins'
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildFinancialCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green[800]!,
            Colors.green[600]!,
            Colors.green[400]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Financial Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6.0),
          const Divider(
            color: Colors.white24,
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFinancialItem(
                'INCOME',
                'Rs.${totalIncome.toStringAsFixed(2)}',
                Icons.arrow_upward_rounded,
                Colors.lightGreenAccent[400]!,
              ),
              _buildFinancialItem(
                'EXPENSE',
                'Rs.${totalExpense.toStringAsFixed(2)}',
                Icons.arrow_downward_rounded,
                Colors.orange[200]!,
              ),
              _buildFinancialItem(
                'SAVINGS',
                'Rs.${savings.toStringAsFixed(2)}',
                Icons.savings_rounded,
                Colors.lightBlueAccent[200]!,
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'MONTHLY SUMMARY',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11.0,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        color: savingsRate >= 0
                            ? Colors.lightGreen.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        '${savingsRate.toStringAsFixed(1)}% Rate',
                        style: TextStyle(
                          color: savingsRate >= 0
                              ? Colors.lightGreenAccent[100]
                              : Colors.red[100],
                          fontSize: 11.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Rs. ${savings.toStringAsFixed(2)} saved',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8.0),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: LinearProgressIndicator(
                    value: savingsRate / 100,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      savingsRate >= 0
                          ? Colors.lightGreenAccent[400]!
                          : Colors.orange[300]!,
                    ),
                    minHeight: 6.0,
                  ),
                ),
                const SizedBox(height: 2.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${savingsRate.toStringAsFixed(1)}% of income',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 9.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialItem(String title, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14.0,
              color: color,
            ),
            const SizedBox(width: 4.0),
            Text(
              title,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2.0),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  Widget _buildMenuOption(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 0, top: 10, bottom: 0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green.shade700),
          SizedBox(width: 5),
          Text(text, style: TextStyle(fontSize: 17, color: Colors.grey.shade700,fontFamily: 'Poppins')),
          Spacer(),
          IconButton(
              onPressed: (){},
              icon: Icon(Icons.keyboard_arrow_right_rounded)
          )
        ],
      ),
    );
  }
}