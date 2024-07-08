
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_settings.dart';

import '../utils/constants/constants.dart';

class NetworkHelper{

  static final NetworkHelper _singleton = NetworkHelper._internal();
  static String baseUrl = "https://api.nimbbl.tech/";

  factory NetworkHelper(){
    return _singleton;
  }

  NetworkHelper._internal();

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString(accessTokenPref) ?? '';
    return token;
  }

  Future<Dio> getApiClient(bool isAuth,String token) async {
    var dio = Dio(BaseOptions(
        //baseUrl: BASEURL,
        connectTimeout: const Duration(minutes: 1),
        receiveTimeout: const Duration(minutes: 1),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.plain));
    if (isAuth) {
      if (token.isNotEmpty) {
        if (kDebugMode) {
          print('token-->$token');
        }
        dio.options.headers['Authorization'] = "Bearer $token";
      }
    }
    if (kDebugMode) {
      dio.interceptors.add(
        TalkerDioLogger(
          settings: const TalkerDioLoggerSettings(
              printRequestHeaders: true,
              printResponseHeaders: true,
              printResponseMessage: true,
              printRequestData: true,
              printResponseData: true),
        ),
      );
    }
    return dio;
  }

}