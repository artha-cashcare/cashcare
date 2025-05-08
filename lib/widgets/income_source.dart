import 'package:flutter/material.dart';
import 'package:cashcare/models/income_source.dart';
class SourceButton extends StatelessWidget {
  final IncomeSource source;
  final bool isSelected;
  final VoidCallback onTap;

  const SourceButton({
    required this.source,
    required this.isSelected,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? source.color.withOpacity(0.2) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? source.color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(source.icon, size: 30, color: source.color),
            const SizedBox(height: 8),
            Text(
              source.name,
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