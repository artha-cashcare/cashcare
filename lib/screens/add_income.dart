import 'package:cashcare/models/income_source.dart';
import 'package:cashcare/services/income_expense_services.dart';
import 'package:cashcare/utils/snackbar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:cashcare/widgets/income_source.dart';
class AddIncomeScreen extends StatefulWidget {
  @override
  _AddIncomeScreenState createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  String? _selectedSource;

  final List<IncomeSource> _incomeSources = [
    IncomeSource('Salary', Icons.work, Colors.green),
    IncomeSource('Rental', Icons.home, Colors.blue),
    IncomeSource('Investment', Icons.trending_up, Colors.purple),
    IncomeSource('Lottery', Icons.celebration, Colors.orange),
    IncomeSource('Refund', Icons.assignment_return, Colors.teal),
    IncomeSource('Reward', Icons.card_giftcard, Colors.pink),
    IncomeSource('Freelance', Icons.computer, Colors.indigo),
    IncomeSource('Bonus', Icons.star, Colors.amber),
    IncomeSource('Other', Icons.more_horiz, Colors.grey),
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  void _submitIncome() async {
    if (_formKey.currentState!.validate()) {
      final source = _selectedSource ?? _sourceController.text;
      final amount = double.tryParse(_amountController.text);

      if (amount != null) {
        try {
          await ApiService().storeIncome(amount, source);
          SnackBarService.showCustomSnackBar(context: context,
              message: "Income added successfully",
              icon: Icon(Icons.check_circle_outline_sharp,color: Colors.white,),
              backgroundColor: Colors.green,
              textColor: Colors.white);
          _amountController.clear();
          _sourceController.clear();
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

  void _selectSource(String source) {
    setState(() {
      _selectedSource = source;
      _sourceController.text = source;
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
        title: Text('Add Income',style: TextStyle(fontFamily: 'poppins'),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Container(decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(50)
                    ),
                        
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.trending_up, size: 50, color: Colors.green),
                        )),
                    SizedBox(height: 10),
                    Text(
                      'Record Your Income',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ],
                ),
              ),

              TextFormField(
                controller: _sourceController,
                decoration: InputDecoration(
                  labelText: 'Income Source',
                  prefixIcon: Icon(Icons.source, color: Colors.green),
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
                    return 'Please enter income source';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.money_rounded, color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),

              ElevatedButton(
                onPressed: _submitIncome,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    'ADD INCOME',
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
                'Quick Select Source',
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
                itemCount: _incomeSources.length,
                itemBuilder: (context, index) {
                  final source = _incomeSources[index];
                  return SourceButton(
                    source: source,
                    isSelected: _selectedSource == source.name,
                    onTap: () => _selectSource(source.name),
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

