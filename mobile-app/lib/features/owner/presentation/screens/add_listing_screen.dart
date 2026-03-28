import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  int _currentStep = 0;

  void _onStepContinue() {
    if (_currentStep < 5) {
      setState(() => _currentStep += 1);
    } else {
      _showPremiumUpgradeModal();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    } else {
      context.pop();
    }
  }

  void _showPremiumUpgradeModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.star, color: AppColors.secondary, size: 48),
            const SizedBox(height: 16),
            const Text('Upgrade to Premium', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            const Text('Boost your listing to get 5x more views and prioritize placement in search results.', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            _buildFeatureRow(Icons.check_circle, 'Unlimited active listings'),
            _buildFeatureRow(Icons.check_circle, 'Featured placement in search'),
            _buildFeatureRow(Icons.check_circle, 'Verified badge on profile'),
            const SizedBox(height: 24),
            const Text('ETB 500 / month', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
              onPressed: () {
                Navigator.pop(context);
                context.push('/owner/premium-payment');
              },
              child: const Text('Upgrade with M-Pesa'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.pop(); // Go back to dashboard with published listing
              },
              child: const Text('Publish for Free (1 Remaining)'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.success, size: 20),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Listing', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          return Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: Text(_currentStep == 5 ? 'Preview & Publish' : 'Continue'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
                ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Basic Information'),
            content: Column(
              children: const [
                TextField(decoration: InputDecoration(labelText: 'Property Title')),
                SizedBox(height: 16),
                TextField(decoration: InputDecoration(labelText: 'Property Type (e.g. Apartment, House)')),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: TextField(decoration: InputDecoration(labelText: 'Bedrooms'), keyboardType: TextInputType.number)),
                    SizedBox(width: 16),
                    Expanded(child: TextField(decoration: InputDecoration(labelText: 'Bathrooms'), keyboardType: TextInputType.number)),
                  ],
                ),
              ],
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Location'),
            content: Column(
              children: const [
                TextField(decoration: InputDecoration(labelText: 'Search Address (Google Places)')),
                SizedBox(height: 16),
                TextField(decoration: InputDecoration(labelText: 'City')),
                SizedBox(height: 16),
                TextField(decoration: InputDecoration(labelText: 'Neighborhood/Area')),
              ],
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Pricing'),
            content: Column(
              children: const [
                TextField(decoration: InputDecoration(labelText: 'Price per month (ETB)'), keyboardType: TextInputType.number),
                SizedBox(height: 16),
                TextField(decoration: InputDecoration(labelText: 'Security Deposit (Optional)'), keyboardType: TextInputType.number),
              ],
            ),
            isActive: _currentStep >= 2,
          ),
          Step(
            title: const Text('Description & Amenities'),
            content: Column(
              children: const [
                TextField(decoration: InputDecoration(labelText: 'Detailed Description'), maxLines: 4),
                SizedBox(height: 16),
                TextField(decoration: InputDecoration(labelText: 'Amenities (Comma separated)')),
              ],
            ),
            isActive: _currentStep >= 3,
          ),
          Step(
            title: const Text('Photos'),
            content: Column(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined, size: 40, color: AppColors.textSecondary),
                      SizedBox(height: 8),
                      Text('Tap to upload images (Max 10)'),
                    ],
                  ),
                ),
              ],
            ),
            isActive: _currentStep >= 4,
          ),
          Step(
            title: const Text('House Rules'),
            content: Column(
              children: const [
                TextField(decoration: InputDecoration(labelText: 'Check-in Time (Optional)')),
                SizedBox(height: 16),
                TextField(decoration: InputDecoration(labelText: 'Pet Policy (e.g. No Pets)')),
              ],
            ),
            isActive: _currentStep >= 5,
          ),
        ],
      ),
    );
  }
}
