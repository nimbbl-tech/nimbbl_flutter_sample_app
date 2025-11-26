import 'package:flutter/material.dart';

import '../constants/order_create_data_values.dart';

/// Custom painter for dashed line
class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashSpace;

  DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashLength, size.height / 2),
        paint,
      );
      startX += dashLength + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Shared currency and amount input widget
/// Used by both mobile and web screens
class CurrencyAmountInput extends StatelessWidget {
  final String currency;
  final String amount;
  final TextEditingController amountController;
  final ValueChanged<String> onCurrencyChanged;
  final ValueChanged<String> onAmountChanged;

  const CurrencyAmountInput({
    Key? key,
    required this.currency,
    required this.amount,
    required this.amountController,
    required this.onCurrencyChanged,
    required this.onAmountChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Matching React: gradient background wrapper with rounded-[8px]
    // React: background: 'linear-gradient(136deg, #F6F6F6 -4.02%, #E9E9E9 83.84%)'
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.71, -0.71), // 136deg approximation
          end: Alignment(0.71, 0.71),
          colors: [
            Color(0xFFF6F6F6), // -4.02%
            Color(0xFFE9E9E9), // 83.84%
          ],
          stops: [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(8), // Matching React: rounded-[8px]
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Currency Dropdown
          // Matching React: flex p-2 items-center gap-2
          Padding(
            padding: const EdgeInsets.all(8), // Matching React: p-2
            child: Row(
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: currency,
                    isExpanded: false,
                    style: const TextStyle(
                      fontFamily: 'Gordita',
                      fontSize: 18, // Matching React: text-lg (18px)
                      fontWeight: FontWeight.w700, // Matching React: font-[Gordita-bold]
                      color: Colors.black,
                    ),
                    underline: const SizedBox.shrink(),
                    icon: const Icon(Icons.arrow_drop_down, size: 16),
                    items: currencyOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        onCurrencyChanged(value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8), // Matching React: gap-2 (8px)
              ],
            ),
          ),
          // Divider - Matching React: border-l border-[#CBD4E1]
          Container(
            width: 1,
            height: 24,
            color: const Color(0xFFCBD4E1),
          ),
          // Amount Field
          // Matching React: flex px-2 items-center
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8), // Matching React: px-2
            child: Stack(
              children: [
                // Text field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8), // Matching React: px-2
                  child: SizedBox(
                    width: 60, // Matching React: size={7} (approximately)
                    child: TextFormField(
                      controller: amountController,
                      onChanged: onAmountChanged,
                      textAlign: TextAlign.center, // Matching React: text-center
                      textAlignVertical: TextAlignVertical.center,
                      maxLength: 7, // Matching React: maxLength={7}
                      style: const TextStyle(
                        fontFamily: 'Gordita',
                        fontSize: 18, // Matching React: text-lg
                        fontWeight: FontWeight.w700, // Matching React: font-[Gordita-bold]
                        color: Colors.black,
                      ),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        counterText: '', // Hide character counter
                      ),
                    ),
                  ),
                ),
                // Dashed bottom border - Matching React: border-b border-dashed border-[#6C7F9A]
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 0,
                  child: CustomPaint(
                    size: const Size(double.infinity, 1),
                    painter: DashedLinePainter(
                      color: const Color(0xFF6C7F9A), // Matching React: border-[#6C7F9A]
                      strokeWidth: 1,
                      dashLength: 5,
                      dashSpace: 5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

