import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 20),
            const Text('User Name', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('user@example.com', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            CustomButton(text: 'Logout', onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            }, isOutline: true),
          ],
        ),
      ),
    );
  }
}