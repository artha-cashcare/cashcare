import 'package:cashcare/auth/login_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.5, end: 1.0),
              duration: Duration(seconds: 2),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Image.asset(
                'assets/images/logo.png',
                height: 350,
                width: 350,
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Budget Better, ',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 43,
                color: Colors.black,
              ),
            ),

            Text(
              'Stress Never! ',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 43,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Smarter spending starts here and ',
              style: TextStyle(fontSize: 20, color: Colors.grey[600]),
            ),
            Text(
              'manage paisa like a pro',
              style: TextStyle(fontSize: 20, color: Colors.grey[600]),
            ),
            Spacer(),
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 20,left: 15,right: 15),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                  minimumSize: Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  )
                ),
                child: Text('Get Started', style: TextStyle(color: Colors.white,fontFamily: 'Poppins',fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
