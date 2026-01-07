import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme.dart';
import '../../cubits/user/user_cubit.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _holderNameController = TextEditingController();
  bool _isLoading = false;
  String _cardType = 'Unknown';

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(_handleCardNumberChange);
  }

  @override
  void dispose() {
    _cardNumberController.removeListener(_handleCardNumberChange);
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _holderNameController.dispose();
    super.dispose();
  }

  void _handleCardNumberChange() {
    final nextType = _detectCardType(_cardNumberController.text);
    if (nextType != _cardType) {
      setState(() {
        _cardType = nextType;
      });
    }
  }

  void _addCard() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Use Cubit to add card
      await context.read<UserCubit>().addCreditCard(
        cardNumber: _cardNumberController.text,
        expirationDate: _expiryController.text,
        cvv: _cvvController.text,
        holderName: _holderNameController.text,
        cardType: _cardType,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      final state = context.read<UserCubit>().state;
      if (state is UserError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add card: ${state.message}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment method added successfully!')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Payment Method')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                label: 'Card Number',
                controller: _cardNumberController,
                prefixIcon: Icons.credit_card,
                suffix: _buildCardTypeSuffix(context),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final raw = value ?? '';
                  if (raw.isEmpty) {
                    return 'Please enter card number';
                  }
                  final digits = _digitsOnly(raw);
                  final allowedLengths = _allowedLengthsForType(_cardType);
                  final isLengthOk = allowedLengths.contains(digits.length) ||
                      (_cardType == 'Unknown' &&
                          digits.length >= 13 &&
                          digits.length <= 16);
                  if (!isLengthOk) {
                    return 'Invalid card number length';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Expiry Date (MM/YY)',
                      controller: _expiryController,
                      prefixIcon: Icons.calendar_today,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (!value.contains('/')) {
                          return 'Invalid format';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: CustomTextField(
                      label: 'CVV',
                      controller: _cvvController,
                      prefixIcon: Icons.lock_outline,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (value.length < 3) {
                          return 'Invalid CVV';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                label: 'Cardholder Name',
                controller: _holderNameController,
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cardholder name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              CustomButton(
                text: 'Add Card',
                onPressed: _addCard,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildCardTypeSuffix(BuildContext context) {
    if (_cardType == 'Unknown') return null;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Text(
        _cardType,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  String _digitsOnly(String value) {
    final buffer = StringBuffer();
    for (final codeUnit in value.codeUnits) {
      if (codeUnit >= 48 && codeUnit <= 57) {
        buffer.writeCharCode(codeUnit);
      }
    }
    return buffer.toString();
  }

  List<int> _allowedLengthsForType(String cardType) {
    switch (cardType) {
      case 'American Express':
        return [15];
      case 'Diners Club':
      case 'Carte Blanche':
        return [14];
      case 'Discover':
        return [16];
      case 'EnRoute':
        return [15];
      case 'JCB':
        return [15, 16];
      case 'Master Card':
        return [16];
      case 'Visa':
        return [13, 16];
      default:
        return [];
    }
  }

  String _detectCardType(String input) {
    final digits = _digitsOnly(input);
    if (digits.isEmpty) return 'Unknown';

    if (_startsWithAny(digits, const ['2014', '2149'])) return 'EnRoute';
    if (_startsWithAny(digits, const ['2131', '1800'])) return 'JCB';
    if (_startsWithAny(digits, const ['6011'])) return 'Discover';
    if (_startsWithAny(digits, const ['34', '37'])) return 'American Express';
    if (_startsWithRange(digits, 300, 305) || _startsWithAny(digits, const ['36'])) {
      return 'Diners Club';
    }
    if (_startsWithAny(digits, const ['38'])) return 'Carte Blanche';
    if (_startsWithRange(digits, 51, 55)) return 'Master Card';
    if (_startsWithAny(digits, const ['4'])) return 'Visa';
    if (_startsWithAny(digits, const ['3'])) return 'JCB';

    return 'Unknown';
  }

  bool _startsWithAny(String digits, List<String> prefixes) {
    for (final prefix in prefixes) {
      if (digits.startsWith(prefix)) return true;
    }
    return false;
  }

  bool _startsWithRange(String digits, int start, int end) {
    if (digits.isEmpty) return false;
    final prefixLength = start.toString().length;
    if (digits.length < prefixLength) return false;
    final prefix = int.tryParse(digits.substring(0, prefixLength));
    if (prefix == null) return false;
    return prefix >= start && prefix <= end;
  }
}
