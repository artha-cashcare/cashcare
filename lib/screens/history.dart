import 'package:cashcare/services/income_expense_history.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cashcare/models/history.dart';

class PlaceTypeView extends StatefulWidget {
  const PlaceTypeView({super.key});

  @override
  State<PlaceTypeView> createState() => _PlaceTypeViewState();
}

class _PlaceTypeViewState extends State<PlaceTypeView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text(
            "My Records",
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          // centerTitle: true,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[700],
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 0),
                  tabs: const [
                    Tab(child: Text('All', style: TextStyle(fontWeight: FontWeight.w500))),
                    Tab(child: Text('Income', style: TextStyle(fontWeight: FontWeight.w500))),
                    Tab(child: Text('Expense', style: TextStyle(fontWeight: FontWeight.w500))),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            PremiumTransactionList(filter: null),
            PremiumTransactionList(filter: TransactionType.income),
            PremiumTransactionList(filter: TransactionType.expense),
          ],
        ),
      ),
    );
  }
}

enum TransactionType { income, expense }

class PremiumTransactionList extends StatefulWidget {
  final TransactionType? filter;
  final ApiService apiService = ApiService();

   PremiumTransactionList({Key? key, this.filter}) : super(key: key);

  @override
  _PremiumTransactionListState createState() => _PremiumTransactionListState();
}

class _PremiumTransactionListState extends State<PremiumTransactionList> {
  late Future<List<TransactionModel>> _transactionsFuture;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final transactions = await widget.apiService.getAllTransactions();

      // Sort all transactions by date (newest first)
      transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      setState(() {
        _transactionsFuture = Future.value(transactions);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading transactions: $e')),
      );
    }
  }

  List<TransactionModel> _filterTransactions(List<TransactionModel> transactions) {
    if (widget.filter == null) return transactions;
    return transactions.where((t) {
      if (widget.filter == TransactionType.income) return t.isIncome;
      return !t.isIncome;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder<List<TransactionModel>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          // Get filtered transactions and maintain the date sorting
          final filtered = _filterTransactions(snapshot.data!);

          if (filtered.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadTransactions,
            child: ListView.builder(
              padding: EdgeInsets.only(top: 8, bottom: 16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                return _buildTransactionItem(filtered[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.filter == TransactionType.income
                ? Icons.money_off
                : Icons.receipt_long,
            size: 48,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            widget.filter == TransactionType.income
                ? 'No income transactions'
                : 'No expense transactions',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    final isIncome = transaction.isIncome;
    final amountColor = isIncome ? Color(0xFF4CAF50) : Color(0xFFF44336);
    final amountSign = isIncome ? '+ ' : '- ';
    final formattedDate = DateFormat('MMM dd, hh:mm a').format(transaction.timestamp);
    final formattedAmount = NumberFormat.currency(symbol: 'Rs.', decimalDigits: 2)
        .format(transaction.amount.abs());

    final categoryInfo = _getCategoryInfo(transaction.title, isIncome);

    return Dismissible(
      key: Key(transaction.title + transaction.timestamp.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.red),
      ),
      onDismissed: (direction) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction deleted'),
            backgroundColor: Colors.grey[800],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            action: SnackBarAction(
              label: 'UNDO',
              textColor: Colors.white,
              onPressed: () {
                // Would need to re-add to list in real implementation
              },
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: categoryInfo.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                categoryInfo.icon,
                color: categoryInfo.color,
                size: 24,
              ),
            ),
          ),
          title: Text(
            transaction.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Text(
                _getSubtitle(transaction.title, isIncome),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                formattedDate,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amountSign$formattedAmount',
                style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: amountColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isIncome ? 'Income' : 'Expense',
                  style: TextStyle(
                    color: amountColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSubtitle(String title, bool isIncome) {
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

  CategoryInfo _getCategoryInfo(String title, bool isIncome) {
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
}

class CategoryInfo {
  final IconData icon;
  final Color color;

  CategoryInfo(this.icon, this.color);
}