/// Nimbbl Standalone Payment App
///
/// A minimal standalone Flutter app for testing Nimbbl payment integration.
/// Enter your order token and tap "Pay Now" to initiate a payment.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nimbbl_mobile_kit_flutter_webview_sdk/nimbbl_checkout_sdk.dart';
import 'package:nimbbl_mobile_kit_flutter_webview_sdk/types.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Nimbbl SDK once at startup
  await NimbblCheckoutSDK.instance.initialize(
    SDKConfig(
      enableDebugLogs: kDebugMode,
    ),
  );

  runApp(const NimbblStandaloneApp());
}

class NimbblStandaloneApp extends StatelessWidget {
  const NimbblStandaloneApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nimbbl Payment',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F51F3)),
        useMaterial3: true,
      ),
      home: const OrderTokenScreen(),
    );
  }
}

class OrderTokenScreen extends StatefulWidget {
  const OrderTokenScreen({Key? key}) : super(key: key);

  @override
  State<OrderTokenScreen> createState() => _OrderTokenScreenState();
}

class _OrderTokenScreenState extends State<OrderTokenScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController(
    text: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ1cm46bmltYmJsIiwiaWF0IjoxNzc1NDg0Njc4LCJleHAiOjE3NzU0ODU4NzgsInR5cGUiOiJvcmRlciIsInN1Yl9tZXJjaGFudF9pZCI6MjAyLCJvcmRlcl9pZCI6Im9fM3pNNUJMcjQ5cTg0UmdXeCJ9.ZckU9Id74l1kzZLN39p5HSIK2oa06DDcQAwm18IA6P8',
  );
  bool _isLoading = false;

  void _logLongDebug(String message) {
    const chunkSize = 800;
    if (!kDebugMode) return;
    for (var i = 0; i < message.length; i += chunkSize) {
      final end = (i + chunkSize < message.length) ? i + chunkSize : message.length;
      debugPrint(message.substring(i, end));
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final checkoutOptions = CheckoutOptions(
        orderToken: _tokenController.text.trim(),
      );

      final result = await NimbblCheckoutSDK.instance.checkout(checkoutOptions);

      if (mounted && kDebugMode) {
        final pretty = const JsonEncoder.withIndent('  ').convert(result);
        _logLongDebug('NIMBBL_CHECKOUT_RESULT (simple_example): $pretty');
      }

      if (mounted) {
        final status = result['status'] ?? 'unknown';
        _showResultSheet(status, result);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showResultSheet(String status, Map<String, dynamic> result) {
    final isSuccess = status == 'success';
    final isFailed = status == 'failed';
    final isCancelled = status == 'cancelled';

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSuccess
                  ? Icons.check_circle_rounded
                  : isCancelled
                  ? Icons.cancel_outlined
                  : Icons.error_rounded,
              size: 64,
              color: isSuccess
                  ? Colors.green
                  : isCancelled
                  ? Colors.orange
                  : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              isSuccess
                  ? 'Payment Successful!'
                  : isCancelled
                  ? 'Payment Cancelled'
                  : isFailed
                  ? 'Payment Failed'
                  : 'Payment Status: $status',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (result['payment_id'] != null) ...[
              _ResultRow(label: 'Payment ID', value: result['payment_id']),
            ],
            if (result['order_id'] != null) ...[
              _ResultRow(label: 'Order ID', value: result['order_id']),
            ],
            if (result['message'] != null && !isSuccess) ...[
              _ResultRow(label: 'Message', value: result['message']),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Nimbbl Payment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.payment_rounded,
                          size: 48, color: Colors.white),
                      const SizedBox(height: 12),
                      const Text(
                        'Enter Order Token',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Paste your order token below to initiate payment',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Form card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Token',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _tokenController,
                          decoration: InputDecoration(
                            hintText: 'e.g. ot_xxxxxxxxxxxxxxxx',
                            prefixIcon: const Icon(Icons.token_rounded),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _tokenController.clear(),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          maxLines: 3,
                          minLines: 1,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handlePayment(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter an order token';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _handlePayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: scheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: _isLoading
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Icon(Icons.lock_rounded),
                            label: Text(
                              _isLoading ? 'Processing...' : 'Pay Now',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Info note
                Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Generate the order token from your backend using Nimbbl S2S API before proceeding.',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small helper widget to display a labeled result row
class _ResultRow extends StatelessWidget {
  final String label;
  final dynamic value;

  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '-',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
