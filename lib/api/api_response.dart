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
    Map bodyData = {
      "access_key": accessKey,
      "access_secret": secreteKey
    };
    var dio = await NetworkHelper().getApiClient(false,'');
    Response response = await dio.post(NetworkHelper.baseUrl+getTokenUrl, data: bodyData);
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

  Future<Result<OrderDataResponseVo>> getOrderData(String currency, int price,String userFirstName,String userEmailId,String userMobileNumber,String token) async {
    String randomString = Utils().getRandomString(10);
    if (kDebugMode) {
      print('RandomString==>$randomString');
    }
    String useraddressLine1 = "My address";
    String userAddrStreet = "My street";
    String userAddrLandmark = "My landmark";
    String userAddrArea = "My area";
    String userAddrCity = "My city";
    String userAddrState = "My state";
    String userAddrPin = "1234567";


    Map bodyData = {
      "currency": currency,
      "total_amount": price,
      "amount_before_tax": price,
      "tax": 1,
      "invoice_id": "inv_$randomString",
      "referrer_platform": "flutter",
      "referrer_platform_version": "2.0.0",
      "callback_mode": "callback_mobile",
      "user": {
        "email": userEmailId,
        "first_name": userFirstName,
        "last_name": "",
        "country_code": "+91",
        "mobile_number": userMobileNumber,
      },
      "shipping_address": {
        "address_1":useraddressLine1,
        "street": userAddrStreet,
        "landmark": userAddrLandmark,
        "area": userAddrArea,
        "city": userAddrCity,
        "state": userAddrState,
        "pincode": userAddrPin,
        "address_type": "residential"
      }
    };

    if(userMobileNumber.isEmpty){
       bodyData = {
        "currency": currency,
        "total_amount": price,
        "amount_before_tax": price,
        "tax": 1,
        "invoice_id": "inv_$randomString",
        "referrer_platform": "flutter",
        "referrer_platform_version": "2.0.0",
        "callback_mode": "callback_mobile",
        "shipping_address": {
          "address_1":useraddressLine1,
          "street": userAddrStreet,
          "landmark": userAddrLandmark,
          "area": userAddrArea,
          "city": userAddrCity,
          "state": userAddrState,
          "pincode": userAddrPin,
          "address_type": "residential"
        }
      };
    }

    try {
      var dio = await NetworkHelper().getApiClient(true,token);
      Response response = await dio.post(NetworkHelper.baseUrl+getOrderDataUrl, data: bodyData);
      var responseData = json.decode(response.data);
      if (kDebugMode) {
        print(responseData);
      }

      if (response.statusCode == 201) {
        OrderDataResponseVo orderDataVo =
        OrderDataResponseVo.fromJson(jsonDecode(response.data));
        return Result(data: orderDataVo);
      } else {
        return Result(
          error: NimbblErrorResponse(
            error: NimbblError(nimbblMerchantMessage: 'Failed to load data.' ),
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
            error: NimbblError(nimbblMerchantMessage: 'Failed to load data.' ),
          ),
        );
      }
    } catch (error) {
      return Result(
        error: NimbblErrorResponse(
          error: NimbblError(nimbblMerchantMessage: 'Unexpected error.' ),
        ),
      );
    }

  }

}
