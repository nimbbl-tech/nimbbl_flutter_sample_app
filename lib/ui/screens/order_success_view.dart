
import 'package:flutter/material.dart';

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
            title: const Text(
              'Order Success',
              //style:  context.gorditasTitle1.copyWith(
              style: TextStyle(
                  color: whiteColor, fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          body:  Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Text("$orderIdStr${widget.orderID}",
                  //style:  context.gorditasTitle1.copyWith(
                  style: const TextStyle(
                      color:blackColor, fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 10,),
                 Text(
                  '$statusStr${widget.status}',
                  //style:  context.gorditasTitle1.copyWith(
                  style: const TextStyle(
                      color: blackColor, fontWeight: FontWeight.w600, fontSize: 16),
                )
              ],
            ),
          ),
        ));
  }
}
