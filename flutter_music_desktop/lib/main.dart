import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_music_desktop/config/config_request.dart';
import 'package:flutter_music_desktop/routes/route.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:music_common/entity/user.dart';
import 'package:music_common/utils/log.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'global/g_variable.dart';
import 'player/j_player.dart';

void main() async {
  initReq();
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  runApp(MaterialApp(
    builder: FlutterSmartDialog.init(builder: EasyLoading.init()),
    // builder: EasyLoading.init(builder: FlutterSmartDialog.init()),
    routes: routes,
    home: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  @override
  Widget build(BuildContext context) {
    JPlayer.init();
    final navigator = Navigator.of(context);
    SharedPreferences.getInstance().then((instance) {
      String nextRoute, toastMsg;
      // Navigator.of(context).popAndPushNamed("/login");
      if (instance.getString("userInfo") == null) {
        nextRoute = "/login";
        toastMsg = "未登录";
      } else {
        User user = User.fromJson(json.decode(instance.getString("userInfo")!));
        gUser.id = user.id;
        gUser.username = user.username;
        gUser.token = user.token;
        baseOptions.headers = {'token': gUser.token};
        nextRoute = "/index";
        toastMsg = "已登录";
      }
      EasyLoading.showToast(toastMsg);
      Timer(const Duration(seconds: 1), () {
        navigator.popAndPushNamed(nextRoute);
      });
    });
    return const Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Image(image: AssetImage('img/1.jpg'), fit: BoxFit.fill),
      ),
    );
  }

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void reassemble() {
    super.reassemble();
  }

  @override
  void onWindowClose() async {
    windowManager.removeListener(this);
    JPlayer.dispose();
    LogE("window close");
    super.onWindowClose();
  }
}
