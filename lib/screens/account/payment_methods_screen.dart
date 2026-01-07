import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme.dart';
import '../../cubits/user/user_cubit.dart';
import '../../models/payment_method.dart';
import 'add_payment_method_screen.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().loadUserData();
  }

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
          ).then((_) {
            // Reload user data to get updated list (if Add screen didn't already)
            // Ideally AddScreen uses Cubit which reloads upon success.
            // But doing it here ensures sync if we come back.
            context.read<UserCubit>().loadUserData();
          });
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load payment methods: ${state.message}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => context.read<UserCubit>().loadUserData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is UserLoaded) {
            final rawMethods = state.creditCards as List;
            final paymentMethods = rawMethods
                .map((method) {
                  if (method is PaymentMethod) return method;
                  if (method is Map) {
                    return PaymentMethod.fromJson(
                      Map<String, dynamic>.from(method),
                    );
                  }
                  return null;
                })
                .whereType<PaymentMethod>()
                .toList();
            return paymentMethods.isEmpty
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
                    itemCount: paymentMethods.length,
                    itemBuilder: (context, index) {
                      final method = paymentMethods[index];
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
                          onTap: () => _showCardDetails(context, method),
                        ),
                      );
                    },
                  );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _showCardDetails(
    BuildContext context,
    PaymentMethod method,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Card Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Card Type', method.cardType),
              _detailRow(
                'Number',
                method.cardNumber.isNotEmpty
                    ? method.cardNumber
                    : '•••• ${method.lastFourDigits}',
              ),
              _detailRow('Expiry', method.expiryDate),
              _detailRow('Holder', method.holderName),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () async {
                final confirmed = await _confirmDelete(dialogContext);
                if (!confirmed) return;
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                try {
                  final message = await context
                      .read<UserCubit>()
                      .deleteCreditCard(method.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete card: $e')),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete card?'),
          content: const Text(
            'Are you sure you want to delete this credit card?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}
