import 'package:cashcare/models/goal_model.dart';
import 'package:cashcare/services/goal_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:intl/intl.dart';

class GoalCreationForm extends StatefulWidget {
  @override
  _PremiumGoalFormState createState() => _PremiumGoalFormState();
}

class _PremiumGoalFormState extends State<GoalCreationForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetAmountController = TextEditingController();
  DateTime? _selectedDeadline;
  List<RuleInput> _rules = [RuleInput()];
  bool _isSubmitting = false;

  final Color _primaryColor = Color(0xFF00C853); // Premium green
  final Color _backgroundColor = Color(0xFFFAFAFA);

  void _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDeadline = picked);
    }
  }

  void _addRule() => setState(() => _rules.add(RuleInput()));

  void _removeRule(int index) => setState(() => _rules.removeAt(index));

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDeadline == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select a deadline')));
      return;
    }

    List<GoalRule> rules =
    _rules.map((rule) {
      return GoalRule(
        incomeCategory: rule.categoryController.text.trim(),
        percentage: double.parse(rule.percentageController.text.trim()),
      );
    }).toList();

    try {
      await GoalService().createGoal(
        title: _titleController.text.trim(),
        targetAmount: double.parse(_targetAmountController.text.trim()),
        deadline: _selectedDeadline!,
        rules: rules,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Goal created successfully!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputCard(
                label: 'GOAL TITLE',
                icon: Icons.flag_circle_rounded,
                child: TextFormField(
                  controller: _titleController,
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                  decoration: InputDecoration.collapsed(
                    hintText: 'i.e. Laptop',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                ),
              ),
              SizedBox(height: 24),

              _buildInputCard(
                label: 'TARGET AMOUNT(NPR)',
                icon: Icons.money_outlined,
                child: TextFormField(
                  controller: _targetAmountController,
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    final v = double.tryParse(val ?? '');
                    return v == null || v <= 0 ? 'Enter valid amount' : null;
                  },
                  decoration: InputDecoration.collapsed(
                    hintText: '300,000',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                ),
              ),
              SizedBox(height: 24),

              _buildInputCard(
                label: 'TARGET DATE',
                icon: Icons.calendar_today,
                child: InkWell(
                  onTap: _pickDeadline,
                  child: Row(
                    children: [
                      Text(
                        _selectedDeadline == null
                            ? 'Select date'
                            : DateFormat(
                              'MMM dd, yyyy',
                            ).format(_selectedDeadline!),
                        style: TextStyle(
                          color:
                              _selectedDeadline == null
                                  ? Colors.grey[400]
                                  : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32),

              Text('SAVING RULES', style: _sectionStyle),
              SizedBox(height: 8),

              ..._rules.asMap().entries.map(
                (entry) => _buildRuleCard(entry.key, entry.value),
              ),

              TextButton(
                onPressed: _addRule,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 18, color: _primaryColor),
                    SizedBox(width: 4),
                    Text(
                      'ADD RULE',
                      style: TextStyle(
                        color: _primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),

              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(IconlyBold.arrowLeftCircle, color: Colors.teal),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('New Goal', style: TextStyle(fontFamily: 'poppins')),
      centerTitle: true,
    );
  }

  Widget _buildInputCard({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _sectionStyle),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey[500]),
              SizedBox(width: 16),
              Expanded(child: child),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRuleCard(int index, RuleInput rule) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: rule.categoryController,
                        validator: (val) => val!.isEmpty ? 'Required' : null,
                        decoration: InputDecoration(
                          hintText: 'i.e. salary',
                          hintStyle: TextStyle(color: Colors.grey),
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        controller: rule.percentageController,
                        validator: (val) {
                          final p = double.tryParse(val ?? '');
                          return p == null || p <= 0 || p > 100
                              ? 'Invalid'
                              : null;
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'i.e.10',
                          hintStyle: TextStyle(color: Colors.grey),
                          labelText: '%',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          // suffixText: '%',
                        ),
                      ),
                    ),
                    if (_rules.length > 1)
                      IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red[400]),
                        onPressed: () => _removeRule(index),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, Color(0xFF5EFC82)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _isSubmitting ? null : _submit,
          child: Center(
            child:
                _isSubmitting
                    ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : Text(
                      'CREATE GOAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  final TextStyle _sectionStyle = TextStyle(
    color: Colors.grey[600],
    fontWeight: FontWeight.w600,
    fontSize: 13,
    letterSpacing: 0.5,
  );
}

class RuleInput {
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController percentageController = TextEditingController();

  void dispose() {
    categoryController.dispose();
    percentageController.dispose();
  }
}
