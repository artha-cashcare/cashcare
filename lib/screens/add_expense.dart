import 'package:cashcare/services/income_expense_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;

  final List<ExpenseCategory> _expenseCategories = [
    ExpenseCategory('Food', Icons.fastfood, Colors.red),
    ExpenseCategory('Transport', Icons.directions_car, Colors.blue),
    ExpenseCategory('Shopping', Icons.shopping_bag, Colors.purple),
    ExpenseCategory('Bills', Icons.receipt, Colors.orange),
    ExpenseCategory('Entertainment', Icons.movie, Colors.teal),
    ExpenseCategory('Healthcare', Icons.medical_services, Colors.pink),
    ExpenseCategory('Education', Icons.school, Colors.indigo),
    ExpenseCategory('Gifts', Icons.card_giftcard, Colors.amber),
    ExpenseCategory('Other', Icons.more_horiz, Colors.grey),
  ];

  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }



  void _submitExpense() async {
    if (_formKey.currentState!.validate()) {
      final category = _selectedCategory ?? _categoryController.text;
      final amount = double.tryParse(_amountController.text);

      if (amount != null) {
        try {
          await ApiService().storeExpense(amount, category);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Income added successfully!')),
          );
          _amountController.clear();
          _categoryController.clear();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add income. Please try again.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a valid amount')),
        );
      }
    }
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _categoryController.text = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(IconlyBold.arrowLeftCircle, color: Colors.teal),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 0),
                child: Column(
                  children: [
                    Icon(Icons.trending_down, size: 50, color: Colors.red),
                    Text(
                      'Track Your Expense',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Expense Category',
                  prefixIcon: Icon(IconlyBold.category, color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select expense category';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.currency_rupee, color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter valid amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: _submitExpense,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    'ADD EXPENSE',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                ),
              ),
              SizedBox(height: 30),

              Text(
                'Quick Select Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 15),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.9,
                ),
                itemCount: _expenseCategories.length,
                itemBuilder: (context, index) {
                  final category = _expenseCategories[index];
                  return _CategoryButton(
                    category: category,
                    isSelected: _selectedCategory == category.name,
                    onTap: () => _selectCategory(category.name),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpenseCategory {
  final String name;
  final IconData icon;
  final Color color;

  ExpenseCategory(this.name, this.icon, this.color);
}

class _CategoryButton extends StatelessWidget {
  final ExpenseCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color:
              isSelected ? category.color.withOpacity(0.2) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? category.color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category.icon, size: 30, color: category.color),
            SizedBox(height: 8),
            Text(
              category.name,
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
