import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:music_common/entity/response_entity.dart';
import 'package:music_common/utils/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Dio _dio = Dio()..interceptors.add(DioLogInterceptor());
const _defaultReceiveTimeout=Duration(seconds: 5);
void configOptions(BaseOptions options) {
  _dio.options = options;
  _dio.options.contentType = Headers.jsonContentType;
}
void Function(String? msg) _success = (msg) {
  EasyLoading.showToast(msg ?? "ok");
};
void Function(String?) _fail = (msg) {
  EasyLoading.showError(msg ?? "fail");
};
VoidCallback _error = () {
  EasyLoading.showError("network error");
};
VoidCallback _downloadSuccess = () {
  EasyLoading.showToast('download success');
};
VoidCallback _downloadFail = () {
  EasyLoading.showToast('download fail');
};

void setDownloadCallback(success, fail) {
  _downloadSuccess = success;
  _downloadFail = fail;
}

class DioLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    LogD(options.uri);
    LogD(options.headers);
    LogD(options.data);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    LogD(response.data);
    handler.next(response);
  }
}

setReqCallBack(void Function(String?) success, void Function(String? msg) fail,
    VoidCallback error) {
  _success = success;
  _fail = fail;
  _error = error;
}

sendRequest(String path,
    {params, data, method = 'GET', receiveTimeout =_defaultReceiveTimeout,String contentType=Headers.jsonContentType}) async {
  String key = "$path$params$data";
  // SmartDialog.showLoading();
  EasyLoading.show(status: 'loading...');
  int status = 0;
  ResponseEntity responseEntity = ResponseEntity();
  try {
    var response = await _dio.request(
      path,
      options: Options(
          method: method,
          headers: {'content-type':contentType},
          receiveTimeout: receiveTimeout),
      queryParameters: params,
      data: data,
    );
    responseEntity = ResponseEntity.fromJson(response.data);
    if (responseEntity.code == '200') {
      if (path.contains("select")) {
        var instance = await SharedPreferences.getInstance();
        instance.setString(key, json.encode(responseEntity));
      }
    } else {
      status = 1;
    }
    return responseEntity;
  } on DioError catch (e) {
    status = 2;
    var instance = await SharedPreferences.getInstance();
    String? s = instance.getString(key);
    if (s != null) {
      responseEntity = ResponseEntity.fromJson(json.decode(s));
      return responseEntity;
    }
  } finally {
    EasyLoading.dismiss();
    switch (status) {
      case 0:
        if (!const bool.fromEnvironment('dart.vm.product') ||
            !path.contains("select")) {
          _success(responseEntity.msg);
        }
        break;
      case 1:
        _fail(responseEntity.msg);
        break;
      case 2:
        _error();
        break;
    }
  }
}

postAction(path, {data, params, receiveTimeout =_defaultReceiveTimeout}) async {
  return await sendRequest(path,
      method: METHOD.post.name,
      data: data,
      params: params,
      receiveTimeout: receiveTimeout);
}

getAction(path, {params}) async {
  return await sendRequest(path, params: params);
}

delAction(path, {data, params}) async {
  return await sendRequest(path,
      method: METHOD.delete.name, data: data, params: params);
}

VoidCallback downloadSuccess = () {
  EasyLoading.showToast('download success');
};

downloadFile(url, path, {VoidCallback? success, VoidCallback? fail}) {
  _dio
      .download(
    url,
    path,
    options: Options(receiveTimeout: const Duration()),
  )
      .then((req) {
    if (req.statusCode == 200) {
      if (success != null) {
        success();
      } else {
        _downloadSuccess();
      }
    } else {
      if (fail != null) {
        fail();
      } else {
        _downloadFail();
      }
    }
  });
}

enum METHOD { get, post, delete }
