import 'package:flutter/material.dart';
import 'ar_try_on_screen.dart';

class AIProfileScreen extends StatelessWidget {
  const AIProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Beauty Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tell us about yourself and let our AI personalize your style!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            _buildDropdown('Skin Type', ['Dry', 'Oily', 'Combination', 'Sensitive']),
            const SizedBox(height: 16),
            _buildDropdown('Hair Type', ['Straight', 'Wavy', 'Curly', 'Coily']),
            const SizedBox(height: 16),
            _buildDropdown('Primary Goal', ['Hydration', 'Anti-aging', 'Hair Volume', 'Glow']),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate Matches'),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ARTryOnScreen()));
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Virtual Try-On (AR)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (val) {},
    );
  }
}
