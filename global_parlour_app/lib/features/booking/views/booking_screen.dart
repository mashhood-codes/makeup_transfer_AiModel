import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import 'payment_screen.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selected Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Card(
              child: ListTile(
                title: Text('Haircut & Styling'),
                subtitle: Text('Elite Studio'),
                trailing: Text('\$50', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Select Date', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 30)),
              onDateChanged: (date) {},
            ),
            const SizedBox(height: 24),
            const Text('Select Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildTimeChip('10:00 AM', isSelected: false),
                _buildTimeChip('11:30 AM', isSelected: true),
                _buildTimeChip('01:00 PM', isSelected: false),
                _buildTimeChip('02:30 PM', isSelected: false),
                _buildTimeChip('04:00 PM', isSelected: false),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, -5), blurRadius: 10),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentScreen()));
          },
          child: const Text('Proceed to Payment'),
        ),
      ),
    );
  }

  Widget _buildTimeChip(String time, {required bool isSelected}) {
    return ChoiceChip(
      label: Text(time),
      selected: isSelected,
      onSelected: (val) {},
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }
}
