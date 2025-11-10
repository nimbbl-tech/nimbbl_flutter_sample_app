import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/constants/app_strings.dart';
import '../../domain/models/payment_result_data.dart';

/// Widget for displaying payment result information
class PaymentResultWidget extends StatelessWidget {
  final PaymentResultData parsedData;

  const PaymentResultWidget({
    super.key,
    required this.parsedData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
      ],
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
