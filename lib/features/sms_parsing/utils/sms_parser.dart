class SmsParser {
  static Map<String, String> parseSms(String body) {
    final amountRegex = RegExp(r'(?:NPR|Rs\.?|Rs|Nrs|रु)[\s:]*(\d[\d,]*\.\d{2})');
    final typeRegex = RegExp(r'(debited|credited|withdrawn|deposited)', caseSensitive: false);

    final amountMatch = amountRegex.firstMatch(body);
    final typeMatch = typeRegex.firstMatch(body);

    return {
      'amount': amountMatch?.group(1)?.replaceAll(',', '') ?? '0',
      'type': typeMatch?.group(1)?.toLowerCase() ?? 'unknown',
    };
  }

  static String determineTransactionType(String smsType) {
    return (smsType == 'credited' || smsType == 'deposited')
        ? 'income'
        : (smsType == 'debited' || smsType == 'withdrawn')
        ? 'expense'
        : 'unknown';
  }
}