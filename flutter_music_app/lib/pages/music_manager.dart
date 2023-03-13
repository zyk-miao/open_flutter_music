import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_app/common/function.dart';
import 'package:flutter_music_app/global/g_state.dart';

import 'package:music_common/api/api.dart';
import 'package:music_common/entity/music.dart';
import 'package:music_common/entity/response_entity.dart';
import 'package:music_common/entity/tag.dart';

import '../common/components/text_icon_button.dart';
import 'music.dart';

class MusicManagerPage extends StatefulWidget {
  const MusicManagerPage({Key? key}) : super(key: key);

  @override
  State<MusicManagerPage> createState() => _MusicManagerPageState();
}

class _MusicManagerPageState extends State<MusicManagerPage> {
  List<Music> musicList = gOboeMusicPageState.musicList;
  Tag tag = gOboeMusicPageState.tag;

  @override
  void initState() {
    super.initState();
  }

  Set<String> selectedMusicIds = {};

  _refreshMusicList() async {
    ResponseEntity response = await selectMusicList(tag);
    setState(() {
      musicList = List<Music>.from(
          (response.data['dataList'] as List<dynamic>).map((e) {
        return Music.fromJson(e);
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        persistentFooterAlignment: AlignmentDirectional.bottomCenter,
        persistentFooterButtons: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextIconButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return MusicAddToTagWidget(
                            musicIds: selectedMusicIds.toList());
                      }));
                    },
                    text: const Text('添加到'),
                    icon: const Icon(Icons.add),
                  ),
                  TextIconButton(
                    onPressed: () {},
                    text: const Text('下载'),
                    icon: const Icon(Icons.download_rounded),
                  ),
                  TextIconButton(
                    style: tag.id == null
                        ? ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all(Colors.grey))
                        : const ButtonStyle(),
                    onPressed: () {
                      if (tag.id != null) {
                        final navigator = Navigator.of(context);
                        showDialog(
                            context: context,
                            builder: (BuildContext buildContext) {
                              return CupertinoAlertDialog(
                                title: Text(
                                    "确认从${tag.tagName}中移除${selectedMusicIds.length}个音乐?"),
                                actions: [
                                  TextButton(
                                    child: const Text("取消"),
                                    onPressed: () {
                                      Navigator.of(context).pop("updateState");
                                    }, //关闭对话框
                                  ),
                                  TextButton(
                                    child: const Text("移除"),
                                    onPressed: () async {
                                      ResponseEntity response =
                                          await removeMusics(
                                              selectedMusicIds.toList(), tag);
                                      if (response.code == '200') {
                                        _refreshMusicList();
                                        initTagList();
                                        initMusicList();
                                        selectedMusicIds.clear();
                                        navigator.pop();
                                      }
                                      //关闭对话框
                                    },
                                  ),
                                ],
                              );
                            });
                      }
                      ;
                    },
                    text: const Text('移除'),
                    icon: const Icon(Icons.delete_forever),
                  ),
                ]),
          )
        ],
        appBar: AppBar(
          leading: TextButton(
            onPressed: () {
              Navigator.of(context).pop("updateState");
            },
            child: const Text(
              "取消",
              style: TextStyle(color: Colors.white),
            ),
          ),
          title: Text("${tag.tagName}"),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Center(
              child: Text(
                "已选${selectedMusicIds.length}个",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Expanded(
                child: SingleChildScrollView(
              child: DataTable(
                  columns: const [DataColumn(label: Text("音乐"))],
                  rows: List<DataRow>.generate(musicList.length, (index) {
                    return DataRow(
                        cells: [
                          DataCell(
                            ListTile(title: Text(musicList[index].musicName!)),
                          )
                        ],
                        onSelectChanged: (selected) {
                          setState(() {
                            if (selected!) {
                              selectedMusicIds.add(musicList[index].id!);
                            } else {
                              selectedMusicIds.remove(musicList[index].id!);
                            }
                            musicList[index].selected = selected;
                          });
                        },
                        selected: musicList[index].selected);
                  })),
            ))
          ],
        ));
  }
}
