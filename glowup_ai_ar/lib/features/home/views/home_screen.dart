import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

import '../../ai_profile/views/ai_profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global AI Parlor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAIRecommendationCard(context),
              const SizedBox(height: 24),
              const Text('Categories', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildCategoriesList(),
              const SizedBox(height: 24),
              const Text('Top Rated Salons', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTopSalons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIRecommendationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI Beauty Match', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Discover styles perfect for your profile', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AIProfileScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text('Try Now'),
                )
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.auto_awesome, size: 48, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
    final categories = [
      {'icon': Icons.content_cut, 'name': 'Haircut'},
      {'icon': Icons.brush, 'name': 'Makeup'},
      {'icon': Icons.spa, 'name': 'Spa'},
      {'icon': Icons.face, 'name': 'Facial'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: categories.map((cat) => Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Icon(cat['icon'] as IconData, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(cat['name'] as String, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      )).toList(),
    );
  }

  Widget _buildTopSalons() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 60,
                height: 60,
                color: Colors.grey[200],
                child: const Icon(Icons.store, color: Colors.grey),
              ),
            ),
            title: Text('Luxury Parlor ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('New York, NY \u2022 4.9 \u2605'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        );
      },
    );
  }
}
