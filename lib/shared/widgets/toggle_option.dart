import 'package:flutter/material.dart';

/// Shared toggle option widget
/// Used by both mobile and web screens
/// Matches React toggle style: w-11 h-6 bg-gray-200 rounded-full peer-checked:bg-black
class ToggleOption extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool disabled;

  const ToggleOption({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Matching React: opacity-50 on entire label when disabled
    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              // Matching React: font-[Gordita-medium] text-sm lg:text-base md:text-base
              // text-black text-opacity-80 when enabled, text-gray-400 when disabled
              style: TextStyle(
                fontFamily: 'Gordita',
                fontSize: 14, // text-sm (14px on mobile, 16px on large screens)
                fontWeight: FontWeight.w500, // font-[Gordita-medium]
                color: disabled
                    ? Colors.grey[400] // text-gray-400 when disabled
                    : Colors.black.withOpacity(0.8), // text-black text-opacity-80 when enabled
                letterSpacing: -0.05,
              ),
            ),
          ),
          GestureDetector(
            onTap: disabled ? null : () => onChanged(!value),
            child: Container(
              width: 44, // w-11 (44px)
              height: 24, // h-6 (24px)
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), // rounded-full
                // Matching React: bg-gray-300 when disabled, bg-gray-200 when enabled, bg-black when checked
                color: disabled
                    ? Colors.grey[300] // bg-gray-300 cursor-not-allowed when disabled
                    : value
                        ? Colors.black // peer-checked:bg-black
                        : Colors.grey[200], // bg-gray-200
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    // React: after:start-[2px] when off, peer-checked:after:translate-x-full when on
                    // translate-x-full means: move by (container width - circle width - start position)
                    // Container: 44px, Circle: 20px, Start: 2px
                    // When on: 44 - 20 - 2 = 22px from left
                    left: value ? 22.0 : 2.0,
                    top: 2.0, // after:top-0.5 (2px)
                    child: Container(
                      width: 20, // after:h-5 w-5 (20px)
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white, // after:bg-white
                        border: Border.all(
                          color: Colors.grey[300]!, // after:border-gray-300
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

