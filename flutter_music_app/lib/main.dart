import 'dart:async';
import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_music_app/player/player.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_common/entity/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/config_request.dart';
import 'global/g_variable.dart';
import 'routes/route.dart';

void main() async {
  initReq();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      null,
      [
        // NotificationChannel(
        //   channelKey: 'music_control',
        //   channelName: '音乐控制栏',
        //   channelDescription: '音乐控制栏',
        //   defaultPrivacy: NotificationPrivacy.Public,
        //   enableVibration: false,
        //   enableLights: false,
        //   playSound: false,
        //   locked: true,
        // ),
        NotificationChannel(
          channelKey: 'normal_msg',
          channelName: '普通消息通知',
          channelDescription: '普通消息通知',
          defaultPrivacy: NotificationPrivacy.Public,
          enableVibration: false,
          enableLights: false,
          playSound: false,
        ),
      ],
      debug: true);
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      // This is just a basic example. For real apps, you must show some
      // friendly dialog box before call the request method.
      // This is very important to not harm the user experience
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });
  runApp(MaterialApp(
    title: 'Flutter Demo',
    builder: EasyLoading.init(),
    routes: routes,
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    gHeight = MediaQuery.of(context).size.height;
    Player.init();
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
      Fluttertoast.showToast(
          msg: toastMsg,
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT);
      Timer(const Duration(seconds: 1), () {
        navigator.popAndPushNamed(nextRoute);
      });
    });
    EasyLoading.instance.userInteractions = false;
    return const Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Image(image: AssetImage('img/1.jpg'), fit: BoxFit.fill),
      ),
    );
  }
}
