import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/payment_method.dart';
import 'add_payment_method_screen.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<PaymentMethod> _paymentMethods =
      PaymentMethod.getMockPaymentMethods();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Methods')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPaymentMethodScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _paymentMethods.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.credit_card_off_outlined,
                    size: 64,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No payment methods added yet',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _paymentMethods.length,
              itemBuilder: (context, index) {
                final method = _paymentMethods[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.credit_card, size: 32),
                    title: Text(
                      '${method.cardType} •••• ${method.lastFourDigits}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Expires ${method.expiryDate}'),
                    trailing: method.isDefault
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Default',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              // Delete logic
                            },
                          ),
                  ),
                );
              },
            ),
    );
  }
}
