import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nimbbl_flutter_sample_app/api/result.dart';
import 'package:nimbbl_flutter_sample_app/utils/helpers/utills.dart';
import 'package:nimbbl_mobile_kit_flutter_core_api_sdk/model/nimbbl_error_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/home_page_model/generate_token_vo.dart';
import '../model/home_page_model/order_data_response_vo.dart';
import '../utils/constants/constants.dart';
import 'api_constants.dart';
import 'network_helper.dart';

class APIResponse {
  static final APIResponse _singleton = APIResponse._internal();

  factory APIResponse() {
    return _singleton;
  }

  APIResponse._internal();

  Future<GenerateTokenVo> getToken(String accessKey, String secreteKey) async {
    Map bodyData = {"access_key": accessKey, "access_secret": secreteKey};
    var dio = await NetworkHelper().getApiClient(false, '');
    Response response =
        await dio.post(NetworkHelper.baseUrl + getTokenUrl, data: bodyData);
    var responseData = json.decode(response.data);
    if (kDebugMode) {
      print(responseData);
    }
    GenerateTokenVo userVo =
        GenerateTokenVo.fromJson(jsonDecode(response.data));

    var token = userVo.token.toString();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(accessTokenPref, token);

    return userVo;
  }

  Future<Result<OrderDataResponseVo>> getOrderData(
    String currency,
    int price,
    String userFirstName,
    String userEmailId,
    String userMobileNumber,
    String productId,
    String paymentCode,
    String subPaymentCode,
  ) async {
    String randomString = Utils().getRandomString(10);
    if (kDebugMode) {
      print('RandomString==>$randomString');
    }

    Map bodyData = {
      "currency": currency,
      "amount": price.toString(),
      "product_id": productId,
      "orderLineItems": true,
      "checkout_experience": "redirect",
      "payment_mode": paymentCode,
      "subPaymentMode": subPaymentCode,
      "user": {
        "email": userEmailId,
        "name": userFirstName,
        "mobile_number": userMobileNumber,
      },
    };

    try {
      var dio = await NetworkHelper().getApiClient(false, '');
      Response response = await dio
          .post(Utils().getShopUrl(NetworkHelper.baseUrl), data: bodyData);
      var responseData = json.decode(response.data);
      if (kDebugMode) {
        print(responseData);
      }

      if (response.statusCode == 200) {
        OrderDataResponseVo orderDataVo =
            OrderDataResponseVo.fromJson(jsonDecode(response.data));
        return Result(data: orderDataVo);
      } else {
        return Result(
          error: NimbblErrorResponse(
            error: NimbblError(nimbblMerchantMessage: 'Failed to load data.'),
          ),
        );
      }
    } on DioException catch (error) {
      if (error.response != null) {
        return Result(
          error: NimbblErrorResponse.fromJson(jsonDecode(error.response?.data)),
        );
      } else {
        return Result(
          error: NimbblErrorResponse(
            error: NimbblError(nimbblMerchantMessage: 'Failed to load data.'),
          ),
        );
      }
    } catch (error) {
      return Result(
        error: NimbblErrorResponse(
          error: NimbblError(nimbblMerchantMessage: 'Unexpected error.'),
        ),
      );
    }
  }
}
