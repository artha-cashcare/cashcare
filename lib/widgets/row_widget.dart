import 'package:flutter/material.dart';

class RowWidget extends StatelessWidget {
  final String title;
  final String amount;
  final Color amountColor;
  final bool isamtvisible;

  const RowWidget({
    Key? key,
    required this.title,
    required this.amount,
    this.amountColor = Colors.green, //default
    required this.isamtvisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            isamtvisible ? amount : '****',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
