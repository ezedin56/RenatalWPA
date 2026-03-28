import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/listing_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key('fav_$index'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: AppColors.error,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              // Remove logic
            },
            child: ListingCard(
              title: 'Saved Property $index',
              location: 'Location $index',
              price: '\$${index * 200}/mo',
              imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
              beds: 3,
              baths: 2,
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
