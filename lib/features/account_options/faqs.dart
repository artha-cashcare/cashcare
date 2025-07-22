import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class FAQScreen extends StatefulWidget {
  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<FAQItem> _faqs = [
    FAQItem(
      question: "What is the SMS Parsing feature?",
      answer: "This feature extracts transaction details like date,amount from your SMS messages.",
    ),
    FAQItem(
      question: "How do I add a new receipt?",
      answer: "Tap the Upload or Capture button and select an image of your receipt.",
    ),
    FAQItem(
      question: "How do I categorize my expenses?",
      answer: "Choose a category while reviewing the receipt data.",
    ),
    FAQItem(
      question: "How do I update my profile?",
      answer: "Go to the Profile section and tap on \"Edit\".",
    ),
    FAQItem(
      question: "What is the SMS Parsing feature?",
      answer: "This feature automatically extracts transaction details including merchant name, transaction date, and amount from your SMS messages, helping you track expenses effortlessly.",
    ),
    FAQItem(
      question: "How do I add a new receipt?",
      answer: "Simply tap the 'Upload' button and select an image of your receipt. Our system will automatically scan and extract the relevant information.",
    ),
    FAQItem(
      question: "How do I categorize my expenses?",
      answer: "When reviewing your receipt data, you'll be prompted to select an appropriate category from our comprehensive list of expense types.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'FAQs',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(IconlyLight.arrowLeft, color: Colors.grey[800]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                physics: BouncingScrollPhysics(),
                itemCount: _faqs.length,
                separatorBuilder: (context, index) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildFAQCard(_faqs[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Row(
        children: [
          Icon(IconlyLight.infoSquare, color: Colors.green[800], size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Frequently Asked Questions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQCard(FAQItem faq) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        collapsedBackgroundColor: Colors.white,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        childrenPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.green[100],
            shape: BoxShape.circle,
          ),
          child: Icon(IconlyLight.document, color: Colors.green[800], size: 20),
        ),
        title: Text(
          faq.question,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.grey[800],
          ),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.grey[500],
        ),
        onExpansionChanged: (expanded) {
          // Optional: Add haptic feedback
          // HapticFeedback.lightImpact();
        },
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              faq.answer,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}