import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class SearchFilterScreen extends StatelessWidget {
  const SearchFilterScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search & Filter')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(controller: TextEditingController(), hintText: 'Search Parlours', icon: Icons.search),
            const SizedBox(height: 20),
            CustomButton(text: 'Apply Filters', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}