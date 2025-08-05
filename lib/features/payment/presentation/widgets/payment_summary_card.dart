import 'package:flutter/material.dart';

class PaymentSummaryCard extends StatelessWidget {
  final String orderId;
  final double amount;
  final String customerName;
  final String customerEmail;

  const PaymentSummaryCard({
    super.key,
    required this.orderId,
    required this.amount,
    required this.customerName,
    required this.customerEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Order ID', orderId),
            _buildSummaryRow('Amount', 'रू${amount.toStringAsFixed(2)}'),
            _buildSummaryRow('Customer', customerName),
            _buildSummaryRow('Email', customerEmail),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
