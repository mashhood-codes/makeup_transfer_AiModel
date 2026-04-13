import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import 'subscription_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text('Jane Doe', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('jane.doe@example.com', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.card_membership, color: AppColors.primary),
              title: const Text('World Parlor Pass'),
              subtitle: const Text('Unlock premium features'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionScreen()));
              },
            ),
            const Divider(),
            _buildActionItem(Icons.history, 'Booking History'),
            _buildActionItem(Icons.favorite_border, 'Saved Parlors'),
            _buildActionItem(Icons.payment, 'Payment Methods'),
            _buildActionItem(Icons.help_outline, 'Help & Support'),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
