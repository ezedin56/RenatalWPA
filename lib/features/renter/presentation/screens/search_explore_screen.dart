import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/listing_card.dart';
import 'package:go_router/go_router.dart';

class SearchExploreScreen extends StatefulWidget {
  const SearchExploreScreen({super.key});

  @override
  State<SearchExploreScreen> createState() => _SearchExploreScreenState();
}

class _SearchExploreScreenState extends State<SearchExploreScreen> {
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () {}, child: const Text('Reset', style: TextStyle(color: AppColors.primary))),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                children: [
                  const Text('Price Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  RangeSlider(
                    values: const RangeValues(200, 2000),
                    min: 0,
                    max: 5000,
                    activeColor: AppColors.primary,
                    onChanged: (values) {},
                  ),
                  const SizedBox(height: 24),
                  const Text('Bedrooms', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildChip('Any', true),
                      _buildChip('1', false),
                      _buildChip('2', false),
                      _buildChip('3+', false),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Property Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip('House', true),
                      _buildChip('Apartment', false),
                      _buildChip('Condo', false),
                      _buildChip('Townhouse', false),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Apply Filters')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {},
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
      ),
      showCheckmark: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search by location...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              suffixIcon: IconButton(
                icon: const Icon(Icons.tune, color: AppColors.primary),
                onPressed: _showFilterBottomSheet,
              ),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.70,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return ListingCard(
                    title: 'Property \$index',
                    location: 'Location \$index',
                    price: '\$${index * 100}/mo',
                    imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                    beds: 2,
                    baths: 1,
                    onTap: () {
                      context.push('/details'); // Push over ShellRoute
                    },
                  );
                },
                childCount: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
