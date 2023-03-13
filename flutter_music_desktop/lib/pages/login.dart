import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_common/api/api.dart';
import 'package:music_common/entity/response_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/config_request.dart';
import '../global/g_variable.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),

          child: LoginFormWidget(),

      ),
    ));
  }
}

class LoginFormWidget extends StatelessWidget {
  LoginFormWidget({Key? key}) : super(key: key);
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    submit() async {
      final navigator = Navigator.of(context);
      if ((_formKey.currentState as FormState).validate()) {
        var username = _usernameController.text;
        var password = _passwordController.text;
        ResponseEntity responseEntity = await login(username, password);
        if (responseEntity.code == "200") {
          var map = Map.from(responseEntity.data);
          var instance = await SharedPreferences.getInstance();
          instance.setString("userInfo", json.encode(map));
          gUser.id = map['id'];
          gUser.username = map['username'];
          gUser.token = map['token'];
          baseOptions.headers = {'token': gUser.token};
          navigator.popAndPushNamed("/index");
        }
      }
      // return response;
    }

    if (!const bool.fromEnvironment('dart.vm.product')) {
      _usernameController.text = 'zyk';
      _passwordController.text = '123';
    }
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                margin: const EdgeInsets.all(10),
                child: const Image(
                  image: AssetImage('img/1.jpg'),
                ),
              ),
              TextFormField(
                controller: _usernameController,
                autofocus: false,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(18),
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
                ],
                decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: '用户名',
                    hintText: "用户名"),
                validator: (v) {
                  return v!.trim().isNotEmpty ? null : "用户名不能为空";
                },
              ),
              TextFormField(
                controller: _passwordController,
                keyboardType: TextInputType.number,
                obscureText: true,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(18),
                  FilteringTextInputFormatter.allow(RegExp('[0-9]'))
                ],
                decoration: const InputDecoration(
                  icon: Icon(Icons.lock),
                  labelText: "密码",
                  hintText: "密码",
                ),
                validator: (v) {
                  return v!.trim().isNotEmpty ? null : "密码不能为空";
                },
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(10),
                child: TextButton(
                  style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      backgroundColor: MaterialStateProperty.all(Colors.blue)),
                  child: const Text("登录"),
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(FocusNode()); //隐藏键盘
                    // EasyLoading.show(status: 'login...');
                    try {
                      await submit();
                    } finally {
                      // EasyLoading.dismiss();
                    }
                  },
                ),
              )
            ],
          ),
        ));
  }
}
