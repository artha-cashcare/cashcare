import 'package:flutter/material.dart';
import '../models/recommendation.dart' show Recommendation;

class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;

  const RecommendationCard({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.deepOrange.shade400, size: 26),
                const SizedBox(width: 10),
                Text(
                  'Spending Alert',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.deepOrange.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              recommendation.message,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  children: [
                    const TextSpan(
                      text: 'Highest spending category ',
                      // style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: recommendation.highestSource,
                      style: const TextStyle(
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(text: ' with ',style: TextStyle(fontSize: 15)),
                    TextSpan(
                      text: 'Rs.${recommendation.highestExpense.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
