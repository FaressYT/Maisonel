class PaymentMethod {
  final String id;
  final String cardType; // 'Visa', 'MasterCard', etc.
  final String cardNumber;
  final String lastFourDigits;
  final String expiryDate; // MM/YY
  final String holderName;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.cardType,
    required this.cardNumber,
    required this.lastFourDigits,
    required this.expiryDate,
    required this.holderName,
    this.isDefault = false,
  });

  String get cardLogo {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return 'assets/images/visa.png'; // Placeholder path
      case 'mastercard':
        return 'assets/images/mastercard.png'; // Placeholder path
      default:
        return 'assets/images/credit_card.png'; // Placeholder path
    }
  }

  // Mock data generator
  static List<PaymentMethod> getMockPaymentMethods() {
    return [
      PaymentMethod(
        id: 'pm1',
        cardType: 'Visa',
        cardNumber: '4242424242424242',
        lastFourDigits: '4242',
        expiryDate: '12/25',
        holderName: 'John Doe',
        isDefault: true,
      ),
      PaymentMethod(
        id: 'pm2',
        cardType: 'MasterCard',
        cardNumber: '5555555555554444',
        lastFourDigits: '8888',
        expiryDate: '09/24',
        holderName: 'John Doe',
        isDefault: false,
      ),
    ];
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    final rawNumber = json['card_number']?.toString() ?? '';
    final lastFour = rawNumber.length >= 4
        ? rawNumber.substring(rawNumber.length - 4)
        : (json['last_four_digits']?.toString() ?? '****');
    final expiryRaw =
        json['expiration_date']?.toString() ?? json['expiry_date']?.toString();
    final expiryDate = _formatExpiry(expiryRaw);

    return PaymentMethod(
      id: json['id']?.toString() ?? '',
      cardType:
          json['card_type']?.toString() ?? json['type']?.toString() ?? 'Unknown',
      cardNumber: rawNumber,
      lastFourDigits: lastFour,
      expiryDate: expiryDate,
      holderName:
          json['card_holder_name']?.toString() ??
          json['holder_name']?.toString() ??
          '',
      isDefault: json['is_default'] == true || json['is_default'] == 1,
    );
  }

  static String _formatExpiry(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    if (raw.contains('/')) return raw;
    final parts = raw.split('-');
    if (parts.length >= 2) {
      final year = parts[0];
      final month = parts[1];
      if (year.length == 4 && month.length == 2) {
        return '$month/${year.substring(2)}';
      }
    }
    return raw;
  }
}
