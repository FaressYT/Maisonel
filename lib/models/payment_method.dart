class PaymentMethod {
  final String id;
  final String cardType; // 'Visa', 'MasterCard', etc.
  final String lastFourDigits;
  final String expiryDate; // MM/YY
  final String holderName;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.cardType,
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
        lastFourDigits: '4242',
        expiryDate: '12/25',
        holderName: 'John Doe',
        isDefault: true,
      ),
      PaymentMethod(
        id: 'pm2',
        cardType: 'MasterCard',
        lastFourDigits: '8888',
        expiryDate: '09/24',
        holderName: 'John Doe',
        isDefault: false,
      ),
    ];
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id']?.toString() ?? '',
      cardType: json['type'] ?? 'Unknown',
      lastFourDigits: json['last_four_digits']?.toString() ?? '****',
      expiryDate: json['expiry_date'] ?? '',
      holderName: json['holder_name'] ?? '',
      isDefault: json['is_default'] == true || json['is_default'] == 1,
    );
  }
}
