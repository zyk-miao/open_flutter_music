import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:music_common/api/request.dart';

const _debugBaseUrl = 'http://10.1.2.168:8700/api/';
//正式地址
const _releaseBaseUrl = 'http://127.0.0.1:8701/api/';
var baseOptions = BaseOptions(
  baseUrl: baseUrl,
  connectTimeout: const Duration(seconds: 5),
  receiveTimeout: const Duration(seconds: 5),
);
String baseUrl = const bool.fromEnvironment('dart.vm.product')
    ? _releaseBaseUrl
    : _debugBaseUrl;
void Function(String?) reqSuccess = (msg) {
  Fluttertoast.showToast(
    msg: msg ?? "无msg",
    gravity: ToastGravity.CENTER,
  );
};
void Function(String?) reqFail = (msg) {
  Fluttertoast.showToast(
    msg: msg ?? "无msg",
    gravity: ToastGravity.CENTER,
    textColor: Colors.redAccent,
  );
};
void Function() reqError = () {
  Fluttertoast.showToast(
    textColor: Colors.redAccent,
    msg: "网络错误",
    gravity: ToastGravity.CENTER,
  );
};

initReq() {
  configOptions(baseOptions);
  setReqCallBack(reqSuccess, reqFail, reqError);
}
