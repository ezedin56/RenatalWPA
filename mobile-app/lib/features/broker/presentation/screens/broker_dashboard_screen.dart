import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/listing_card.dart';
import 'package:go_router/go_router.dart';

class BrokerDashboardScreen extends StatelessWidget {
  const BrokerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: const Text('Broker Dashboard', style: TextStyle(color: AppColors.textPrimary)),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'My Managed Listings'),
              Tab(text: 'My Clients (Owners)'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Listings
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Listing for Client'),
                    onPressed: () => context.push('/owner/add-listing'),
                  ),
                  const SizedBox(height: 24),
                  ListingCard(
                    title: 'Client Property 1',
                    location: 'Bole, Addis Ababa',
                    price: '\$1,000/mo',
                    imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                    beds: 3,
                    baths: 2,
                    isPremium: false,
                    onTap: () {},
                  ),
                  ListingCard(
                    title: 'Client Property 2',
                    location: 'Piazza, Addis Ababa',
                    price: '\$800/mo',
                    imageUrl: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                    beds: 2,
                    baths: 1,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            // Tab 2: Clients
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.surface,
                      child: Icon(Icons.person, color: AppColors.textSecondary),
                    ),
                    title: Text('Client ${index + 1}'),
                    subtitle: const Text('2 Properties Managed'),
                    trailing: IconButton(
                      icon: const Icon(Icons.phone, color: AppColors.primary),
                      onPressed: () {},
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.secondary,
          onPressed: () {},
          child: const Icon(Icons.person_add),
        ),
      ),
    );
  }
}
