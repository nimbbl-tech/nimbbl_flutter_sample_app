
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../utils/colors.dart';
import '../../utils/strings.dart';

class OrderSuccessView extends StatefulWidget {
  final String? orderID ;
  final String? status ;

  const OrderSuccessView({super.key,this.orderID,this.status});

  @override
  State<OrderSuccessView> createState() => _OrderSuccessViewState();
}

class _OrderSuccessViewState extends State<OrderSuccessView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: whiteColor),
            backgroundColor: blackColor,
            leading: Row(
              children: [
                const Gap(14),
                Image.asset(
                  height: 31,
                  width: 85,
                  "assets/images/headerLogo.png",
                ),
              ],
            ),
            titleSpacing: 0,
            leadingWidth: 100,
            title: const Text(
              header1,
              //style:  context.gorditasTitle1.copyWith(
              style: TextStyle(
                  color: whiteColor, fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          body:  Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    "OrderID: ${widget.orderID}",
                    //style:  context.gorditasTitle1.copyWith(
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 10,),
                   Text(
                    'Status: ${widget.status}',
                    //style:  context.gorditasTitle1.copyWith(
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
