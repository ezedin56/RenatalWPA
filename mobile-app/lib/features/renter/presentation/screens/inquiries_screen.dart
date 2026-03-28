import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:rental_app/features/renter/application/providers/inquiry_provider.dart';

class InquiriesScreen extends ConsumerWidget {
  const InquiriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inquiries = ref.watch(inquiryProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('My Inquiries', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text('${inquiries.length} conversations', style: const TextStyle(color: AppColors.textSecondary)),
          ),
        ),
      ),
      body: inquiries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  const Text('No inquiries yet', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: inquiries.length,
              itemBuilder: (context, index) {
                final inquiry = inquiries[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  color: Colors.white,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        inquiry.listing.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(inquiry.listing.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        if (inquiry.isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                            child: const Text('New', style: TextStyle(color: Colors.white, fontSize: 10)),
                          )
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(inquiry.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    onTap: () => context.push('/inquiries/chat/${inquiry.id}'),
                  ),
                );
              },
            ),
    );
  }
}
