import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../services/places_service.dart';

class ParlourListingScreen extends StatefulWidget {
  const ParlourListingScreen({super.key});

  @override
  State<ParlourListingScreen> createState() => _ParlourListingScreenState();
}

class _ParlourListingScreenState extends State<ParlourListingScreen> {
  late Future<List<dynamic>> parlours;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final city =
        ModalRoute.of(context)!.settings.arguments as String;
    parlours = PlacesService.searchParlours(city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Parlours'),
        backgroundColor: AppColors.primary,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: parlours,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          }

          final results = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final p = results[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['name'], style: AppTextStyles.cardTitle),
                    const SizedBox(height: 4),
                    Text(
                      p['formatted_address'] ?? '',
                      style: AppTextStyles.smallText,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}