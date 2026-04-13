import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Select Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButton<String>(
              items: ['Haircut','Makeup','Massage'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),
              onChanged: (value){},
              hint: const Text('Choose Service'),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Confirm Booking',
              onPressed: (){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking Confirmed'))
                );
              }
            )
          ],
        ),
      ),
    );
  }
}