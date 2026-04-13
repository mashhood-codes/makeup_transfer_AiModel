import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../routes/app_routes.dart';

class ParlourDetailScreen extends StatelessWidget {
  const ParlourDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parlour Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network('https://i.imgur.com/l1.jpg', height: 200, fit: BoxFit.cover),
            const SizedBox(height: 16),
            const Text('Beauty Hub', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Services: Hair, Makeup, Spa', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            CustomButton(text: 'Book Now', onPressed: () {
              Navigator.pushNamed(context, AppRoutes.booking);
            })
          ],
        ),
      ),
    );
  }
}