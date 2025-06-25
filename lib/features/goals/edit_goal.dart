// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:cashcare/models/goal_model.dart';
// import 'package:cashcare/services/goal_service.dart';
//
// class AddEditGoalScreen extends StatefulWidget {
//   final Goal? goal;
//
//   const AddEditGoalScreen({Key? key, this.goal}) : super(key: key);
//
//   @override
//   _AddEditGoalScreenState createState() => _AddEditGoalScreenState();
// }
//
// class _AddEditGoalScreenState extends State<AddEditGoalScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _targetAmountController = TextEditingController();
//   final _currentAmountController = TextEditingController();
//   final _reminderDateController = TextEditingController();
//   final GoalService _goalService = GoalService();
//   DateTime? _deadline;
//   String _reminderFrequency = 'monthly';
//   bool _isReminderActive = false;
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.goal != null) {
//       _titleController.text = widget.goal!.title;
//       _descriptionController.text = widget.goal!.description;
//       _targetAmountController.text = widget.goal!.targetAmount.toStringAsFixed(2);
//       _currentAmountController.text = widget.goal!.currentAmount.toStringAsFixed(2);
//       _deadline = widget.goal!.deadline;
//       _reminderDateController.text = widget.goal!.reminderDate?.toString() ?? '';
//       _reminderFrequency = widget.goal!.reminderFrequency;
//       _isReminderActive = widget.goal!.isReminderActive;
//     } else {
//       _currentAmountController.text = '0.00';
//     }
//   }
//
//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     _targetAmountController.dispose();
//     _currentAmountController.dispose();
//     _reminderDateController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null && picked != _deadline) {
//       setState(() => _deadline = picked);
//     }
//   }
//
//   Future<void> _saveGoal() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_deadline == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a deadline')),
//       );
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       final goal = Goal(
//         id: widget.goal?.id,
//         title: _titleController.text,
//         description: _descriptionController.text,
//         targetAmount: double.parse(_targetAmountController.text),
//         currentAmount: double.parse(_currentAmountController.text),
//         deadline: _deadline!,
//         reminderDate: _isReminderActive && _reminderDateController.text.isNotEmpty
//             ? int.parse(_reminderDateController.text)
//             : null,
//         reminderFrequency: _reminderFrequency,
//         isReminderActive: _isReminderActive,
//         status: widget.goal?.status ?? 'in_progress',
//         createdAt: widget.goal?.createdAt ?? DateTime.now(),
//         updatedAt: DateTime.now(),
//       );
//
//       if (widget.goal == null) {
//         await _goalService.createGoal(goal);
//       } else {
//         await _goalService.updateGoal(goal);
//       }
//
//       if (mounted) {
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: ${e.toString()}')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.goal == null ? 'Add Goal' : 'Edit Goal'),
//         actions: [
//           if (widget.goal != null)
//             IconButton(
//               icon: const Icon(Icons.delete),
//               onPressed: _isLoading
//                   ? null
//                   : () async {
//                 setState(() => _isLoading = true);
//                 try {
//                   await _goalService.deleteGoal(widget.goal!.id!);
//                   if (mounted) {
//                     Navigator.pop(context);
//                   }
//                 } catch (e) {
//                   if (mounted) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Error: ${e.toString()}')),
//                     );
//                   }
//                 } finally {
//                   if (mounted) {
//                     setState(() => _isLoading = false);
//                   }
//                 }
//               },
//             ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               TextFormField(
//                 controller: _titleController,
//                 decoration: const InputDecoration(
//                   labelText: 'Goal Title',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a title';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _descriptionController,
//                 decoration: const InputDecoration(
//                   labelText: 'Description (Optional)',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _targetAmountController,
//                 decoration: const InputDecoration(
//                   labelText: 'Target Amount (NPR)',
//                   border: OutlineInputBorder(),
//                   prefixText: 'NPR ',
//                 ),
//                 keyboardType: TextInputType.number,
//                 inputFormatters: [
//                   FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
//                 ],
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter an amount';
//                   }
//                   if (double.tryParse(value) == null) {
//                     return 'Please enter a valid number';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _currentAmountController,
//                 decoration: const InputDecoration(
//                   labelText: 'Current Amount (NPR)',
//                   border: OutlineInputBorder(),
//                   prefixText: 'NPR ',
//                 ),
//                 keyboardType: TextInputType.number,
//                 inputFormatters: [
//                   FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
//                 ],
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter an amount';
//                   }
//                   if (double.tryParse(value) == null) {
//                     return 'Please enter a valid number';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               InkWell(
//                 onTap: () => _selectDate(context),
//                 child: InputDecorator(
//                   decoration: const InputDecoration(
//                     labelText: 'Deadline',
//                     border: OutlineInputBorder(),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         _deadline == null
//                             ? 'Select a date'
//                             : DateFormat('MMM dd, yyyy').format(_deadline!),
//                       ),
//                       const Icon(Icons.calendar_today),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               SwitchListTile(
//                 title: const Text('Enable Reminders'),
//                 value: _isReminderActive,
//                 onChanged: (value) {
//                   setState(() => _isReminderActive = value);
//                 },
//               ),
//               if (_isReminderActive) ...[
//                 const SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   value: _reminderFrequency,
//                   decoration: const InputDecoration(
//                     labelText: 'Reminder Frequency',
//                     border: OutlineInputBorder(),
//                   ),
//                   items: const [
//                     DropdownMenuItem(
//                       value: 'daily',
//                       child: Text('Daily'),
//                     ),
//                     DropdownMenuItem(
//                       value: 'weekly',
//                       child: Text('Weekly'),
//                     ),
//                     DropdownMenuItem(
//                       value: 'monthly',
//                       child: Text('Monthly'),
//                     ),
//                     DropdownMenuItem(
//                       value: 'yearly',
//                       child: Text('Yearly'),
//                     ),
//                   ],
//                   onChanged: (value) {
//                     setState(() => _reminderFrequency = value!);
//                   },
//                 ),
//                 if (_reminderFrequency == 'monthly') ...[
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _reminderDateController,
//                     decoration: const InputDecoration(
//                       labelText: 'Reminder Day of Month (1-31)',
//                       border: OutlineInputBorder(),
//                     ),
//                     keyboardType: TextInputType.number,
//                     inputFormatters: [
//                       FilteringTextInputFormatter.digitsOnly,
//                       LengthLimitingTextInputFormatter(2),
//                     ],
//                     validator: _isReminderActive
//                         ? (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter a day';
//                       }
//                       final day = int.tryParse(value);
//                       if (day == null || day < 1 || day > 31) {
//                         return 'Please enter a valid day (1-31)';
//                       }
//                       return null;
//                     }
//                         : null,
//                   ),
//                 ],
//               ],
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: _saveGoal,
//                 child: const Text('Save Goal'),
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }