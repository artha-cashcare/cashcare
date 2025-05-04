import 'package:cashcare/auth/login_screen.dart';
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
    return Scaffold(
      appBar: AppBar(
        // leadingWidth: 60, // Ensure avatar doesn't shift too far in
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
        title: Transform.translate(
          offset: Offset(-15, 0),
          child: Text(
            userName,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
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
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 0, 0, 0),
            child: Text(
              'Current Balance',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 0),

          Padding(
            padding: const EdgeInsets.fromLTRB(11, 0, 0, 0),
            child: Row(
              children: [
                Text(
                  'NPR ',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, -1),
                  child: Text(
                    isAmountVisible?'3,590.00':'******',
                    style: TextStyle(
                      fontSize: 21,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 7),
                Transform.translate(
                  offset: Offset(-16, -3),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        isAmountVisible = !isAmountVisible;
                      });
                    },
                    icon: Icon(
                      isAmountVisible ? Icons.visibility : Icons.visibility_off,
                      size: 19,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          RowWidget(title: 'Total Income', amount: 'NPR 4,500.00',isamtvisible: isAmountVisible,),
          RowWidget(
            title: 'Total Expence',
            amount: 'NPR 4,500.00',
            amountColor: Colors.red,
            isamtvisible: isAmountVisible,
          ),
          SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 0, 0, 0),
            child: Text(
              'What would you like to do next?',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 20),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 25,
                crossAxisSpacing: 15,
                childAspectRatio: 0.78, // adjust as needed to get perfect height/width
                children: [
                  HomeContainer(
                    title: 'Add Income',
                    imagePath: 'assets/images/add_money.png',
                    color: Colors.greenAccent,
                    onTap: () => print('Add Income'),
                  ),
                  HomeContainer(
                    title: 'Add Expense',
                    imagePath: 'assets/images/addexpence.png',
                    color: Colors.deepOrangeAccent[100],
                  ),
                  HomeContainer(
                    title: 'Scan Receipt',
                    imagePath: 'assets/images/receipt1.jpg',
                    color: Colors.purple[100],
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
          )

        ],
      ),
    );
  }
}
