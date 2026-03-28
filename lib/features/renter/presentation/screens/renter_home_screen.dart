import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/listing_card.dart';
import '../../domain/models/listing_model.dart';

class RenterHomeScreen extends StatefulWidget {
  const RenterHomeScreen({super.key});

  @override
  State<RenterHomeScreen> createState() => _RenterHomeScreenState();
}

class _RenterHomeScreenState extends State<RenterHomeScreen> {
  final List<String> _filters = ['All', 'House', 'Apartment', 'Condo', 'Studio'];
  int _selectedFilterIndex = 0;

  final List<ListingModel> _allListings = [
    ListingModel(
      id: '1',
      title: 'Modern Luxury Villa',
      location: 'Bole, Addis Ababa',
      price: '\$1,200/mo',
      imageUrl: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      beds: 4,
      baths: 3,
      isPremium: true,
      category: 'House',
    ),
    ListingModel(
      id: '2',
      title: 'Cozy Downtown Condo',
      location: 'Piazza, Addis Ababa',
      price: '\$650/mo',
      imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      beds: 2,
      baths: 1,
      category: 'Condo',
    ),
    ListingModel(
      id: '3',
      title: 'Elegant Studio Apartment',
      location: 'Kazanchis, Addis Ababa',
      price: '\$850/mo',
      imageUrl: 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      beds: 1,
      baths: 1,
      isPremium: true,
      category: 'Apartment',
    ),
    ListingModel(
      id: '4',
      title: 'Skyline Penthouse',
      location: 'Bole Atlas, Addis Ababa',
      price: '\$2,500/mo',
      imageUrl: 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      beds: 3,
      baths: 3,
      category: 'Apartment',
    ),
    ListingModel(
      id: '5',
      title: 'Compact Urban Studio',
      location: 'Megenagna, Addis Ababa',
      price: '\$450/mo',
      imageUrl: 'https://images.unsplash.com/photo-1536376074432-8d64216a7244?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      beds: 1,
      baths: 1,
      category: 'Studio',
    ),
    ListingModel(
      id: '6',
      title: 'Family Sized House',
      location: 'Old Airport, Addis Ababa',
      price: '\$1,800/mo',
      imageUrl: 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      beds: 5,
      baths: 4,
      category: 'House',
    ),
  ];

  List<ListingModel> get _filteredListings {
    final selectedFilter = _filters[_selectedFilterIndex];
    if (selectedFilter == 'All') return _allListings;
    return _allListings.where((l) => l.category == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildFilters(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _filters[_selectedFilterIndex] == 'All' 
                        ? 'Featured Listings' 
                        : '${_filters[_selectedFilterIndex]} Listings',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 18),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('See All', style: TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
              _buildListings(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning, Ezedin 👋',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Addis Ababa, ET',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 16),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                ],
              ),
            ],
          ),
          Stack(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  height: 12,
                  width: 12,
                  decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search properties...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            Container(
              height: 24,
              width: 1,
              color: AppColors.border,
              margin: const EdgeInsets.symmetric(horizontal: 12),
            ),
            const Icon(Icons.tune, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(_filters[index]),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedFilterIndex = index);
                }
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildListings() {
    final listings = _filteredListings;
    
    if (listings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.home_work_outlined, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text(
                'No listings found for this category',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: listings.map((listing) => ListingCard(
          title: listing.title,
          location: listing.location,
          price: listing.price,
          imageUrl: listing.imageUrl,
          beds: listing.beds,
          baths: listing.baths,
          isPremium: listing.isPremium,
          onTap: () => context.push('/details', extra: listing),
        )).toList(),
      ),
    );
  }
}
