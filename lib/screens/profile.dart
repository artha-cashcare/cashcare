import 'package:cashcare/screens/edit_profile.dart';
import 'package:cashcare/services/auth_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import 'package:cashcare/providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color primaryColor = Color(0xFF1B5E20);
  final Color accentColor = Color(0xFF69F0AE);
  final Color premiumColor = Color(0xFFD4AF37);
  final Color cardColor = Color(0xFFFAFAFA);
  final Color textColor = Color(0xFF212121);
  final Color secondaryTextColor = Color(0xFF757575);

  late TextEditingController firstNameController;
  late TextEditingController secondNameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: '');
    secondNameController = TextEditingController(text: '');
    phoneController = TextEditingController(text: '');
    emailController = TextEditingController(text: '');
    addressController = TextEditingController(text: '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
    });
  }

  @override
  void dispose() {
    firstNameController.dispose();
    secondNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        if (profileProvider.profile != null && !profileProvider.loading) {
          final profile = profileProvider.profile!;
          firstNameController.text = profile['first_name'] ?? 'Guest';
          secondNameController.text = profile['last_name'] ?? '';
          phoneController.text = profile['phone'] ?? 'Not provided';
          emailController.text = profile['email'] ?? 'Not provided';
          addressController.text = profile['address'] ?? 'Not provided';
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child:
                profileProvider.loading && profileProvider.profile == null
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildAppBar(),
                          SizedBox(height: 24),
                          _buildProfileCard(profileProvider),
                          SizedBox(height: 24),
                          _buildPremiumFinancialSummary(),
                          SizedBox(height: 24),
                          _buildMenuOptions(),
                          SizedBox(height: 24),
                        ],
                      ),
                    ),
          ),
        );
      },
    );
  }

  Widget _buildEditableField(
    TextEditingController fc,
    TextEditingController sc,
    bool enabled,
  ) {
    return TextField(
      controller: TextEditingController(text: "${fc.text} ${sc.text}"),
      enabled: enabled,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
      ),
    );
  }

  Widget _buildEditableInfoRow(
    IconData icon,
    TextEditingController controller,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: secondaryTextColor),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: false,
              style: TextStyle(fontSize: 15, color: textColor.withOpacity(0.9)),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'My Account',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: 0.5,
          ),
        ),
        InkWell(onTap: (){AuthInterceptor.logout();},
          child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color(0xFF43A047).withOpacity(0.3),
                Color(0xFF66BB6A).withOpacity(0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 6,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Icon(Icons.logout_outlined, color: Colors.black),
        ),)
      ],
    );
  }

  Widget _buildProfileCard(ProfileProvider profileProvider) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: premiumColor.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage:
                      profileProvider.profile?['profile_image'] != null
                          ? NetworkImage(
                            profileProvider.profile!['profile_image'],
                          )
                          : NetworkImage(
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSR7A9dGuwJBYl_DSbqsdr2lGkGsIsmqhr_lw&s',
                          ),
                ),
              ),
              SizedBox(height: 16),
              _buildEditableField(
                firstNameController,
                secondNameController,
                false,
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: premiumColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: premiumColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.workspace_premium_rounded,
                      color: premiumColor,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'PREMIUM MEMBER',
                      style: TextStyle(
                        color: premiumColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              _buildEditableInfoRow(Icons.phone_rounded, phoneController),
              _buildEditableInfoRow(Icons.email_rounded, emailController),
              _buildEditableInfoRow(
                Icons.location_on_rounded,
                addressController,
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,

            child: FloatingActionButton.small(
              backgroundColor: primaryColor.withOpacity(0.1),
              elevation: 0,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              ),
              child: Icon(IconlyBold.edit, size: 15, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFinancialSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.2),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.attach_money_rounded,
                    color: premiumColor,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "FINANCIAL DASHBOARD",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.more_horiz_rounded,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFinancialMetric("Income", "\$12,000", true),
              _buildFinancialMetric("Expense", "\$8,000", false),
              _buildFinancialMetric("Savings", "\$4,000", true),
            ],
          ),
          SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 6,
                    width: constraints.maxWidth * 0.67,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [premiumColor, Color(0xFFFFFF00)],
                      ),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: premiumColor.withOpacity(0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Monthly Summary",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              Text(
                "67% Savings Rate",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: premiumColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialMetric(String title, String value, bool isPositive) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isPositive ? premiumColor : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOptions() {
    return Column(
      children: [
        _buildMenuOption(Icons.history_outlined, "History"),
        _buildMenuOption(Icons.help_outline, "FAQs"),
        _buildMenuOption(Icons.info_outline, "About"),
        _buildMenuOption(Icons.settings, "Settings"),
      ],
    );
  }

  Widget _buildMenuOption(IconData icon, String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primaryColor),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: secondaryTextColor),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {},
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: secondaryTextColor),
          SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(fontSize: 15, color: textColor.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }
}
