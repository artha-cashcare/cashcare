import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum TransactionType { income, expense }

class CategoryInfo {
  final IconData icon;
  final Color color;

  CategoryInfo(this.icon, this.color);
}

class TransactionUtils {
  static String getSubtitle(String title, bool isIncome) {
    final lowerTitle = title.toLowerCase();

    if (isIncome) {
      switch (lowerTitle) {
        case 'salary': return 'Salary received';
        case 'rental': return 'Rental income';
        case 'investment': return 'Investment returns';
        case 'refund': return 'Refund received';
        case 'reward': return 'Reward earned';
        case 'freelance': return 'Freelance payment';
        case 'bonus': return 'Bonus received';
        default: return 'Income received';
      }
    } else {
      switch (lowerTitle) {
        case 'food': return 'Food expense';
        case 'transport': return 'Transport cost';
        case 'shopping': return 'Shopping purchase';
        case 'bills': return 'Bill payment';
        case 'entertainment': return 'Entertainment expense';
        case 'healthcare': return 'Healthcare cost';
        case 'education': return 'Education expense';
        case 'gifts': return 'Gift purchase';
        default: return 'Expense';
      }
    }
  }

  static CategoryInfo getCategoryInfo(String title, bool isIncome) {
    final lowerTitle = title.toLowerCase();

    if (isIncome) {
      switch (lowerTitle) {
        case 'salary': return CategoryInfo(Icons.work, Colors.blue);
        case 'rental': return CategoryInfo(Icons.home, Colors.indigo);
        case 'investment': return CategoryInfo(Icons.trending_up, Colors.teal);
        case 'refund': return CategoryInfo(Icons.receipt, Colors.orange);
        case 'reward': return CategoryInfo(Icons.star, Colors.amber);
        case 'freelance': return CategoryInfo(Icons.computer, Colors.green);
        case 'bonus': return CategoryInfo(Icons.celebration, Colors.pink);
        default: return CategoryInfo(Icons.attach_money, Colors.blueGrey);
      }
    } else {
      switch (lowerTitle) {
        case 'food': return CategoryInfo(Icons.restaurant, Colors.orange);
        case 'transport': return CategoryInfo(Icons.directions_car, Colors.blue);
        case 'shopping': return CategoryInfo(Icons.shopping_bag, Colors.purple);
        case 'bills': return CategoryInfo(Icons.receipt_long, Colors.red);
        case 'entertainment': return CategoryInfo(Icons.movie, Colors.pink);
        case 'healthcare': return CategoryInfo(Icons.medical_services, Colors.redAccent);
        case 'education': return CategoryInfo(Icons.school, Colors.indigo);
        case 'gifts': return CategoryInfo(Icons.card_giftcard, Colors.pinkAccent);
        default: return CategoryInfo(Icons.money_off, Colors.grey);
      }
    }
  }

  static Color getAmountColor(bool isIncome) {
    return isIncome ? Color(0xFF4CAF50) : Color(0xFFF44336);
  }

  static String formatAmount(double amount, bool isIncome) {
    final sign = isIncome ? ' ' : ' ';
    return '$sign${NumberFormat.currency(symbol: 'Rs.', decimalDigits: 2).format(amount.abs())}';
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, hh:mm a').format(date);
  }
}