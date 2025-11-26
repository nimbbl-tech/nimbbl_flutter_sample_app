import 'package:flutter/material.dart';

import '../constants/app_strings.dart';

/// Shared view mode selector widget
/// Used by web screen for selecting mobile/desktop view mode
/// Matches React ViewMode component behavior exactly
class ViewModeSelector extends StatelessWidget {
  final bool value; // renderDesktopUi value
  final bool orderLineItems; // orderLineItems value
  final bool disabled; // disabled prop (typically enableAddressCod)
  final ValueChanged<bool> onChanged;

  const ViewModeSelector({
    Key? key,
    required this.value,
    required this.orderLineItems,
    this.disabled = false,
    required this.onChanged,
  }) : super(key: key);

  /// Check if the toggle should be checked
  /// Matches React: checked={userInteractedDetails.render_desktop_ui && orderLineItems}
  bool get isChecked => value && orderLineItems;

  /// Check if the toggle should be disabled
  /// Matches React: disabled={disabled || !orderLineItems}
  bool get isDisabled => disabled || !orderLineItems;

  @override
  Widget build(BuildContext context) {
    // Hidden on small screens (matching React: hidden lg:flex)
    // Only show on large screens (≥1024px, matching Tailwind lg breakpoint)
    // Use MediaQuery to check actual screen width, not widget constraints
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Hide on screens smaller than 1024px (lg breakpoint)
    if (screenWidth < 1024) {
      return const SizedBox.shrink();
    }

    // Matching React: label with items-center justify-between (row layout)
    return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Label text (matching React span with mb-4, but in row layout mb-4 doesn't apply)
            Text(
              AppStrings.viewMode,
              style: TextStyle(
                fontFamily: 'Gordita',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDisabled 
                    ? Colors.grey[400] 
                    : Colors.black.withOpacity(0.8),
                letterSpacing: -0.05,
              ),
            ),
            // Toggle container (matching React div with toggle)
            GestureDetector(
              onTap: isDisabled ? null : () => onChanged(!value),
              child: Opacity(
                opacity: isDisabled ? 0.5 : 1.0,
                child: Container(
                  width: 90,
                  height: 40,
                  padding: const EdgeInsets.all(8), // p-2 = 8px
                  decoration: BoxDecoration(
                    color: isDisabled
                        ? const Color(0xFFD1D5DB) // bg-gray-300 when disabled
                        : const Color(0xFFE5E7EB), // bg-gray-200 when enabled
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none, // Allow slider to extend if needed
                    children: [
                      // Animated toggle indicator - sized to properly cover icons
                      // React: after:w-[40%] after:h-[80%] after:top-1 after:start-2
                      // Container: 40px height, h-[80%] = 32px, top-1 = 4px from container top
                      // Slider center: 4px + 16px = 20px from container top
                      // Stack has 8px padding, so slider center is at 20px - 8px = 12px from Stack top
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        left: isChecked ? 44 : 2, // start-2 = 2px, moves to cover right icon
                        top: -4, // Match React's top-1 (4px from container top, accounting for 8px padding)
                        child: Container(
                          width: 42, // w-[40%] of 90px = 36px, but we use 42px to better cover icons
                          height: 32, // h-[80%] of 40px container = 32px (matches React exactly)
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFD1D5DB), 
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      // Icons row - positioned to be centered in the slider
                      // Slider is at top: -4px with height 32px, so center is at -4 + 16 = 12px from Stack top
                      // Icons are 24px, so we center them at 12px (which is the slider center)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone_android,
                              size: 24,
                              color: !isChecked 
                                  ? Colors.black 
                                  : Colors.black54,
                            ),
                            const SizedBox(width: 16), // gap-4 = 16px
                            Icon(
                              Icons.desktop_windows,
                              size: 24,
                              color: isChecked 
                                  ? Colors.black 
                                  : Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
  }
}

