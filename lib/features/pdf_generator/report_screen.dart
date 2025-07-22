import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pdf_generator.dart';
import 'services.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with SingleTickerProviderStateMixin {
  bool _loading = false;
  String _status = "";

  final months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];
  final years = List.generate(10, (i) => (DateTime.now().year - i).toString());
  final reportTypes = ["Monthly", "Yearly"];

  String _reportType = "Yearly";
  String _selectedMonth = "January";
  String _selectedYear = DateTime.now().year.toString();

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String getMonthParam() {
    final index = months.indexOf(_selectedMonth) + 1;
    return "$_selectedYear-${index.toString().padLeft(2, '0')}";
  }

  Future<void> _generateReport() async {
    setState(() {
      _loading = true;
      _status = "Fetching data...";
    });

    try {
      HapticFeedback.mediumImpact();

      Map<String, String> params = {
        "type": _reportType == "Monthly" ? "month" : "year"
      };

      if (_reportType == "Monthly") {
        params["month"] = getMonthParam();
      } else {
        params["year"] = _selectedYear;
      }

      await Future.delayed(const Duration(seconds: 1));
      final data = await ApiService.fetchSummary(params);

      if (data != null) {
        setState(() => _status = "Generating PDF...");
        await Future.delayed(const Duration(seconds: 1));
        await PdfGenerator.generateMonthlyPdf(data);
        _showSnack("Report generated successfully!", Colors.green[700]!);
      } else {
        _showSnack("Failed to load data. Please try again.", Colors.red);

      }
    } catch (e) {
      _showSnack("Error: ${e.toString()}", Colors.red);
      print(e);
    } finally {
      setState(() {
        _loading = false;
        _status = "";
      });
    }
  }

  void _showSnack(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(bg == Colors.red ? Icons.error_outline : Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg,
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F4E24),
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFC8E6C9), width: 1.8),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.green.shade100.withOpacity(0.4),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF4CAF50), size: 32),
              style: GoogleFonts.poppins(
                color: const Color(0xFF21522D),
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
              borderRadius: BorderRadius.circular(18),
              dropdownColor: Colors.white,
              onChanged: onChanged,
              items: items
                  .map((e) => DropdownMenuItem(
                value: e,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(e.toString()),
                ),
              ))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(IconlyBold.arrowLeftCircle, color: Color(0xFF00897B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Financial Reportt',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Generate Your Business Insights",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F4E24),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Effortlessly create detailed financial reports tailored to your needs. Choose your criteria below.",
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 40),
                if (_loading) ...[
                  const SizedBox(height: 60),
                  Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          color: const Color(0xFF2E7D32),
                          strokeWidth: 5,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          _status,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ] else ...[
                  _buildDropdown<String>(
                    label: "Report Type",
                    value: _reportType,
                    items: reportTypes,
                    onChanged: (v) => setState(() => _reportType = v!),
                  ),
                  if (_reportType == "Monthly")
                    _buildDropdown<String>(
                      label: "Select Month",
                      value: _selectedMonth,
                      items: months,
                      onChanged: (v) => setState(() => _selectedMonth = v!),
                    ),
                  _buildDropdown<String>(
                    label: "Select Year",
                    value: _selectedYear,
                    items: years,
                    onChanged: (v) => setState(() => _selectedYear = v!),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 30, color: Colors.white),
                      label: Text(
                        "Generate Report",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 19,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 10,
                        shadowColor: const Color(0xFF4CAF50).withOpacity(0.5),

                      ),
                      onPressed: _loading ? null : _generateReport,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}