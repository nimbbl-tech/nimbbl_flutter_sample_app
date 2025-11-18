import '../../../../core/constants/app_constants.dart';

/// Payment result data model
class PaymentResultData {
  final String orderId;
  final String? transactionId;
  final PaymentStatus status;
  final String? message;
  final double? amount;
  final String? currency;
  final String? invoiceId;
  final String? orderDate;
  final String? reason;
  final String? cancellationReason;
  final int? attempts;
  final String? referrerPlatform;
  final String? referrerPlatformVersion;
  final String? deviceName;
  final String? deviceOsName;
  final String? deviceIpAddress;
  final String? shippingCity;
  final String? shippingState;
  final String? shippingCountry;
  final String? shippingPincode;
  final bool isEncrypted;
  final String? encryptedResponse;

  const PaymentResultData({
    required this.orderId,
    this.transactionId,
    required this.status,
    this.message,
    this.amount,
    this.currency,
    this.invoiceId,
    this.orderDate,
    this.reason,
    this.cancellationReason,
    this.attempts,
    this.referrerPlatform,
    this.referrerPlatformVersion,
    this.deviceName,
    this.deviceOsName,
    this.deviceIpAddress,
    this.shippingCity,
    this.shippingState,
    this.shippingCountry,
    this.shippingPincode,
    this.isEncrypted = false,
    this.encryptedResponse,
  });

  factory PaymentResultData.fromEncryptedResponse(Map<String, dynamic> json) {
    return PaymentResultData(
      orderId: json['order_id'] ?? json['nimbbl_order_id'] ?? 'N/A',
      status: PaymentStatus.success,
      message: 'Payment successful. Encrypted response received.',
      isEncrypted: true,
      encryptedResponse: json['encrypted_response'],
    );
  }

  factory PaymentResultData.defaultData() {
    return const PaymentResultData(
      orderId: 'N/A',
      status: PaymentStatus.failed,
      message: 'No payment data received',
      amount: 0,
      currency: AppConstants.defaultCurrency,
      isEncrypted: false,
    );
  }
}

/// Payment status enumeration
enum PaymentStatus {
  success,
  failed,
  cancelled,
}

/// Payment status extension for display properties
extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.success:
        return 'SUCCESS';
      case PaymentStatus.failed:
        return 'FAILED';
      case PaymentStatus.cancelled:
        return 'CANCELLED';
    }
  }

  String get icon {
    switch (this) {
      case PaymentStatus.success:
        return '✅';
      case PaymentStatus.failed:
        return '❌';
      case PaymentStatus.cancelled:
        return '⚠️';
    }
  }

  String get title {
    switch (this) {
      case PaymentStatus.success:
        return 'Payment Successful';
      case PaymentStatus.failed:
        return 'Payment Failed';
      case PaymentStatus.cancelled:
        return 'Payment Cancelled';
    }
  }

  String get defaultMessage {
    switch (this) {
      case PaymentStatus.success:
        return 'Your payment has been processed successfully';
      case PaymentStatus.failed:
        return 'Your payment could not be processed';
      case PaymentStatus.cancelled:
        return 'Payment was cancelled';
    }
  }
}
