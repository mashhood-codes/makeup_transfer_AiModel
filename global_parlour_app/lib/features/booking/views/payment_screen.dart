import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Total Amount', style: TextStyle(fontSize: 16)),
            const Text('\$50.00', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildPaymentOption(Icons.credit_card, 'Credit/Debit Card', isSelected: true),
            _buildPaymentOption(Icons.account_balance_wallet, 'PayPal', isSelected: false),
            _buildPaymentOption(Icons.phone_android, 'Apple/Google Pay', isSelected: false),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                _showSuccessDialog(context);
              },
              child: const Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(IconData icon, String label, {required bool isSelected}) {
    return Card(
      color: isSelected ? Colors.pink[50] : null,
      shape: RoundedRectangleBorder(
        side: isSelected ? const BorderSide(color: Colors.pink, width: 2) : BorderSide.none,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.pink : Colors.grey),
        title: Text(label),
        trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.pink) : null,
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        title: const Text('Booking Confirmed!'),
        content: const Text('Your appointment at Elite Studio has been successfully booked.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/main');
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}
