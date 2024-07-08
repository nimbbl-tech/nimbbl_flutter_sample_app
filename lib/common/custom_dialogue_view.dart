import 'package:flutter/material.dart';

import '../utils/colors.dart';

class CustomDialogueView extends StatelessWidget {
  final String? title1;
  final String? title2;
  final String? description;
  final List<Widget>? actions;
  final double? width;

  const CustomDialogueView({
    super.key,
    this.title1,
    this.title2,
    this.description,
    this.actions,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title1 ?? " ",
                //style: context.headlineLarge?.copyWith(
                style: const TextStyle(
                    color: pinkColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
              Text(
                title2 ?? " ",
                //style: context.headlineLarge?.copyWith(
                style: const TextStyle(
                    color: blackColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
            ],
          ),
          GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(
                Icons.close,
                size: 20,
                color: blackColor,
              ))
        ],
      ),
      content: SizedBox(
        width: width,
        child: Text(
          description ?? " ",
          maxLines: 4,
          textAlign: TextAlign.start,
          //style: context.headlineLarge?.copyWith(
          style: const TextStyle(
              color: blackColor, fontWeight: FontWeight.w400, fontSize: 14),
        ),
      ),
      actions: actions ?? [],
      actionsAlignment: MainAxisAlignment.center,
      shape:  RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      surfaceTintColor: whiteColor,
    );
  }
}
