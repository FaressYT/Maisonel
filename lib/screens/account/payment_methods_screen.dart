import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme.dart';
import '../../cubits/user/user_cubit.dart';
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
            final paymentMethods = state.creditCards;
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
}
