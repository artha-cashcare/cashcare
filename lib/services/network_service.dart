import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkService with ChangeNotifier {
  bool _hasInternet = true;
  bool get hasInternet => _hasInternet;

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription _subscription;

  NetworkService() {
    _init();
  }

  void _init() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result as ConnectivityResult);

    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus as void Function(List<ConnectivityResult> event)?);
  }

  void _updateStatus(ConnectivityResult result) {
    _hasInternet = result != ConnectivityResult.none;
    notifyListeners();
  }

  void disposeService() {
    _subscription.cancel();
  }
}
