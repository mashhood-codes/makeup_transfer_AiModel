import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../booking/views/booking_screen.dart';

class ParlorDetailScreen extends StatelessWidget {
  const ParlorDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Elite Studio'),
              background: ColoredBox(
                color: Colors.grey,
                child: Icon(Icons.image, size: 100, color: Colors.white),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Elite Studio', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Row(
                        children: const [
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          Text(' 4.8 (120 reviews)', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('123 Beauty Blvd, New York, NY', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  const SizedBox(height: 24),
                  const Text('Services', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildServiceTile(context, 'Haircut & Styling', '\$50', '45 mins'),
                  _buildServiceTile(context, 'Bridal Makeup', '\$150', '90 mins'),
                  _buildServiceTile(context, 'Facial Glow', '\$80', '60 mins'),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, -5), blurRadius: 10),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const BookingScreen()));
          },
          child: const Text('Book Appointment'),
        ),
      ),
    );
  }

  Widget _buildServiceTile(BuildContext context, String name, String price, String duration) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(duration),
        trailing: Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
      ),
    );
  }
}
