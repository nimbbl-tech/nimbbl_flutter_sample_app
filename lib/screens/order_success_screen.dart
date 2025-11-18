import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/payment_result_data.dart';
import '../shared/constants/app_strings.dart';

/// Order success screen for displaying payment results
class OrderSuccessScreen extends StatefulWidget {
  final Map<String, dynamic>? paymentData;
  final String? orderID; // Legacy parameter
  final String? status; // Legacy parameter
  final String? orderId; // Legacy parameter

  const OrderSuccessScreen({
    super.key,
    this.paymentData,
    this.orderID,
    this.status,
    this.orderId,
  });

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  late PaymentResultData parsedData;

  @override
  void initState() {
    super.initState();
    _parsePaymentData();
  }

  void _parsePaymentData() {
    try {
      if (widget.paymentData != null) {
        // Handle raw checkout result from PaymentService
        final checkoutResult = widget.paymentData!;
        
        // Determine payment status from checkout result
        PaymentStatus status;
        String message = '';
        
        // Check if this is a PaymentService error format
        if (checkoutResult.containsKey('success') && checkoutResult['success'] == false) {
          status = PaymentStatus.failed;
          message = checkoutResult['errorMessage'] ?? 'Payment failed';
        } else if (checkoutResult['status'] == 'success') {
          status = PaymentStatus.success;
          message = 'Payment completed successfully';
        } else if (checkoutResult['status'] == 'failed') {
          status = PaymentStatus.failed;
          message = checkoutResult['message'] ?? 'Payment failed';
        } else if (checkoutResult['status'] == 'cancelled') {
          status = PaymentStatus.cancelled;
          message = 'Payment cancelled by user';
        } else {
          status = PaymentStatus.failed;
          message = checkoutResult['message'] ?? 'Unknown payment error';
        }
        
        // Extract nested data from checkout result
        final orderData = _convertToMap(checkoutResult['order']);

        // Create PaymentResultData from checkout result with nested data extraction
        parsedData = PaymentResultData(
          orderId: checkoutResult['order_id'] ?? checkoutResult['orderId'] ?? orderData?['order_id'] ?? '',
          transactionId: checkoutResult['transaction_id'] ?? checkoutResult['transactionId'] ?? checkoutResult['nimbbl_transaction_id'],
          status: status,
          message: message,
          amount: _parseAmount(checkoutResult['amount'] ?? orderData?['total_amount'] ?? orderData?['grand_total']),
          currency: checkoutResult['currency'] ?? orderData?['currency'] ?? AppConstants.defaultCurrency,
          invoiceId: checkoutResult['invoice_id'] ?? checkoutResult['invoiceId'] ?? orderData?['invoice_id'],
          orderDate: checkoutResult['order_date'] ?? checkoutResult['orderDate'] ?? orderData?['order_date'],
          reason: checkoutResult['reason'],
          cancellationReason: checkoutResult['cancellation_reason'] ?? checkoutResult['cancellationReason'] ?? orderData?['cancellation_reason'],
          deviceName: checkoutResult['device_name'] ?? checkoutResult['deviceName'] ?? orderData?['device']?['device_name'],
          deviceOsName: checkoutResult['device_os_name'] ?? checkoutResult['deviceOsName'] ?? orderData?['device']?['os_name'],
          deviceIpAddress: checkoutResult['device_ip_address'] ?? checkoutResult['deviceIpAddress'] ?? orderData?['device']?['ip_address'],
          shippingCity: checkoutResult['shipping_city'] ?? checkoutResult['shippingCity'] ?? orderData?['shipping_address']?['city'],
          shippingState: checkoutResult['shipping_state'] ?? checkoutResult['shippingState'] ?? orderData?['shipping_address']?['state'],
          shippingCountry: checkoutResult['shipping_country'] ?? checkoutResult['shippingCountry'] ?? orderData?['shipping_address']?['country'],
          shippingPincode: checkoutResult['shipping_pincode'] ?? checkoutResult['shippingPincode'] ?? orderData?['shipping_address']?['pincode'],
          isEncrypted: false,
          encryptedResponse: null,
        );
      } else {
        // Fallback to legacy parameters
        parsedData = PaymentResultData(
          orderId: widget.orderID ?? widget.orderId ?? 'N/A',
          status: _parseLegacyStatus(widget.status),
          message: 'Payment processed',
          amount: 0,
          currency: AppConstants.defaultCurrency,
        );
      }
    } catch (error) {
      debugPrint('PaymentResultScreen: Error parsing payment data: $error');
      parsedData = PaymentResultData.defaultData();
    }
  }

  PaymentStatus _parseLegacyStatus(String? status) {
    if (status == 'success' || status == 'completed') {
      return PaymentStatus.success;
    } else if (status == 'cancelled') {
      return PaymentStatus.cancelled;
    } else {
      return PaymentStatus.failed;
    }
  }

  double? _parseAmount(dynamic amount) {
    if (amount == null) return null;
    if (amount is double) return amount;
    if (amount is int) return amount.toDouble();
    if (amount is String) {
      return double.tryParse(amount);
    }
    return null;
  }

  Map<String, dynamic>? _convertToMap(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      // Convert Map<Object?, Object?> to Map<String, dynamic>
      final Map<String, dynamic> result = {};
      data.forEach((key, value) {
        if (key is String) {
          result[key] = value;
        }
      });
      return result;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  children: [
                    // Status Card
                    _buildStatusCard(),
                    const SizedBox(height: AppConstants.defaultPadding),

                    // Order Details Card
                    if (!parsedData.isEncrypted) ...[
                      _buildOrderDetailsCard(),
                      const SizedBox(height: AppConstants.defaultPadding),
                    ],

                    // Additional Details Card
                    if (!parsedData.isEncrypted && _buildAdditionalDetails().isNotEmpty) ...[
                      _buildAdditionalDetailsCard(),
                      const SizedBox(height: AppConstants.defaultPadding),
                    ],

                    // Encrypted Response Card
                    if (parsedData.isEncrypted) ...[
                      _buildEncryptedResponseCard(),
                      const SizedBox(height: AppConstants.defaultPadding),
                    ],

                    // Action Button
                    _buildActionButton(),
                  ],
                ),
              ),
            ),
            
            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          
          // Title
          const Expanded(
            child: Text(
              AppStrings.orderSuccess,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      color: AppTheme.primaryColor,
      child: Text(
        '© ${DateTime.now().year} nimbbl by bigital technologies pvt ltd',
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 12,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            parsedData.status.icon,
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            _getStatusTitle(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _getStatusColor(),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            _getStatusMessage(),
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.orderDetails,
            style: AppTheme.headingSmall,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildDetailRow('Order ID', _cleanValue(parsedData.orderId)),
          _buildDetailRow('Status', parsedData.status.displayName, valueColor: _getStatusColor()),
          _buildDetailRow('Amount', '${_cleanValue(parsedData.currency)} ${_cleanValue(parsedData.amount)}'),
          _buildDetailRow('Invoice ID', _cleanValue(parsedData.invoiceId)),
          _buildDetailRow('Transaction ID', _cleanValue(parsedData.transactionId)),
          _buildDetailRow('Order Date', _formatOrderDate(parsedData.orderDate)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: valueColor ?? AppTheme.textPrimaryColor,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.additionalDetails,
            style: AppTheme.headingSmall,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            _buildAdditionalDetails(),
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEncryptedResponseCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.encryptedResponse,
            style: AppTheme.headingSmall,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          const Text(
            'This response is encrypted and needs to be decrypted on your server.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.smallPadding),
            decoration: BoxDecoration(
              color: AppTheme.inputBackgroundColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${parsedData.encryptedResponse?.substring(0, parsedData.encryptedResponse!.length > 100 ? 100 : parsedData.encryptedResponse!.length)}...',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textHintColor,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleBackToHome,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          AppStrings.backToHome,
          style: AppTheme.buttonText,
        ),
      ),
    );
  }

  void _handleBackToHome() {
    Navigator.of(context).pop();
  }

  // Helper methods
  Color _getStatusColor() {
    switch (parsedData.status) {
      case PaymentStatus.success:
        return AppTheme.successColor;
      case PaymentStatus.failed:
        return AppTheme.errorColor;
      case PaymentStatus.cancelled:
        return AppTheme.warningColor;
    }
  }

  String _getStatusTitle() {
    if (parsedData.isEncrypted) {
      return 'Encrypted Response';
    }
    return parsedData.status.title;
  }

  String _getStatusMessage() {
    if (parsedData.isEncrypted) {
      return 'Encrypted response received. Please handle decryption on your server.';
    }
    return parsedData.message ?? parsedData.status.defaultMessage;
  }

  String _formatOrderDate(String? orderDate) {
    if (orderDate == null || orderDate.isEmpty || orderDate == 'null') {
      return '';
    }
    try {
      return orderDate.substring(0, orderDate.length > 19 ? 19 : orderDate.length);
    } catch (error) {
      return orderDate;
    }
  }

  String _cleanValue(dynamic value) {
    if (value == null || value == 'null' || value == '') {
      return '';
    }
    return value.toString();
  }

  String _buildAdditionalDetails() {
    if (parsedData.isEncrypted) return '';

    final details = <String>[];

    final reason = _cleanValue(parsedData.reason);
    if (reason.isNotEmpty) {
      details.add('Reason: $reason');
    }

    final cancellationReason = _cleanValue(parsedData.cancellationReason);
    if (cancellationReason.isNotEmpty) {
      details.add('Cancellation Reason: $cancellationReason');
    }

    final attempts = _cleanValue(parsedData.attempts);
    if (attempts.isNotEmpty) {
      details.add('Attempts: $attempts');
    }

    final platform = _cleanValue(parsedData.referrerPlatform);
    final platformVersion = _cleanValue(parsedData.referrerPlatformVersion);
    if (platform.isNotEmpty) {
      details.add('Platform: $platform${platformVersion.isNotEmpty ? ' $platformVersion' : ''}');
    }

    final deviceName = _cleanValue(parsedData.deviceName);
    final deviceOs = _cleanValue(parsedData.deviceOsName);
    if (deviceName.isNotEmpty) {
      details.add('Device: $deviceName${deviceOs.isNotEmpty ? ' ($deviceOs)' : ''}');
    }

    final ipAddress = _cleanValue(parsedData.deviceIpAddress);
    if (ipAddress.isNotEmpty) {
      details.add('IP Address: $ipAddress');
    }

    final shippingCity = _cleanValue(parsedData.shippingCity);
    final shippingState = _cleanValue(parsedData.shippingState);
    final shippingCountry = _cleanValue(parsedData.shippingCountry);
    final shippingPincode = _cleanValue(parsedData.shippingPincode);
    if (shippingCity.isNotEmpty) {
      final addressParts = [
        shippingCity,
        if (shippingState.isNotEmpty) shippingState,
        if (shippingCountry.isNotEmpty) shippingCountry,
        if (shippingPincode.isNotEmpty) shippingPincode,
      ];
      details.add('Shipping Address: ${addressParts.join(', ')}');
    }

    return details.join('\n\n');
  }
}
