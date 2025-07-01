import 'package:another_telephony/telephony.dart';
import 'package:cashcare/features/sms_parsing/utils/sms_parser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmsHandler {
  final Telephony telephony = Telephony.instance;
   Set<String> _processedIds = {};
  final List<String> trustedBankSenders = [
    "nabil", "nic", "nibl", "global", "scb", "sanima", "ctzn", "alert", "1415"
  ];
  final List<String> transactionKeywords = [
    "credited", "debited", "withdrawn", "deposited"
  ];
  final List<String> excludeKeywords = [
    "otp", "loan", "code", "password", "rs 0", "rs. 0", "expired", "offer"
  ];

  Future<void> init() async {
    await _requestPermission();
    await _loadProcessed();
  }

  Future<void> _requestPermission() async {
    final perm = await Permission.sms.request();
    if (!perm.isGranted) {
      throw Exception('SMS permission required!');
    }
  }

  Future<void> _loadProcessed() async {
    final prefs = await SharedPreferences.getInstance();
    _processedIds = prefs.getStringList('processed_sms_ids')?.toSet() ?? {};
  }

  Future<void> _saveProcessedId(String id) async {
    _processedIds.add(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('processed_sms_ids', _processedIds.toList());
  }

  Future<void> scanInbox(Function(SmsMessage) onValidSms) async {
    final perm = await Permission.sms.isGranted;
    if (!perm) return;

    final inbox = await telephony.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
    );

    for (var sms in inbox) {
      await _processSms(sms, onValidSms);
    }
  }

  Future<void> _processSms(SmsMessage sms, Function(SmsMessage) onValidSms) async {
    final addr = sms.address?.toLowerCase() ?? '';
    final body = sms.body?.toLowerCase() ?? '';
    final id = '${addr}_${sms.date}';

    if (_processedIds.contains(id)) return;

    final isBank = trustedBankSenders.any(addr.contains);
    final isTxn = transactionKeywords.any(body.contains);
    final isNoise = excludeKeywords.any(body.contains);

    if (!isBank || !isTxn || isNoise) return;

    final parsed = SmsParser.parseSms(sms.body ?? '');
    final amount = parsed['amount'] ?? '0';
    if (amount == '0' || amount == '0.00') return;

    onValidSms(sms);
    await _saveProcessedId(id);
  }
}