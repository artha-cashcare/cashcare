import 'package:cashcare/auth/signup_screen.dart';
import 'package:cashcare/screens/PredictionPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim, _shadowAnim, _fadeAnim, _bgPulse;
  late Animation<Offset> _textSlideAnim;

  @override
    void initState() {
      super.initState();
      _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 1800));

      _scaleAnim = TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 0.7, end: 1.1), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 50),
      ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      _shadowAnim = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Interval(0.4, 1.0, curve: Curves.easeOut)),
      );

      _fadeAnim = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Interval(0.3, 1.0, curve: Curves.easeIn)),
      );

      _textSlideAnim = Tween(begin: Offset(0, 0.5), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Interval(0.4, 1.0, curve: Curves.fastOutSlowIn)),
      );

      _bgPulse = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      SchedulerBinding.instance.addPostFrameCallback((_) => _controller.forward());
    }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _fadedText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        color: Colors.grey[700],
        fontFamily: 'Poppins',
        letterSpacing: 0.3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final greenShade = Colors.green.withOpacity(0.05 + _bgPulse.value * 0.05);

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [greenShade, Colors.white, greenShade],
              ),
            ),
            child: Stack(
              children: [
                ..._backgroundIcons(),
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLogo(),
                        SizedBox(height: 40),
                        _buildTitle(),
                        SizedBox(height: 20),
                        FadeTransition(
                          opacity: _fadeAnim,
                          child: Column(
                            children: [_fadedText('Smarter spending starts here and'), _fadedText('manage paisa like a pro')],
                          ),
                        ),
                        Spacer(),
                        _buildButton(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _backgroundIcons() => [
    Positioned(
      top: 50,
      left: 30,
      child: Opacity(
        opacity: 0.03,
        child: Transform.scale(
          scale: 1.5,
          child: Icon(Icons.account_balance_wallet, size: 120, color: Colors.green[800]),
        ),
      ),
    ),
    Positioned(
      bottom: 100,
      right: 40,
      child: Opacity(
        opacity: 0.03,
        child: Transform.scale(
          scale: 1.5,
          child: Icon(Icons.trending_up_rounded, size: 120, color: Colors.green[800]),
        ),
      ),
    ),
  ];

  Widget _buildLogo() {
    return AnimatedScale(
      scale: _scaleAnim.value,
      duration: Duration(milliseconds: 800),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              blurRadius: 50,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/images/logo3.png',
            height: 180,
            width: 180,
          ),
        ),
      ),
    );
  }


  Widget _buildTitle() {
    final baseStyle = TextStyle(fontFamily: 'Poppins', fontSize: 36, fontWeight: FontWeight.w600, color: Colors.black87);
    return SlideTransition(
      position: _textSlideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            RichText(
              text: TextSpan(style: baseStyle, children: [
                TextSpan(text: 'Budget '),
                TextSpan(text: 'Better', style: baseStyle.copyWith(color: Colors.green[800], fontWeight: FontWeight.w700)),
              ]),
            ),
            RichText(
              text: TextSpan(style: baseStyle, children: [
                TextSpan(text: 'Stress '),
                TextSpan(text: 'Never', style: baseStyle.copyWith(color: Colors.green[800], fontWeight: FontWeight.w700)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Padding(
        padding: EdgeInsets.only(bottom: 40),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => SignupPage(),
                  transitionsBuilder: (_, animation, __, child) {
                    final curved = CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn);
                    return FadeTransition(
                      opacity: curved,
                      child: SlideTransition(
                        position: Tween<Offset>(begin: Offset(0, 0.1), end: Offset.zero).animate(curved),
                        child: child,
                      ),
                    );
                  },
                  transitionDuration: Duration(milliseconds: 600),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[800],
              padding: EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 8,
              shadowColor: Colors.green.withOpacity(0.4),
            ),
            child: Text(
              'Get Started',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
