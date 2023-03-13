/// code : "200"
/// msg : "登陆成功"
/// data : null

class ResponseEntity {
  ResponseEntity({
    String? code,
    String? msg,
    dynamic data,
  }) {
    _code = code;
    _msg = msg;
    _data = data;
  }

  ResponseEntity.fromJson(dynamic json) {
    _code = json['code'];
    _msg = json['msg'];
    _data = json['data'];
  }

  String? _code;
  String? _msg;
  dynamic _data;

  ResponseEntity copyWith({
    String? code,
    String? msg,
    dynamic data,
  }) =>
      ResponseEntity(
        code: code ?? _code,
        msg: msg ?? _msg,
        data: data ?? _data,
      );

  String? get code => _code;

  String? get msg => _msg;

  dynamic get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = _code;
    map['msg'] = _msg;
    map['data'] = _data;
    return map;
  }

  @override
  String toString() {
    return 'ResponseEntity{_code: $_code, _msg: $_msg, _data: $_data}';
  }
}
