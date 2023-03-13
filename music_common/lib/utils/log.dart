import 'package:logger/logger.dart';

String _tag = DateTime.now().toString();

var _logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
  ),
);

LogV(String msg) {
  _logger.v("$_tag :: $msg");
}

LogD(dynamic msg) {
  _logger.d("debug $_tag :: ${msg.toString()}");
}

LogI(String msg) {
  _logger.i("$_tag :: $msg");
}

LogW(String msg) {
  _logger.w("$_tag :: $msg");
}

LogE(dynamic msg) {
  _logger.e("$_tag :: ${msg.toString()}");
}

LogWTF(String msg) {
  _logger.wtf("$_tag :: $msg");
}
