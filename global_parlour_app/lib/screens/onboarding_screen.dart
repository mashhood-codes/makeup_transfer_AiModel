import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../widgets/custom_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                children: [
                  buildPage(
                    'Discover Parlours',
                    'Find the best beauty parlours near you',
                    'https://via.placeholder.com/300x300?text=Discover+Parlours',
                  ),
                  buildPage(
                    'Book Services',
                    'Book hair, makeup, massage and more',
                    'https://via.placeholder.com/300x300?text=Book+Services',
                  ),
                  buildPage(
                    'Enjoy Experience',
                    'Enjoy professional beauty services',
                    'https://via.placeholder.com/300x300?text=Enjoy+Experience',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: CustomButton(
                text: 'Get Started',
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.signup);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPage(String title, String subtitle, String imageUrl) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.network(
          imageUrl,
          height: 300,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 300,
              color: Colors.grey[300],
              child: const Icon(
                Icons.image_not_supported,
                size: 100,
                color: Colors.grey,
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
