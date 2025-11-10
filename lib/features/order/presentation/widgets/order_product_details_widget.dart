import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/constants/app_strings.dart';
import '../../../../shared/widgets/order_create_data_values.dart';
import '../providers/order_provider.dart';

/// Widget that displays product title, currency, and amount in one row
class OrderProductDetailsWidget extends StatelessWidget {
  const OrderProductDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        return Container(
          margin: const EdgeInsets.fromLTRB(
            AppConstants.defaultPadding,
            0,
            AppConstants.defaultPadding,
            AppConstants.defaultPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Product Title
              const Text(
                'paper plane.',
                style: AppTheme.headingSmall,
              ),
              
              // Currency and Amount Container
              Row(
                children: [
                  // Currency Dropdown
                  Container(
                    width: 60,
                    height: AppConstants.inputFieldHeight,
                    margin: const EdgeInsets.only(right: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.inputBackgroundColor,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: orderProvider.orderData.currency,
                        isExpanded: true,
                        style: AppTheme.inputText,
                        items: currencyOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            orderProvider.handleCurrencyChange(newValue);
                          }
                        },
                      ),
                    ),
                  ),
                  
                  // Amount Field
                  Container(
                    width: 50,
                    height: AppConstants.inputFieldHeight,
                    decoration: BoxDecoration(
                      color: AppTheme.inputBackgroundColor,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    child: DottedBorder(
                      color: AppTheme.borderColor,
                      strokeWidth: 1,
                      dashPattern: const [5, 5],
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(AppConstants.borderRadius),
                      child: TextFormField(
                        initialValue: orderProvider.orderData.amount,
                        onChanged: orderProvider.handleAmountChange,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        style: AppTheme.inputText,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                          hintText: AppStrings.enterAmount,
                          hintStyle: AppTheme.hintText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
