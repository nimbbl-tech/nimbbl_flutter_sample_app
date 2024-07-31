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

  String getAccessKey(String url, String header) {
    if (kDebugMode) {
      print("url---->$url/////header--->$header");
    }
    switch (url) {
      case baseUrlPP:
        switch (header) {
          case "your brand name and brand logo":
            return "access_key_WKO7dmkKnlwpBvdl";
           // return "access_key_1MwvMlANM5Lqk7ry";
          case "your brand logo":
            return "access_key_94Y3mmW5YJEaa3dE";
          case "your brand name":
            return "access_key_mVG3568XjBZON0kZ";
        }
        break;
      case baseUrlUAT:
        switch (header) {
          case "your brand name and brand logo":
            return "access_key_RqLva5xqjjWxAvQZ";
          case "your brand logo":
            return "access_key_Pm43nNr6RVQZA3GL";
          case "your brand name":
            return "access_key_j8w0yLqDzRmqp3Ba";
        }
        break;
      case baseUrlPROD:
        switch (header) {
          case "your brand name and brand logo":
            return "";
          case "your brand logo":
            return "";
          case "your brand name":
            return "";
        }
        break;
    }
    return "";
  }

  String getAccessSecret(String url, String header) {
    switch (url) {
      case baseUrlPP:
        switch (header) {
          case "your brand name and brand logo":
            return "access_secret_ROG3K9DyyPOPL7kq";
            //return "access_secret_WKO7dnm5dpeRB3dl";
          case "your brand logo":
            return "access_secret_rQv9VROL8RKPD3zg";
          case "your brand name":
            return "access_secret_6EAvqK8jg4Lwr0PD";
        }
        break;
      case baseUrlUAT:
        switch (header) {
          case "your brand name and brand logo":
            return "access_secret_aKQvPDKGxemWjv9z";
          case "your brand logo":
            return "access_secret_ArL0OVMBZOnXM3zP";
          case "your brand name":
            return "access_secret_wlvDmqjR9njxB3JQ";
        }
        break;
      case baseUrlPROD:
        switch (header) {
          case "your brand name and brand logo":
            return "";
          case "your brand logo":
            return "";
          case "your brand name":
            return "";
        }
        break;
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
