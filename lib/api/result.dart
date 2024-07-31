import 'package:nimbbl_mobile_kit_flutter_core_api_sdk/model/nimbbl_error_response.dart';

class Result<T> {
  final T? data;
  final NimbblErrorResponse? error;

  Result({this.data, this.error});
}
