import 'package:contextmenu/contextmenu.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide MenuBar hide MenuStyle;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:menu_bar/menu_bar.dart';
import 'package:music_common/api/api.dart';
import 'package:music_common/api/request.dart';
import 'package:music_common/entity/music.dart';
import 'package:music_common/entity/response_entity.dart';
import 'package:music_common/entity/tag.dart';
import '../Icons/Icons.dart';
import '../common/function.dart';
import '../common/j_play_control_panel.dart';
import '../common/music_add_form.dart';
import '../common/tag_form.dart';
import '../global/g_state.dart';
import '../player/j_player.dart';

initMusicList(Tag tag) async {
  List<Music> list = await getMusicListByTag(tag);
  gOboeMusicsState.update(tag, list);
}

class IndexPage extends StatelessWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    initTagList();
    // gOboeMusicsState.tag
    initMusicList(Tag(tagName: "全部", id: "all"));
    return MenuBar(
        barStyle: const BarStyle(backgroundColor: Colors.white),
        barButtons: [
          BarButton(
              text: const Text("菜单"),
              submenu: SubMenu(
                menuItems: [
                  MenuButton(
                    text: const Text('添加歌单'),
                    onTap: () {
                      SmartDialog.show(builder: (BuildContext context) {
                        return const SimpleDialog(
                          children: [
                            SingleChildScrollView(
                              child: TagForm(),
                            )
                          ],
                        );
                      });
                    },
                    // icon: const Icon(Icons.save),
                  ),
                  MenuButton(
                    text: const Text('上传音乐'),
                    onTap: () {
                      SmartDialog.show(builder: (BuildContext context) {
                        return const SimpleDialog(
                          children: [
                            SingleChildScrollView(
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: MusicAddForm(),
                              ),
                            )
                          ],
                        );
                      });
                    },
                  ),
                  MenuButton(
                    text: const Text('搜索歌曲'),
                    onTap: () {
                      Navigator.pushNamed(context, "/searchFromYoutube");
                    },
                    // icon: const Icon(Icons.save),
                  ),
                ],
              ))
        ],
        child: Column(
          children: [
            Expanded(
                flex: 17,
                child: Row(
                  children: const [
                    Expanded(
                      flex: 2,
                      child: LeftPanel(),
                    ),
                    Expanded(
                      flex: 8,
                      child: IndexBody(),
                    )
                  ],
                )),
            const Expanded(
              flex: 3,
              // child: PlayControlPanel(),
              child: JPlayControlPanel(),
            )
          ],
        ));
  }
}

class LeftPanel extends StatelessWidget {
  const LeftPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: gOboeTagsState.ob(() => ListView.builder(
                    itemCount: gOboeTagsState.tagList.length,
                    itemBuilder: (BuildContext context, int index) {
                      var content = ListTile(
                        tileColor: gOboeTagsState.tagList[index].selected
                            ? Colors.lightBlue
                            : Colors.white,
                        onTap: () async {
                          initMusicList(gOboeTagsState.tagList[index]);
                          for (int i = 0;
                              i < gOboeTagsState.tagList.length;
                              i++) {
                            gOboeTagsState.tagList[i].selected = false;
                          }
                          gOboeTagsState.tagList[index].selected = true;
                          gOboeTagsState.next();
                        },
                        title: Row(
                          children: [
                            Text("${gOboeTagsState.tagList[index].tagName}"),
                          ],
                        ),
                      );
                      if (gOboeTagsState.tagList[index].id == null) {
                        return content;
                      }
                      return ContextMenuArea(
                          child: content,
                          builder: (context) => [
                                ListTile(
                                    title: const Text("编辑"),
                                    onTap: () async {
                                      SmartDialog.show(
                                          builder: (BuildContext context) {
                                        return SimpleDialog(
                                          children: [
                                            SingleChildScrollView(
                                              child: TagForm(
                                                  tag: gOboeTagsState
                                                      .tagList[index]),
                                            )
                                          ],
                                        );
                                      });
                                      Navigator.pop(context);
                                    }),
                                ListTile(
                                  onTap: () async {
                                    final navigator = Navigator.of(context);
                                    ResponseEntity response = await delTag(
                                        gOboeTagsState.tagList[index].id!);
                                    if (response.code == '200') {
                                      await initTagList();
                                      navigator.pop();
                                    }
                                  },
                                  title: const Text("删除"),
                                )
                              ]);
                    },
                  )))
        ],
      ),
    );
  }
}

class IndexBody extends StatelessWidget {
  const IndexBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: gOboeMusicsState.ob(() => Column(
            children: [
              Row(
                children: [
                  Center(
                    child: Text(
                        "${gOboeMusicsState.tag.tagName} (${gOboeMusicsState.musicList.length})"),
                  )
                ],
              ),
              Expanded(
                  child: ListView.builder(
                itemCount: gOboeMusicsState.musicList.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onDoubleTap: () async {
                      await JPlayer.playByIndex(
                          gOboeMusicsState.musicList, index);
                    },
                    child: ContextMenuArea(
                      builder: (context) => [
                        ListTile(
                          title: const Text('播放'),
                          onTap: () async {
                            final navigator = Navigator.of(context);
                            await JPlayer.playByIndex(
                                gOboeMusicsState.musicList, index);
                            navigator.pop();
                          },
                        ),
                        ListTile(
                          title: const Text('编辑'),
                          onTap: () {
                            SmartDialog.show(builder: (BuildContext context) {
                              return SimpleDialog(
                                children: [
                                  SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: MusicAddForm(
                                        type: MusicAddFormType.edit,
                                        music:
                                            gOboeMusicsState.musicList[index],
                                      ),
                                    ),
                                  )
                                ],
                              );
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                        Offstage(
                          offstage: gOboeMusicsState.tag.id != "all",
                          child: ListTile(
                            title: const Text('删除'),
                            onTap: () async {
                              final navigator = Navigator.of(context);
                              ResponseEntity response = await delMusics(
                                  gOboeMusicsState.musicList[index]);
                              if (response.code == "200") {
                                initMusicList(gOboeMusicsState.tag);
                                initTagList();
                                navigator.pop();
                              }
                            },
                          ),
                        ),
                        Offstage(
                          offstage:
                              ['all', 'love'].contains(gOboeMusicsState.tag.id),
                          child: ListTile(
                            title: const Text('移除'),
                            onTap: () async {
                              final navigator = Navigator.of(context);
                              ResponseEntity response = await removeMusics(
                                  [gOboeMusicsState.musicList[index].id!],
                                  gOboeMusicsState.tag);
                              if (response.code == "200") {
                                initMusicList(gOboeMusicsState.tag);
                                initTagList();
                                navigator.pop();
                              }
                            },
                          ),
                        ),
                      ],
                      child: Card(
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 20),
                              child: Text(
                                "${gOboeMusicsState.musicList[index].index}",
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            IconButton(
                              icon: const Icon(Icons.download_outlined),
                              onPressed: () async {
                                String? outputFile =
                                    await FilePicker.platform.saveFile(
                                  dialogTitle: 'Please select an output file:',
                                  fileName:
                                      '${gOboeMusicsState.musicList[index].fileName}',
                                );
                                if (outputFile != null) {
                                  downloadFile(
                                      gOboeMusicsState
                                          .musicList[index].musicUrl,
                                      outputFile);
                                }
                              },
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            IconButton(
                                onPressed: () async {
                                  ResponseEntity response;
                                  if (gOboeMusicsState
                                      .musicList[index].ifLove) {
                                    response = await cancelLoveMusic(
                                        gOboeMusicsState.musicList[index].id);
                                  } else {
                                    response = await addLoveMusic(
                                        gOboeMusicsState.musicList[index].id);
                                  }
                                  if (response.code == "200") {
                                    initMusicList(gOboeMusicsState.tag);
                                  }
                                },
                                icon: gOboeMusicsState.musicList[index].ifLove
                                    ? const Icon(
                                        Icons_.love2,
                                        color: Colors.red,
                                      )
                                    : const Icon(Icons_.love)),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                                '${gOboeMusicsState.musicList[index].musicName}  -  ${gOboeMusicsState.musicList[index].artistName}')
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ))
            ],
          )),
    );
  }
}
