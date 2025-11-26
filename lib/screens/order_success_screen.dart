import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_constants.dart';
import '../models/payment_result_data.dart';
import '../shared/widgets/responsive_layout.dart';
import '../shared/utils/web_navigation_helper.dart';

/// Order success screen for displaying payment results
/// Matches the design from nimbbl_sonic_shop React project
class OrderSuccessScreen extends StatefulWidget {
  final Map<String, dynamic>? paymentData;
  final String? orderID; // Legacy parameter
  final String? status; // Legacy parameter
  final String? orderId; // Legacy parameter

  const OrderSuccessScreen({
    Key? key,
    this.paymentData,
    this.orderID,
    this.status,
    this.orderId,
  }) : super(key: key);

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  late PaymentResultData parsedData;
  Map<String, dynamic>? transactionData;
  Map<String, dynamic>? userData;
  Map<String, dynamic>? payloadData; // Store full payload for data extraction
  int counter = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _parsePaymentData();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    // Matching React behavior: countdown from 5 to 0, stops at 0
    // React: useEffect with counter dependency, sets interval only when counter > 0
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        if (counter > 0) {
          counter--;
        } else {
          // Stop the timer when counter reaches 0
          timer.cancel();
          // Auto-redirect when counter reaches 0 (matching React: setTimeout redirect after 5 seconds)
          _navigateToHome();
        }
      });
    });
  }

  void _navigateToHome() {
    if (kIsWeb) {
      // On web, navigate to root URL (matching React: location.href = window.location.origin)
      navigateToRoot();
    } else {
      // On mobile, clear navigation stack and go to home
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const ResponsiveLayout()),
        (route) => false,
      );
    }
  }

  void _parsePaymentData() {
    try {
      if (widget.paymentData != null) {
        // Handle raw checkout result from PaymentService
        final checkoutResult = widget.paymentData!;
        
        // Extract payload if present (web SDK response structure)
        Map<String, dynamic>? payload;
        if (checkoutResult['payload'] != null && checkoutResult['payload'] is Map) {
          payload = Map<String, dynamic>.from(checkoutResult['payload'] as Map);
        }
        
        // Store payload data for later use
        payloadData = payload;
        
        // Use payload data if available, otherwise use root level data
        final data = payload ?? checkoutResult;
        
        // Extract transaction and user data from payload
        // Matching React: const { transaction_id, transaction, order, user, reason } = payload ?? {};
        transactionData = _convertToMap(data['transaction']);
        userData = _convertToMap(data['user']);
        
        // Determine payment status from checkout result
        PaymentStatus status;
        String message = '';
        
        // Check if this is a PaymentService error format
        if (checkoutResult.containsKey('success') && checkoutResult['success'] == false) {
          status = PaymentStatus.failed;
          message = checkoutResult['errorMessage'] ?? 'Payment failed';
        } else if (data['status'] == 'success') {
          status = PaymentStatus.success;
          message = data['message'] ?? 'Payment completed successfully';
        } else if (data['status'] == 'failed') {
          status = PaymentStatus.failed;
          message = data['message'] ?? data['reason'] ?? 'Payment failed';
        } else if (data['status'] == 'cancelled') {
          status = PaymentStatus.cancelled;
          message = 'Payment cancelled by user';
        } else {
          status = PaymentStatus.failed;
          message = data['message'] ?? data['reason'] ?? 'Unknown payment error';
        }
        
        // Extract nested data from order object
        final orderData = _convertToMap(data['order']);

        // Create PaymentResultData from checkout result with nested data extraction
        parsedData = PaymentResultData(
          orderId: data['nimbbl_order_id'] ?? 
                   data['order_id'] ?? 
                   checkoutResult['order_id'] ?? 
                   checkoutResult['orderId'] ?? 
                   orderData?['order_id'] ?? 
                   '',
          transactionId: data['nimbbl_transaction_id'] ?? 
                        data['transaction_id'] ?? 
                        checkoutResult['transaction_id'] ?? 
                        checkoutResult['transactionId'] ?? 
                        orderData?['transaction_id'],
          status: status,
          message: message,
          amount: _parseAmount(data['amount'] ?? orderData?['total_amount'] ?? orderData?['grand_total']),
          currency: data['currency'] ?? orderData?['currency'] ?? AppConstants.defaultCurrency,
          invoiceId: data['invoice_id'] ?? checkoutResult['invoice_id'] ?? checkoutResult['invoiceId'] ?? orderData?['invoice_id'],
          orderDate: data['order_date'] ?? checkoutResult['order_date'] ?? checkoutResult['orderDate'] ?? orderData?['order_date'],
          reason: data['reason'],
          cancellationReason: data['cancellation_reason'] ?? data['cancellationReason'] ?? orderData?['cancellation_reason'],
          deviceName: data['device']?['device_name'] ?? orderData?['device']?['device_name'],
          deviceOsName: data['device']?['os_name'] ?? orderData?['device']?['os_name'],
          deviceIpAddress: data['device']?['ip_address'] ?? orderData?['device']?['ip_address'],
          shippingCity: data['shipping_address']?['city'] ?? orderData?['shipping_address']?['city'],
          shippingState: data['shipping_address']?['state'] ?? orderData?['shipping_address']?['state'],
          shippingCountry: data['shipping_address']?['country'] ?? orderData?['shipping_address']?['country'],
          shippingPincode: data['shipping_address']?['pincode'] ?? orderData?['shipping_address']?['pincode'],
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

  String _formatAmount(double? amount) {
    if (amount == null) return '';
    // Format with 2 decimal places, matching React Intl.NumberFormat('en-IN', { style: 'decimal', minimumFractionDigits: 2 })
    // Indian number format: uses comma for thousands separator
    final formatter = NumberFormat.decimalPattern('en_IN');
    formatter.minimumFractionDigits = 2;
    formatter.maximumFractionDigits = 2;
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = parsedData.status == PaymentStatus.success;
    
    // For web, center the content with max-width constraint
    Widget content = Column(
      children: [
        // Success/Failed Header (matching SuccessFailedResponse component)
        _buildStatusHeader(isSuccess),
        
        // Transaction Details (matching TransactionResponseDetails component)
        Expanded(
          child: SingleChildScrollView(
            child: _buildTransactionDetails(),
          ),
        ),
      ],
    );
    
    // On web, wrap in centered container with max-width
    if (kIsWeb) {
      content = Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 500,
            minWidth: 300,
          ),
          child: content,
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: kIsWeb ? const Color(0xFFECF0FD) : Colors.white,
      body: SafeArea(
        child: content,
      ),
    );
  }

  /// Build status header matching React SuccessFailedResponse component
  Widget _buildStatusHeader(bool isSuccess) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: EdgeInsets.symmetric(horizontal: kIsWeb ? 0 : 16),
      decoration: BoxDecoration(
        color: isSuccess ? const Color(0xFF04550D) : const Color(0xFFFFF0F0),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success/Failed Icon
          SvgPicture.asset(
            isSuccess 
              ? 'assets/images/SuccessIcon.svg'
              : 'assets/images/FailedIcon.svg',
            width: 64,
            height: 64,
            colorFilter: null,
          ),
          const SizedBox(height: 8),
          
          // Status Text
          Text(
            'Payment ${isSuccess ? 'Successful' : 'Failed'}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: isSuccess ? const Color(0xFFBDF2CA) : const Color(0xFFCB4949),
            ),
            textAlign: TextAlign.center,
          ),
          
          // Amount and Currency
          if (parsedData.amount != null && parsedData.currency != null) ...[
            const SizedBox(height: 4),
            Text(
              'for ${parsedData.currency} ${_formatAmount(parsedData.amount)}',
              style: TextStyle(
                fontSize: 18,
                color: isSuccess ? const Color(0xFFBDF2CA) : const Color(0xFFCB4949),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build transaction details matching React TransactionResponseDetails component
  Widget _buildTransactionDetails() {
    return ClipPath(
      clipper: ZigzagClipper(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        margin: EdgeInsets.symmetric(horizontal: kIsWeb ? 0 : 0),
        decoration: const BoxDecoration(
          color: Colors.white, // Matching React: bg-white
        ),
        child: Column(
        children: [
          // Transaction Details Card
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: kIsWeb ? 8 : 8, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFC),
              border: Border.all(color: const Color(0xFFECF0FD), width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  'Transaction Details',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Divider
                const Divider(height: 1, color: Color(0xFFECF0FD)),
                const SizedBox(height: 8),
                
                // Details
                // Extract data matching React: const { transaction_id, transaction, order, user, reason } = payload ?? {};
                // const { payment_mode } = transaction ?? {};
                // const { name } = user ?? {};
                
                // Transaction ID from payload root
                if (payloadData?['transaction_id'] != null || payloadData?['nimbbl_transaction_id'] != null)
                  _buildDetailItem(
                    'Transaction ID',
                    payloadData?['transaction_id'] ?? payloadData?['nimbbl_transaction_id'] ?? '',
                  ),
                
                // Mode of Payment from transaction object
                if (transactionData?['payment_mode'] != null)
                  _buildDetailItem(
                    'Mode of Payment',
                    transactionData!['payment_mode'].toString(),
                  ),
                
                // Cancellation Reason from payload root
                if (payloadData?['reason'] != null && payloadData!['reason'].toString().isNotEmpty)
                  _buildDetailItem(
                    'Cancellation Reason',
                    payloadData!['reason'].toString(),
                  ),
                
                // Name of the Sender from user object
                if (userData?['name'] != null && userData!['name'].toString().isNotEmpty)
                  _buildDetailItem(
                    'Name of the Sender',
                    userData!['name'].toString(),
                  ),
              ],
            ),
          ),
          
          // Go to Sonic Shop Button
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: kIsWeb ? 8 : 8, vertical: 8),
            child: ElevatedButton(
              onPressed: _navigateToHome,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Go to Sonic Shop',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          
          // Countdown Text (matching React: "Redirecting to sonic shop in..{counter}")
          Text(
            'Redirecting to sonic shop in..$counter',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6C7F9A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom clipper for zigzag pattern at the bottom
/// Matches React CSS: clip-path polygon for zigzag-box
/// CSS polygon: 0% 0%, 100% 0%, 100% 95%, 95% 100%, 90% 95%, 85% 100%, ... 0% 95%
class ZigzagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final zigzagHeight = size.height * 0.05; // 5% of height for zigzag depth
    
    // Start from top-left (0% 0%)
    path.moveTo(0, 0);
    
    // Top edge to top-right (100% 0%)
    path.lineTo(size.width, 0);
    
    // Right edge down to zigzag start (100% 95%)
    path.lineTo(size.width, size.height - zigzagHeight);
    
    // Zigzag pattern at bottom (matching CSS polygon exactly)
    // Pattern: 100% 95%, 95% 100%, 90% 95%, 85% 100%, 80% 95%, ... 0% 95%
    // 20 segments total (from 100% to 0% in 5% increments)
    final segments = 20;
    final segmentWidth = size.width / segments;
    
    for (int i = 0; i <= segments; i++) {
      final x = size.width - (i * segmentWidth);
      if (i % 2 == 0) {
        // Even indices: at 95% height (valley)
        path.lineTo(x, size.height - zigzagHeight);
      } else {
        // Odd indices: at 100% height (tip)
        path.lineTo(x, size.height);
      }
    }
    
    // Close path: go back to left edge at 95% height (0% 95%), then to top-left
    path.lineTo(0, size.height - zigzagHeight);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

