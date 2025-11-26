import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Shared info message widget
/// Used by both mobile and web screens for displaying informational messages
class InfoMessage extends StatelessWidget {
  final String message;
  final int? maxLines;
  final EdgeInsets? padding;

  const InfoMessage({
    Key? key,
    required this.message,
    this.maxLines,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Matching React: <span className='flex py-2'>
    // <InfoIcon className='mr-2 min-w-[18px] min-h-[18px]' />
    // <p className='italic text-xs lg:text-sm md:text-sm -tracking-[2%] text-black text-opacity-60'>
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8), // Matching React: py-2 (8px)
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 18, // Matching React: min-w-[18px] min-h-[18px]
            height: 18,
            child: SvgPicture.asset(
              'assets/images/InfoIcon.svg',
              width: 18,
              height: 18,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 8), // Matching React: mr-2 (8px)
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: 'Gordita',
                color: Colors.black.withOpacity(0.6), // Matching React: text-black text-opacity-60
                fontSize: 12, // Matching React: text-xs (12px on mobile), lg:text-sm md:text-sm (14px on desktop)
                fontStyle: FontStyle.italic, // Matching React: italic
                letterSpacing: -0.02, // Matching React: -tracking-[2%]
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: maxLines ?? 2,
            ),
          ),
        ],
      ),
    );
  }
}

