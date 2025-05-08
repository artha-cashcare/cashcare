import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:intl/intl.dart';  // Add this import for date formatting

class ReceiptScanPage extends StatefulWidget {
  @override
  _ReceiptScanPageState createState() => _ReceiptScanPageState();
}

class _ReceiptScanPageState extends State<ReceiptScanPage> with TickerProviderStateMixin  {
  File? _image;
  String? _totalAmount;
  String? _date;
  String? _category;
  bool _isLoading = false;
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;


  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _scanController,
        curve: Curves.easeInOut,
      ),
    );
  }


  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isLoading = true;
      });
      await _processImage(_image!);
    }
  }

  Future<void> _processImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    print("Recognized Text:\n${recognizedText.text}");

    final amount = _extractTotalAmount(recognizedText.text);
    final date = _extractDate(recognizedText.text);

    setState(() {
      _totalAmount = amount;
      _date = date;
      _isLoading = false;
      _amountController.text = amount ?? '';
      _dateController.text = date ?? '';
    });
  }


  String? _extractTotalAmount(String text) {
    final lines = text.split('\n');

    final amountKeywords = ['amount', 'total', 'due amount', 'grand total'];
    final amountRegex = RegExp(r'(Rs\.?\s?\d{1,3}(?:,\d{3})*(?:\.\d{2})?)|(\$\s?\d{1,3}(?:,\d{3})*(?:\.\d{2})?)|(\d{1,3}(?:,\d{3})*(?:\.\d{2}))');
    final numberOnlyRegex = RegExp(r'^\d{1,3}(?:,\d{3})*(?:\.\d{2})?$'); // Matches lines like 5,000 or 12,345.67

    bool isValidAmount(String? amount) {
      if (amount == null) return false;
      final cleaned = amount.replaceAll(RegExp(r'[^\d.]'), '');
      final parsed = double.tryParse(cleaned);
      if (parsed == null) return false;
      // 🔥 Exclude year-like values
      if (parsed >= 1900 && parsed <= 2099) return false;
      return true;
    }

    // Step 1: Look for lines with amount-related keywords
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].toLowerCase();
      if (amountKeywords.any((k) => line.contains(k))) {
        final match = amountRegex.firstMatch(lines[i]);
        if (match != null) {
          final amount = match.group(0)?.replaceAll(',', '').trim();
          if (isValidAmount(amount)) {
            print('✅ Amount Found: $amount');
            return amount;
          }
        }
      }
    }

    // Step 2: Look for "(Rs.)" followed by number-only line
    for (int i = 0; i < lines.length - 1; i++) {
      final current = lines[i].toLowerCase().trim();
      final next = lines[i + 1].trim();
      if ((current.contains('(rs') || current.contains('rs.')) && numberOnlyRegex.hasMatch(next)) {
        final cleaned = next.replaceAll(',', '');
        if (isValidAmount(cleaned)) {
          print('✅ Amount Found After (Rs.): $cleaned');
          return cleaned;
        }
      }
    }

    // Step 3: Fallback - max valid amount ignoring phone lines and year-like values
    double maxAmount = 0;
    for (final line in lines) {
      final lower = line.toLowerCase();
      if (lower.contains('phone') || lower.contains('tel') || lower.contains('(') || lower.contains(')')) continue;

      for (final match in amountRegex.allMatches(line)) {
        final val = match.group(0)?.replaceAll(RegExp(r'[^\d.]'), '');
        final parsed = double.tryParse(val ?? '');
        if (parsed != null && isValidAmount(val) && parsed > maxAmount) {
          maxAmount = parsed;
        }
      }
    }

    if (maxAmount > 0) {
      print('✅ Fallback Max Amount: $maxAmount');
      return maxAmount.toStringAsFixed(2);
    }

    return null;
  }

  String? _extractDate(String text) {
    // Define patterns for dates
    final datePatterns = [
      RegExp(r'\b(Transaction Date:|BillDate:)\s*(\d{4}[-/.]\d{2}[-/.]\d{2})\b'), // e.g. Transaction Date: 2024/06/12
      RegExp(r'\b\d{4}[-/.]\d{2}[-/.]\d{2}\b'), // 2024-06-12 or 2024.06.12
      RegExp(r'\b\d{2}[-/.]\d{2}[-/.]\d{4}\b'), // 30-04-2024 or 30/04/2024
      RegExp(r'\b\d{2}[-/.]\d{2}[-/.]\d{2}\b'), // 30/04/24
      RegExp(r'\b\d{1,2} (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*[,]? \d{4}\b', caseSensitive: false), // 30 Apr 2024
      RegExp(r'\b(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]* \d{1,2}, \d{4}\b', caseSensitive: false), // Apr 30, 2024
    ];

    // Check for valid date and format it
    for (final pattern in datePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        try {
          String? dateText;

          if (match.groupCount > 1) {
            // Extract the date text from the second group (the actual date part)
            dateText = match.group(2);
          } else {
            // Use the full matched date if it's just the date itself
            dateText = match.group(0);
          }

          if (dateText != null) {
            // Normalize date (replace slashes with dashes for consistency)
            dateText = dateText.replaceAll(RegExp(r'[-/.]'), '-');

            DateFormat dateFormat;

            // Handle date format with Month (e.g. "April 5, 2024")
            if (dateText.contains(RegExp(r'[A-Za-z]'))) {
              dateFormat = DateFormat('MMMM d, yyyy');
            } else {
              // Handle date formats like "2024-06-12" or "2024.06.12"
              dateFormat = DateFormat('yyyy-MM-dd');
            }

            DateTime extractedDate = dateFormat.parse(dateText);
            String formattedDate = DateFormat('yyyy-MM-dd').format(extractedDate);
            print('✅ Date Found: $formattedDate');
            return formattedDate;
          }
        } catch (e) {
          print('❌ Error parsing date: $e');
        }
      }
    }

    print('❌ No Date Found');
    return null;
  }
  @override
  void dispose() {
    _scanController.dispose();
    _amountController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Scan Receipt",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.grey[800]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            if (_image != null)
              Expanded(
                child: Stack(
                  children: [
                    // Main receipt image
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_image!, fit: BoxFit.contain),
                      ),
                    ),

                    // Scanning overlay (only visible when loading)
                    if (_isLoading)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              // Animated scanner line
                              AnimatedBuilder(
                                animation: _scanAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      0,
                                      _scanAnimation.value * MediaQuery.of(context).size.width * 0.45,
                                    ),
                                    child: Container(
                                      height: 3,
                                      width: MediaQuery.of(context).size.width * 0.8,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Colors.greenAccent.withOpacity(0.8),
                                            Colors.transparent,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.greenAccent.withOpacity(0.4),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Processing text
                              Expanded(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.document_scanner,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Processing Receipt',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Extracting details...',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No receipt selected',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Capture or upload your receipt to get started',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 24),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: "Total Amount",
                labelStyle: TextStyle(color: Colors.grey[600]),
                floatingLabelStyle: TextStyle(color: Colors.green[700]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                prefixIcon: Icon(Icons.attach_money, color: Colors.grey[600]),
                prefixIconConstraints: BoxConstraints(minWidth: 40),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: "Date",
                labelStyle: TextStyle(color: Colors.grey[600]),
                floatingLabelStyle: TextStyle(color: Colors.green[700]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                prefixIcon: Icon(Icons.calendar_month, color: Colors.grey[600]),
                prefixIconConstraints: BoxConstraints(minWidth: 40),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.green[700]),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Colors.green[700]!,
                              onPrimary: Colors.white,
                              onSurface: Colors.black,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.green[700],
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      _dateController.text = picked.toIso8601String().split('T')[0];
                    }
                  },
                ),
              ),
              readOnly: true,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: "Category",
                labelStyle: TextStyle(color: Colors.grey[600]),
                floatingLabelStyle: TextStyle(color: Colors.green[700]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                prefixIcon: Icon(Icons.category, color: Colors.grey[600]),
                prefixIconConstraints: BoxConstraints(minWidth: 40),
                suffixIcon: IconButton(
                  icon: Icon(Icons.arrow_drop_down, color: Colors.green[700]),
                  onPressed: () {
                    // Show category selection dialog
                  },
                ),
              ),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Save or upload logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  shadowColor: Colors.green.withOpacity(0.3),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'SAVE RECEIPT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: Icon(Icons.camera_alt, color: Colors.white, size: 22),
                  label: Text(
                    "Capture",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: Icon(Icons.upload, color: Colors.white, size: 22),
                  label: Text(
                    "Upload",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[600],
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
