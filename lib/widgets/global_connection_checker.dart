import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class InternetChecker extends StatefulWidget {
  final Widget child;
  const InternetChecker({required this.child, Key? key}) : super(key: key);

  @override
  State<InternetChecker> createState() => _InternetCheckerState();
}

class _InternetCheckerState extends State<InternetChecker> {
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((status) {
      setState(() {
        _hasInternet = status != ConnectivityResult.none;
      });
    });
    // Initial check
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    final status = await Connectivity().checkConnectivity();
    setState(() {
      _hasInternet = status != ConnectivityResult.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!_hasInternet)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.red,
              padding: EdgeInsets.all(8),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.signal_wifi_off, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "No Internet Connection",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
