import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class OwnerInquiriesScreen extends StatelessWidget {
  const OwnerInquiriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Inquiry Management', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
                    child: const TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: 'Filter by property...',
                        icon: Icon(Icons.filter_list),
                        fillColor: Colors.transparent,
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  color: Colors.white,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.surface,
                      child: Icon(Icons.person, color: AppColors.textSecondary),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Renter Name $index', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Text('2h ago', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        const Text('Re: Modern Luxury Villa', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                        const SizedBox(height: 4),
                        const Text("Is this property still available for next month?", maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                    trailing: index == 0 ? Container(
                      width: 12, height: 12,
                      decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                    ) : null,
                    onTap: () {
                      // Open reply modal or chat thread
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
