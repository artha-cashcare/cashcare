import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Terms & Conditions', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSection(
                title: "Acceptance of Terms",
                content: "By using CashCare, you agree to these terms. Disagreeing means you can't use our service."
            ),
            _buildSection(
                title: "Your Responsibilities",
                content: "• Keep your account secure\n• Don't misuse the app\n• Provide accurate info"
            ),
            _buildSection(
                title: "Data Privacy",
                content: "We collect and process personal data as described in our Privacy Policy.\n"
                    "By using CashCare, you consent to such processing."
            ),
            _buildSection(
                title: "Premium Features",
                content: "Payment will be charged to your account."
                    " No refunds for unused periods"
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Terms accepted"), backgroundColor: Colors.green),
                );
              },
              child: const Text("I Accept", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 15, height: 1.6)),
        ],
      ),
    );
  }
}