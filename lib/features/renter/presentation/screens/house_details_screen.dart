import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/listing_model.dart';
import 'package:rental_app/features/renter/application/providers/inquiry_provider.dart';

class HouseDetailsScreen extends ConsumerWidget {
  final ListingModel listing;

  const HouseDetailsScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                listing.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            actions: [
              IconButton(
                icon: const CircleAvatar(backgroundColor: Colors.white54, child: Icon(Icons.share, color: Colors.black)), 
                onPressed: () {}
              ),
              IconButton(
                icon: const CircleAvatar(backgroundColor: Colors.white54, child: Icon(Icons.favorite_border, color: Colors.black)), 
                onPressed: () {}
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(listing.price, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 8),
                  Text(listing.location, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDetailIcon(Icons.bed, '${listing.beds} Beds'),
                      _buildDetailIcon(Icons.bathtub, '${listing.baths} Baths'),
                      _buildDetailIcon(Icons.square_foot, '2500 sqft'),
                    ],
                  ),
                  const Divider(height: 48),
                  const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text(
                    'This beautiful property features modern kitchen appliances, and large windows bringing in plenty of natural light. Perfect for individuals or families seeking comfortable living in a prime location within Addis Ababa.',
                    style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                  ),
                  const Divider(height: 48),
                  const Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Text('Map View Placeholder', style: TextStyle(color: AppColors.textSecondary))),
                  ),
                  const SizedBox(height: 100), // Padding for sticky button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: ElevatedButton(
          onPressed: () {
            // Check if inquiry already exists
            final inquiries = ref.read(inquiryProvider);
            final existing = inquiries.where((info) => info.listing.title == listing.title).toList();
            
            String inquiryId;
            if (existing.isEmpty) {
              // Create new inquiry
              ref.read(inquiryProvider.notifier).addInquiry(
                listing, 
                "Hi! I'm interested in renting this ${listing.title}. Is it still available?"
              );
              // Get the newly created id (it will be the first one)
              inquiryId = ref.read(inquiryProvider).first.id;
            } else {
              inquiryId = existing.first.id;
            }
            
            context.push('/inquiries/chat/$inquiryId');
          },
          child: const Text('Contact Host'),
        ),
      ),
    );
  }

  Widget _buildDetailIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 28),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
