import 'dart:ui';
import 'package:cashcare/models/navbar_provider.dart';
import 'package:cashcare/screens/history.dart';
import 'package:cashcare/screens/notification_screen.dart';
import 'package:cashcare/screens/profile.dart' show ProfileScreen;
import 'package:cashcare/screens/receipt_scan.dart';
import 'package:cashcare/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import '../screens/home_screen.dart';


class BottomNavbar extends StatefulWidget {
  final Map<String, dynamic>? userData;

  BottomNavbar({Key? key, this.userData}) : super(key: key);

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  final List<Widget> _pages = [
    HomeScreen(),
    NotificationsScreen(),
    PlaceTypeView(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUnreadNotifications(); // ✅ only called once!
  }

  void _fetchUnreadNotifications() async {
    try {
      final notificationService = NotificationService();
      final notifications = await notificationService.getNotifications();
      final unreadCount = notifications.where((n) => !n.isRead).length;

      Provider.of<BottomNavProvider>(context, listen: false)
          .updateUnreadCount(unreadCount);
    } catch (e) {
      print("Error fetching unread notifications: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<BottomNavProvider>(context);

    return Scaffold(
      extendBody: true,
      body: _pages[navProvider.currentIndex],
      floatingActionButton: _buildCenterButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomAppBar(context),
    );
  }

  Widget _buildCenterButton(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      margin: EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
      ),
      child: IconButton(
        icon: Icon(Icons.qr_code_scanner, size: 24),
        padding: EdgeInsets.zero,
        color: Color(0xFF4CAF50),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReceiptScanPage(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomAppBar(BuildContext context) {
    final navProvider = Provider.of<BottomNavProvider>(context);

    return Container(
      height: 60,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  height: 56,
                  color: Colors.white70.withOpacity(0.83),
                  padding: EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(IconlyBold.home, 0, context),
                      _buildNavItem(IconlyBold.notification, 1, context),
                      SizedBox(width: 20),
                      _buildNavItem(Icons.history, 2, context),
                      _buildNavItem(Icons.person, 3, context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, BuildContext context) {
    final navProvider = Provider.of<BottomNavProvider>(context);
    final isSelected = navProvider.currentIndex == index;
    final hasUnread = index == 1 && navProvider.unreadNotificationCount > 0;

    return InkWell(
      onTap: () => navProvider.changeIndex(index),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFFE8F5E9) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Color(0xFF4CAF50) : Color(0xFFA5D6A7),
                    size: 20,
                  ),
                ),
                if (hasUnread)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            if (isSelected)
              Container(
                margin: EdgeInsets.only(top: 2),
                height: 2,
                width: 14,
                color: Color(0xFF4CAF50),
              ),
          ],
        ),
      ),
    );
  }
}
