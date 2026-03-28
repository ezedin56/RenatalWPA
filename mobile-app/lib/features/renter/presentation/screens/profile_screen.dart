import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/application/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.surface,
                    child: Icon(Icons.person, size: 40, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? 'Guest User', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text(user?.email ?? 'No email available', style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(4)),
                        child: Text(user?.role ?? 'User Account', style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Owner Mode',
              context: context,
              items: [
                _buildMenuItem(
                  context, 
                  Icons.switch_account_outlined, 
                  'Switch to Owner Dashboard', 
                  onTap: () => context.push('/owner/dashboard'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Account Settings',
              context: context,
              items: [
                _buildMenuItem(context, Icons.person_outline, 'Personal Information'),
                _buildMenuItem(context, Icons.payment, 'Payment Methods', onTap: () => context.push('/profile/payments')),
                _buildMenuItem(context, Icons.notifications_outlined, 'Notifications'),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Support',
              context: context,
              items: [
                _buildMenuItem(context, Icons.help_outline, 'Help Center'),
                _buildMenuItem(context, Icons.privacy_tip_outlined, 'Terms & Privacy Policy'),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              color: Colors.white,
              child: ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text('Log Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                onTap: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/welcome');
                  }
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> items, required BuildContext context}) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap ?? () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title is coming soon!')),
        );
      },
    );
  }
}
