import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class AddPaymentScreen extends StatefulWidget {
  const AddPaymentScreen({super.key});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isCard = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Payment Method', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Credit Card'),
                    selected: _isCard,
                    onSelected: (val) => setState(() => _isCard = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Mobile Money'),
                    selected: !_isCard,
                    onSelected: (val) => setState(() => _isCard = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (_isCard) ...[
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  prefixIcon: Icon(Icons.credit_card),
                  hintText: '0000 0000 0000 0000',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(labelText: 'Expiry Date', hintText: 'MM/YY'),
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(labelText: 'CVV', hintText: '123'),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(labelText: 'Cardholder Name'),
                textCapitalization: TextCapitalization.words,
              ),
            ] else ...[
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_android),
                  hintText: '+251 700 000 000',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(labelText: 'Account Name'),
                textCapitalization: TextCapitalization.words,
              ),
            ],
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Show success message first
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment method added successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
                // Then return
                context.pop();
              },
              child: const Text('Save Payment Method'),
            ),
          ],
        ),
      ),
    );
  }
}
