import 'package:cashcare/models/goal_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cashcare/services/goal_service.dart';

class GoalCreationForm extends StatefulWidget {
  @override
  _GoalCreationFormState createState() => _GoalCreationFormState();
}

class _GoalCreationFormState extends State<GoalCreationForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetAmountController = TextEditingController();
  DateTime? _selectedDeadline;
  List<RuleInput> _rules = [RuleInput()];
  bool _isSubmitting = false;

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

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _rules.forEach((r) => r.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deadlineText =
        _selectedDeadline == null
            ? 'Select Deadline'
            : DateFormat.yMMMMd().format(_selectedDeadline!);

    return Scaffold(
      appBar: AppBar(title: Text('Create Goal')),
      body:
          _isSubmitting
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: _inputDecoration('Goal Title', Icons.title),
                        validator:
                            (val) =>
                                val!.trim().isEmpty ? 'Enter goal title' : null,
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _targetAmountController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _inputDecoration(
                          'Target Amount (₹)',
                          Icons.attach_money,
                        ),
                        validator: (val) {
                          final v = double.tryParse(val ?? '');
                          if (v == null || v <= 0) return 'Enter valid amount';
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      InkWell(
                        onTap: _pickDeadline,
                        child: InputDecorator(
                          decoration: _inputDecoration(
                            'Deadline',
                            Icons.calendar_today,
                          ),
                          child: Text(
                            deadlineText,
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  _selectedDeadline == null
                                      ? Colors.grey
                                      : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Savings Rules',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          TextButton.icon(
                            icon: Icon(Icons.add),
                            label: Text('Add Rule'),
                            onPressed: _addRule,
                          ),
                        ],
                      ),
                      ..._rules
                          .asMap()
                          .entries
                          .map(
                            (entry) => _buildRuleInput(entry.key, entry.value),
                          )
                          .toList(),

                      SizedBox(height: 32),

                      ElevatedButton.icon(
                        icon: Icon(Icons.check),
                        label: Text('Create Goal'),
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildRuleInput(int index, RuleInput rule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: rule.categoryController,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                hintText: 'e.g. salary',
              ),
              validator: (val) => val!.isEmpty ? 'Enter category' : null,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: rule.percentageController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: '%',
                border: OutlineInputBorder(),
                suffixText: '%',
              ),
              validator: (val) {
                final p = double.tryParse(val ?? '');
                if (p == null || p <= 0 || p > 100) return '0 < % ≤ 100';
                return null;
              },
            ),
          ),
          if (_rules.length > 1)
            IconButton(
              icon: Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () => _removeRule(index),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(),
    );
  }
}

class RuleInput {
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController percentageController = TextEditingController();

  void dispose() {
    categoryController.dispose();
    percentageController.dispose();
  }
}
