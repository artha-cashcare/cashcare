import 'package:cashcare/features/sms_parsing/models/smsparse_model.dart';
import 'package:cashcare/features/sms_parsing/services/api_service.dart';
import 'package:cashcare/features/sms_parsing/services/sms_handler.dart';
import 'package:cashcare/features/sms_parsing/utils/sms_parser.dart';
import 'package:cashcare/utils/history_sms_utils.dart';
import 'package:cashcare/widgets/homescreen_loader.dart';
import 'package:flutter/material.dart';
import 'package:another_telephony/telephony.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import 'package:intl/intl.dart';

@pragma('vm:entry-point')
Future<void> backgroundSmsHandler(SmsMessage message) async {
  debugPrint("📩 Background SMS: ${message.body}");
}

class SmsUploaderScreen extends StatefulWidget {
  @override
  State<SmsUploaderScreen> createState() => _SmsUploaderScreenState();
}

class _SmsUploaderScreenState extends State<SmsUploaderScreen> {
  late final ApiService _apiService;
  late final SmsHandler _smsHandler;
  final Telephony _telephony = Telephony.instance;
  bool _isLoading = true;

  List<SmsTransaction> _transactions = [];
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _smsHandler = SmsHandler();

    _initializeApp();
    _telephony.listenIncomingSms(
      onNewMessage: _handleSms,
      onBackgroundMessage: backgroundSmsHandler,
      listenInBackground: true,
    );
  }

  Future<void> _initializeApp() async {
    try {
      await _smsHandler.init();
      await _smsHandler.scanInbox(_handleSms);
      await _fetchTransactions();
      setState(() => _status = 'Ready to scan SMS');
      _isLoading = false;
    } catch (e) {
      setState(() => _status = 'Error: ${e.toString()}');
      _isLoading = false;
    }
  }

  Future<void> _fetchTransactions() async {
    try {
      final transactions = await _apiService.fetchParsedSms();
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Fetch error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSms(SmsMessage sms) async {
    final parsed = SmsParser.parseSms(sms.body ?? '');
    final amount = parsed['amount'] ?? '0';
    final type = SmsParser.determineTransactionType(
      parsed['type'] ?? 'unknown',
    );

    if (type == 'unknown') return;

    final category = await _showCategoryDialog(
      amount: amount,
      date: DateTime.fromMillisecondsSinceEpoch(sms.date ?? 0),
      message: sms.body ?? '',
    );

    if (category == null) return;

    final transaction = SmsTransaction(
      amount: double.parse(amount),
      parsedType: type,
      category: category,
      timestamp: DateTime.now(),
    );

    final success = await _apiService.postTransaction(transaction);
    if (success) {
      await _fetchTransactions();
      setState(() => _status = '✅ Sent: Rs. $amount');
    } else {
      setState(() => _status = '❌ Failed to send SMS');
    }
  }

  Future<String?> _showCategoryDialog({
    required String amount,
    required DateTime date,
    required String message,
  }) {
    String? selectedCategory;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('📊 Categorize Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("💰 Amount: Rs. $amount"),
              Text("📅 Date: ${TransactionUtils.formatDate(date)}"),
              const Divider(),
              const Text(
                "✉️ Message:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(message, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Category'),
                items:
                    ['Food', 'Bills', 'Shopping', 'Salary', 'Other']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) => selectedCategory = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedCategory != null) {
                  Navigator.pop(ctx, selectedCategory);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(IconlyBold.arrowLeftCircle, color: Colors.teal),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SMS Parser',
          style: TextStyle(fontFamily: 'poppins', color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(_status, style: const TextStyle(fontSize: 16)),
          ),
          const Divider(),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: FloatingDotLoading())
                    : _transactions.isEmpty
                    ? const Center(child: Text('No transactions yet'))
                    : ListView.builder(
                      itemCount: _transactions.length,
                      itemBuilder: (ctx, index) {
                        final transaction = _transactions[index];
                        final isIncome = transaction.parsedType == 'income';
                        final categoryInfo = TransactionUtils.getCategoryInfo(
                          transaction.category,
                          isIncome,
                        );

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(1, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                // Icon container
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color:
                                        isIncome
                                            ? Colors.green.shade50
                                            : Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    categoryInfo.icon,
                                    color:
                                        isIncome
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Texts
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        transaction.category,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        TransactionUtils.getSubtitle(
                                          transaction.parsedType,
                                          isIncome,
                                        ),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Amount & date
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      TransactionUtils.formatAmount(
                                        transaction.amount,
                                        isIncome,
                                      ),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isIncome
                                                ? Colors.green.shade800
                                                : Colors.red.shade800,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      TransactionUtils.formatDate(
                                        transaction.timestamp,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
