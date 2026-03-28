import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class PremiumUpgradeScreen extends StatefulWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  State<PremiumUpgradeScreen> createState() => _PremiumUpgradeScreenState();
}

class _PremiumUpgradeScreenState extends State<PremiumUpgradeScreen> {
  bool _isProcessing = false;

  void _simulateMPesa() async {
    setState(() => _isProcessing = true);
    
    // Simulate STK Push delay
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      setState(() => _isProcessing = false);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Payment Successful'),
          content: const Text('Your transaction of ETB 500 was successful. You are now a Premium Owner!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                context.pop(); // go back to dashboard
              },
              child: const Text('Awesome!'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('M-Pesa Ethiopia', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.payment, size: 80, color: AppColors.success),
              const SizedBox(height: 24),
              const Text('M-Pesa Safaricom Ethiopia', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              const Text('Enter your Safaricom phone number to receive the prompt.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 32),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Phone Number (e.g. +251 9... or 09...)',
                  prefixIcon: Icon(Icons.phone_android),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Total Amount:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('ETB 500', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                onPressed: _isProcessing ? null : _simulateMPesa,
                child: _isProcessing 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Send STK Push'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
