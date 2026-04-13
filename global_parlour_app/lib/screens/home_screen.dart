import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController cityController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Global Parlour Network'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Find Parlours Near You', style: AppTextStyles.heading),
            const SizedBox(height: 6),

            Text(
              'Enter your city to see nearby parlours',
              style: AppTextStyles.subHeading,
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  hintText: 'Enter city (e.g. Karachi)',
                  border: InputBorder.none,
                  icon: Icon(Icons.location_city),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (cityController.text.isNotEmpty) {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.parlourListing,
                      arguments: cityController.text,
                    );
                  }
                },
                child: const Text('Search Parlours'),
              ),
            ),

            const SizedBox(height: 30),

            Text('About This App', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'This mobile application allows users to search beauty parlours '
                'based on city location. It works with a web-based admin system '
                'and demonstrates location-based filtering using dummy data '
                'for academic and project purposes.',
                style: AppTextStyles.subHeading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}