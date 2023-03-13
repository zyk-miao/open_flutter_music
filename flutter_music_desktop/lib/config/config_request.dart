import 'package:dio/dio.dart';
import 'package:music_common/api/request.dart';

const _debugBaseUrl = 'http://127.0.0.1:8700/api/';
const _releaseBaseUrl = 'http://127.0.0.1:8701/api/';
var baseOptions = BaseOptions(
  baseUrl: baseUrl,
  connectTimeout: const Duration(seconds: 5),
  receiveTimeout: const Duration(seconds: 10),
);
String baseUrl = const bool.fromEnvironment('dart.vm.product')
    ? _releaseBaseUrl
    : _debugBaseUrl;

initReq() {
  configOptions(baseOptions);
  // setReqCallBack(reqSuccess, reqFail, reqError);
}
