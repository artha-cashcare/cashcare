// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:syncfusion_flutter_gauges/gauges.dart'; // <-- Add this import
// import 'package:cashcare/models/goal_model.dart';
// import 'package:cashcare/features/goals/add_edit_goal_screen.dart';
//
// class GoalDetailScreen extends StatelessWidget {
//   final Goal goal;
//
//   const GoalDetailScreen({Key? key, required this.goal}) : super(key: key);
//
//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'reached':
//         return Colors.green;
//       case 'failed':
//         return Colors.red;
//       default:
//         return Colors.blue;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final statusColor = _getStatusColor(goal.status);
//     final currencyFormat = NumberFormat.currency(symbol: 'NPR ');
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Goal Details'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => AddEditGoalScreen(goal: goal),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Progress Gauge
//             Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     Text(
//                       goal.title,
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Chip(
//                       label: Text(
//                         goal.status.replaceAll('_', ' ').toUpperCase(),
//                         style: TextStyle(
//                           color: statusColor,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       backgroundColor: statusColor.withOpacity(0.2),
//                     ),
//                     const SizedBox(height: 16),
//                     SizedBox(
//                       height: 200,
//                       child: SfRadialGauge( // <-- Now properly recognized
//                         axes: <RadialAxis>[
//                           RadialAxis(
//                             minimum: 0,
//                             maximum: 100,
//                             showLabels: false,
//                             showTicks: false,
//                             axisLineStyle: const AxisLineStyle(
//                               thickness: 0.2,
//                               cornerStyle: CornerStyle.bothCurve,
//                               color: Color.fromARGB(30, 0, 169, 181),
//                               thicknessUnit: GaugeSizeUnit.factor,
//                             ),
//                             pointers: <GaugePointer>[
//                               RangePointer(
//                                 value: goal.progressPercentage,
//                                 cornerStyle: CornerStyle.bothCurve,
//                                 width: 0.2,
//                                 sizeUnit: GaugeSizeUnit.factor,
//                                 color: statusColor,
//                               ),
//                             ],
//                             annotations: <GaugeAnnotation>[
//                               GaugeAnnotation(
//                                 positionFactor: 0.1,
//                                 angle: 90,
//                                 widget: Column(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Text(
//                                       '${goal.progressPercentage.toStringAsFixed(0)}%',
//                                       style: TextStyle(
//                                         fontSize: 24,
//                                         fontWeight: FontWeight.bold,
//                                         color: statusColor,
//                                       ),
//                                     ),
//                                     Text(
//                                       'Completed',
//                                       style: TextStyle(
//                                         color: Colors.grey[600],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     // ... rest of your existing code
//                   ],
//                 ),
//               ),
//             ),
//             // ... rest of your widget tree
//           ],
//         ),
//       ),
//     );
//   }
// }