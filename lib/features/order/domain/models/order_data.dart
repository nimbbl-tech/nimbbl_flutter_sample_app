/// Order data model for payment processing
class OrderData {
  final String amount;
  final String currency;
  final bool orderLineItems;
  final String headerCustomisation;
  final String paymentCustomisation;
  final String subPaymentCustomisation;
  final bool userDetails;
  final String firstName;
  final String mobileNumber;
  final String email;

  const OrderData({
    required this.amount,
    required this.currency,
    required this.orderLineItems,
    required this.headerCustomisation,
    required this.paymentCustomisation,
    required this.subPaymentCustomisation,
    required this.userDetails,
    required this.firstName,
    required this.mobileNumber,
    required this.email,
  });

  /// Create a copy of this OrderData with the given fields replaced with new values
  OrderData copyWith({
    String? amount,
    String? currency,
    bool? orderLineItems,
    String? headerCustomisation,
    String? paymentCustomisation,
    String? subPaymentCustomisation,
    bool? userDetails,
    String? firstName,
    String? mobileNumber,
    String? email,
  }) {
    return OrderData(
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      orderLineItems: orderLineItems ?? this.orderLineItems,
      headerCustomisation: headerCustomisation ?? this.headerCustomisation,
      paymentCustomisation: paymentCustomisation ?? this.paymentCustomisation,
      subPaymentCustomisation: subPaymentCustomisation ?? this.subPaymentCustomisation,
      userDetails: userDetails ?? this.userDetails,
      firstName: firstName ?? this.firstName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
    );
  }

  /// Convert OrderData to JSON
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency,
      'orderLineItems': orderLineItems,
      'headerCustomisation': headerCustomisation,
      'paymentCustomisation': paymentCustomisation,
      'subPaymentCustomisation': subPaymentCustomisation,
      'userDetails': userDetails,
      'firstName': firstName,
      'mobileNumber': mobileNumber,
      'email': email,
    };
  }

  /// Create OrderData from JSON
  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      amount: json['amount'] ?? '',
      currency: json['currency'] ?? '',
      orderLineItems: json['orderLineItems'] ?? false,
      headerCustomisation: json['headerCustomisation'] ?? '',
      paymentCustomisation: json['paymentCustomisation'] ?? '',
      subPaymentCustomisation: json['subPaymentCustomisation'] ?? '',
      userDetails: json['userDetails'] ?? false,
      firstName: json['firstName'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      email: json['email'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderData &&
        other.amount == amount &&
        other.currency == currency &&
        other.orderLineItems == orderLineItems &&
        other.headerCustomisation == headerCustomisation &&
        other.paymentCustomisation == paymentCustomisation &&
        other.subPaymentCustomisation == subPaymentCustomisation &&
        other.userDetails == userDetails &&
        other.firstName == firstName &&
        other.mobileNumber == mobileNumber &&
        other.email == email;
  }

  @override
  int get hashCode {
    return Object.hash(
      amount,
      currency,
      orderLineItems,
      headerCustomisation,
      paymentCustomisation,
      subPaymentCustomisation,
      userDetails,
      firstName,
      mobileNumber,
      email,
    );
  }

  @override
  String toString() {
    return 'OrderData(amount: $amount, currency: $currency, orderLineItems: $orderLineItems, headerCustomisation: $headerCustomisation, paymentCustomisation: $paymentCustomisation, subPaymentCustomisation: $subPaymentCustomisation, userDetails: $userDetails, firstName: $firstName, mobileNumber: $mobileNumber, email: $email)';
  }
}
