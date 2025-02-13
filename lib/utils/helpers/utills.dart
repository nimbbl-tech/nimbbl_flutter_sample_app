import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nimbbl_mobile_kit_flutter_core_api_sdk/utils/api_utils.dart';

import '../colors.dart';

class Utils {
  static final Utils _singleton = Utils._internal();

  factory Utils() {
    return _singleton;
  }

  Utils._internal();

  String getProductID(String header) {
    if (kDebugMode) {
      print("header--->$header");
    }
    switch (header) {
      case "your brand name and brand logo":
        return "11";
      case "your brand logo":
        return "12";
      case "your brand name":
        return "13";
    }
    return "";
  }

  String getShopUrl(String url) {
    switch (url) {
      case baseUrlPP:
        return "https://sonicshopapipp.nimbbl.tech/create-shop";
      case baseUrlUAT:
        return "https://qa1sonicshopapi.nimbbl.tech/create-shop";
      case baseUrlPROD:
        return "https://sonicshopapi.nimbbl.tech/create-shop";
    }
    return "";
  }

  String getRandomString(int length) {
    const allowedChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        'abcdefghijklmnopqrstuvwxyz'
        '0123456789';
    return String.fromCharCodes(Iterable.generate(length,
        (_) => allowedChars.codeUnitAt(Random().nextInt(allowedChars.length))));
  }

  String getPaymentModeCode(String paymentMode) {
    switch (paymentMode) {
      case "all payments modes":
        return "";
      case "netbanking":
        return "Netbanking";
      case "wallet":
        return "Wallet";
      case "card":
        return "card";
      case "upi":
        return "UPI";
      default:
        return "";
    }
  }

  String getBankCode(String bankName) {
    switch (bankName) {
      case "all banks":
        return "";
      case "hdfc bank":
        return "hdfc";
      case "sbi bank":
        return "sbi";
      case "kotak bank":
        return "kotak";
      default:
        return "";
    }
  }

  String getWalletCode(String walletName) {
    switch (walletName) {
      case "all wallets":
        return "";
      case "freecharge":
        return "freecharge";
      case "jio money":
        return "jio_money";
      case "phonepe":
        return "phonepe";
      default:
        return "";
    }
  }

  String getPaymentFlow(String upiModeName) {
    switch (upiModeName) {
      case "collect + intent":
        return "phonepe";
      case "collect":
        return "collect";
      case "intent":
        return "intent";
      default:
        return "";
    }
  }
  static showToast(BuildContext context, String strMessage) {
    Fluttertoast.showToast(
        msg: strMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: blackColor,
        textColor: whiteColor,
        fontSize: 18.0);
  }
  static SnackBar createSnackBar(String message, BuildContext ctx) {
    return SnackBar(
      backgroundColor: Colors.grey,
      action: SnackBarAction(
        backgroundColor: blackColor,
        label: 'Ok',
        textColor:whiteColor,
        onPressed: () {},
      ),
      content: Text(
        message,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: whiteColor),
      ),
    );
  }
}
