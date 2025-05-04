import 'dart:ui';
// import 'package:cashcare/screens/receipt_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'home_screen.dart';
import 'profile.dart';
import 'receipt_scan.dart';

class BottomNavbar extends StatefulWidget {
  @override
  _BottomNavbarState createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(), // 0
    Container(child: Center(child: Text('Goals screen'))), // 1 (Chart)
    // Container(),            // 2 (Scanner page  for center button)
    Container(child: Center(child: Text('History screen'))), // 3 (History)
    ProfileScreen(), // 4
  ];


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      floatingActionButton: _buildCenterButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  Widget _buildCenterButton() {
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
            MaterialPageRoute(builder: (context) => Container(child: Center(child: Text('Scanning page'),),)),
          );
          _onItemTapped(0); // Switch to sca
          // nner page
        },
      ),
    );
  }

  Widget _buildBottomAppBar() {
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
                      _buildNavItem(IconlyBold.home, 0),
                      _buildNavItem(IconlyBold.chart, 1),
                      SizedBox(width: 20), // Space for center button
                      _buildNavItem(Icons.history, 2),
                      _buildNavItem(Icons.person, 3),
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

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
