  import 'dart:io';

  import 'package:cashcare/services/profile_service.dart';
  import 'package:flutter/foundation.dart';
  import 'package:cashcare/providers/profile_provider.dart';
  class ProfileProvider with ChangeNotifier {
    Map<String, dynamic>? _profile;
    bool _loading = false;

    bool get isVerified {
      return _profile?['is_verified'] ?? false;
    }

    Map<String, dynamic>? get profile => _profile;
    bool get loading => _loading;

    Future<void> fetchProfile() async {
      _loading = true;
      notifyListeners();

      try {
        _profile = await ProfileService.getProfile();
        print(profile);
      } catch (e) {
        print('Error fetching profile: $e');
      } finally {
        _loading = false;
        notifyListeners();
      }
    }

    Future<void> updateProfile(Map<String, dynamic> data) async {
      _loading = true;
      notifyListeners();

      try {
        _profile = await ProfileService.updateProfile(data);
      } catch (e) {
        print('Error updating profile: $e');
        rethrow;
      } finally {
        _loading = false;
        notifyListeners();
      }
    }

    Future<void> updateProfileImage(String imagePath) async {
      _loading = true;
      notifyListeners();

      try {
        final file = File(imagePath);
        _profile = await ProfileService.updateProfileImage(file);
      } catch (e) {
        print('Error updating profile image: $e');
        rethrow;
      } finally {
        _loading = false;
        notifyListeners();
      }
    }
  }