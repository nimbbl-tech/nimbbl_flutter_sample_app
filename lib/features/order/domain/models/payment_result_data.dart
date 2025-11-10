import 'dart:convert';
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

  factory PaymentResultData.fromJson(Map<String, dynamic> json) {
    // Parse the nested order data if it exists (matching React Native implementation)
    Map<String, dynamic>? orderData;
    if (json['order'] != null) {
      if (json['order'] is Map<String, dynamic>) {
        // iOS sends order as an object
        orderData = json['order'] as Map<String, dynamic>;
      } else if (json['order'] is String) {
        // Android sends order as a JSON string - parse it
        try {
          orderData = Map<String, dynamic>.from(jsonDecode(json['order'] as String));
        } catch (parseError) {
          orderData = null;
        }
      }
    }

    return PaymentResultData(
      orderId: json['order_id'] ?? json['nimbbl_order_id'] ?? 'N/A',
      transactionId: json['transaction_id'] ?? json['nimbbl_transaction_id'],
      status: _parseStatus(json['status']),
      message: json['message'] ?? 'Payment processed',
      amount: _parseAmount(json['amount'] ?? orderData?['total_amount'] ?? orderData?['grand_total']),
      currency: json['currency'] ?? orderData?['currency'] ?? AppConstants.defaultCurrency,
      invoiceId: json['invoice_id'] ?? orderData?['invoice_id'],
      orderDate: json['order_date'] ?? orderData?['order_date'],
      reason: json['reason'] ?? orderData?['cancellation_reason'],
      cancellationReason: json['cancellation_reason'] ?? orderData?['cancellation_reason'],
      attempts: json['attempts'] ?? orderData?['attempts'],
      referrerPlatform: json['referrer_platform'] ?? orderData?['referrer_platform'],
      referrerPlatformVersion: json['referrer_platform_version'] ?? orderData?['referrer_platform_version'],
      deviceName: json['device_name'] ?? orderData?['device']?['device_name'],
      deviceOsName: json['device_os_name'] ?? orderData?['device']?['os_name'],
      deviceIpAddress: json['device_ip_address'] ?? orderData?['device']?['ip_address'],
      shippingCity: json['shipping_city'] ?? orderData?['shipping_address']?['city'],
      shippingState: json['shipping_state'] ?? orderData?['shipping_address']?['state'],
      shippingCountry: json['shipping_country'] ?? orderData?['shipping_address']?['country'],
      shippingPincode: json['shipping_pincode'] ?? orderData?['shipping_address']?['pincode'],
      isEncrypted: json['encrypted_response'] != null,
      encryptedResponse: json['encrypted_response'],
    );
  }

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

  static PaymentStatus _parseStatus(dynamic status) {
    if (status == 'success' || status == 'completed') {
      return PaymentStatus.success;
    } else if (status == 'cancelled') {
      return PaymentStatus.cancelled;
    } else {
      return PaymentStatus.failed;
    }
  }

  static double? _parseAmount(dynamic amount) {
    if (amount == null) return null;
    if (amount is double) return amount;
    if (amount is int) return amount.toDouble();
    if (amount is String) return double.tryParse(amount);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'transactionId': transactionId,
      'status': status.name,
      'message': message,
      'amount': amount,
      'currency': currency,
      'invoiceId': invoiceId,
      'orderDate': orderDate,
      'reason': reason,
      'cancellationReason': cancellationReason,
      'attempts': attempts,
      'referrerPlatform': referrerPlatform,
      'referrerPlatformVersion': referrerPlatformVersion,
      'deviceName': deviceName,
      'deviceOsName': deviceOsName,
      'deviceIpAddress': deviceIpAddress,
      'shippingCity': shippingCity,
      'shippingState': shippingState,
      'shippingCountry': shippingCountry,
      'shippingPincode': shippingPincode,
      'isEncrypted': isEncrypted,
      'encryptedResponse': encryptedResponse,
    };
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
