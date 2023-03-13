import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_music_app/common/function.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:music_common/api/api.dart';
import 'package:music_common/entity/music.dart';
import 'package:music_common/entity/response_entity.dart';
import 'package:music_common/utils/log.dart';

import '../../Icons/Icons.dart';

enum MusicAddFormType { add, edit, addFromYoutube }

class MusicAddForm extends StatefulWidget {
  const MusicAddForm(
      {Key? key,
      this.type = MusicAddFormType.add,
      this.music,
      this.youtubeVideoId})
      : super(key: key);
  final MusicAddFormType type;
  final Music? music;
  final String? youtubeVideoId;

  @override
  State<MusicAddForm> createState() => _MusicAddFormState();
}

class _MusicAddFormState extends State<MusicAddForm> {
  final TextEditingController _musicNameController = TextEditingController();
  final TextEditingController _musicAuthorController = TextEditingController();
  String? filePath;

  _addMusic() async {
    final navigator = Navigator.of(context);
    if (filePath == null) {
      EasyLoading.showError("没有选择文件!");
      return;
    }
    ResponseEntity response = await addMusic(
        filePath!,
        Music(
            musicName: _musicNameController.text,
            artistName: _musicAuthorController.text));
    if (response.code == '200') {
      navigator.pop();
    }
  }

  _putMusic() async {
    final navigator = Navigator.of(context);
    ResponseEntity response = await putMusic(Music(
        musicName: _musicNameController.text,
        artistName: _musicAuthorController.text,
        id: widget.music!.id));
    if (response.code == '200') {
      initMusicList();
      navigator.pop();
    }
  }

  _addMusicFromYoutube(String videoId) async {
    final navigator = Navigator.of(context);
    ResponseEntity response = await addMusicFromYoutube(
        Music(
          musicName: _musicNameController.text,
          artistName: _musicAuthorController.text,
        ),
        videoId);
    if (response.code == '200') {
      initMusicList();
      navigator.pop();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.music != null) {
      _musicNameController.text = widget.music!.musicName ?? "未知";
      _musicAuthorController.text = widget.music!.artistName ?? "未知";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          Offstage(
            offstage: widget.type != MusicAddFormType.add,
            child: TextButton(
                onPressed: () {
                  FilePicker.platform.pickFiles().then((result) {
                    if (result != null) {
                      File file = File(result.files.single.path!);
                      filePath = file.path;
                      var fileName = filePath!.substring(
                          filePath!.lastIndexOf("/") + 1, filePath!.length);
                      var musicName =
                          fileName.substring(0, fileName.lastIndexOf("."));
                      if (musicName.contains("-")) {
                        _musicAuthorController.text = musicName.split("-")[0];
                        _musicNameController.text = musicName.split("-")[1];
                      } else {
                        _musicAuthorController.text = "未知";
                        _musicNameController.text = musicName;
                      }
                    } else {
                      LogD("打开文件失败");
                      EasyLoading.showError("打开文件失败!");
                    }
                  });
                },
                child: const Text("点击选择文件")),
          ),
          TextFormField(
            controller: _musicNameController,
            keyboardType: TextInputType.text,
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            decoration: const InputDecoration(
              icon: Icon(Icons.people_sharp),
              labelText: "歌名",
              // hintText: "歌名",
            ),
          ),
          TextFormField(
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            controller: _musicAuthorController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              icon: Icon(Icons.people_sharp),
              labelText: "作者",
            ),
          ),
          Container(
              width: double.infinity,
              margin: const EdgeInsets.all(10),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () {
                          var tmp = _musicNameController.text;
                          _musicNameController.text =
                              _musicAuthorController.text;
                          _musicAuthorController.text = tmp;
                        },
                        icon: const Icon(
                          Icons_.upAndDownExchange,
                          color: Colors.blueAccent,
                        )),
                    TextButton(
                      style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue)),
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        switch (widget.type.name) {
                          case "add":
                            _addMusic();
                            break;
                          case "edit":
                            _putMusic();
                            break;
                          case "addFromYoutube":
                            _addMusicFromYoutube(widget.youtubeVideoId!);
                            break;
                        }
                      },
                      child: const Text("提交"),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Fluttertoast.showToast(
                            msg: "已取消",
                            gravity: ToastGravity.CENTER,
                          );
                        },
                        child: const Text("取消"))
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
