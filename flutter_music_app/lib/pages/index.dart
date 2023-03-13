import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_app/common/components/play_bottom_control.dart';
import 'package:flutter_music_app/global/g_state.dart';
import 'package:easy_refresh_flutter3/easy_refresh_flutter3.dart';
import 'package:path_provider/path_provider.dart';
import '../Icons/Icons.dart';
import '../common/components/image_button.dart';
import '../common/components/music_add_form.dart';
import '../common/components/tag_form.dart';
import '../common/components/text_icon_button.dart';
import '../common/function.dart';
import 'package:music_common/utils/log.dart';
import 'package:music_common/entity/tag.dart';

DateTime? _lastPopTime;

_indexPageToMusicPage(Tag tag, BuildContext context) async {
  final navigator = Navigator.of(context);
  await initMusicListAndTag(tag);
  navigator.pushNamed("/music/list");
}

class IndexPage extends StatelessWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterButtons: const [PlayBottomControl()],
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            "我的",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          )),
      body: WillPopScope(
          onWillPop: () async {
            LogD(_lastPopTime);
            LogD(DateTime.now());
            if (_lastPopTime == null ||
                DateTime.now().difference(_lastPopTime!) >
                    const Duration(seconds: 2)) {
              _lastPopTime = DateTime.now();
              // Fluttertoast.showToast(msg: '请再按一次返回');
            } else {
              _lastPopTime = DateTime.now();
              Navigator.pushReplacementNamed(context, "/login");
            }
            return false;
          },
          child: Column(
            children: const [
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal, child: MenuWidget()),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: IndexBody(),
              )
            ],
          )),
    );
  }
}

class MenuWidget extends StatelessWidget {
  const MenuWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextIconButton(
            icon: const Icon(Icons_.all),
            onPressed: () async {
              // gOboeMusicPageState.updateOboeTag(Tag(id: null, tagName: "全部"));
              // initMusicList();
              await _indexPageToMusicPage(
                  Tag(id: null, tagName: "全部"), context);
            },
            text: const Text("曲库")),
        TextIconButton(
            icon: const Icon(Icons_.youtube),
            onPressed: () {
                Navigator.of(context).pushNamed("/audio_player");
            },
            text: const Text("搜索")),
        TextIconButton(
            icon: const Icon(Icons.ac_unit_outlined),
            onPressed: () {},
            text: const Text("下载")),
        TextIconButton(
            icon: const Icon(Icons.ac_unit_outlined),
            onPressed: () async {
              showDialog(
                  context: context,
                  builder: (BuildContext buildContext) {
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
            text: const Text("上传")),
        TextIconButton(
            icon: const Icon(Icons.ac_unit_outlined),
            onPressed: () async {
              await _indexPageToMusicPage(
                  Tag(id: null, tagName: "喜欢"), context);
            },
            text: const Text("喜欢")),
      ],
    );
  }
}

class IndexBody extends StatelessWidget {
  const IndexBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
        onRefresh: () {
          initTagList();
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0.0, 15.0), //阴影xy轴偏移量
                  blurRadius: 15.0, //阴影模糊程度
                  spreadRadius: 10.0 //阴影扩散程度
                  )
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        "歌单 ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      gOboeIndexPageState.ob(() => Text(
                            "(${gOboeIndexPageState.tagList.length})",
                            style: const TextStyle(
                                fontWeight: FontWeight.w300, fontSize: 20),
                          )),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext buildContext) {
                                  return const SimpleDialog(
                                    children: [
                                      SingleChildScrollView(
                                        child: TagForm(),
                                      )
                                    ],
                                  );
                                });
                          },
                          icon: const Icon(Icons.add)),
                      IconButton(
                          onPressed: () {
                            LogD("点击管理歌单");
                            Navigator.pushNamed(context, "/tag/manager",
                                arguments: gOboeIndexPageState.tagList);
                          },
                          icon: const Icon(Icons.settings)),
                    ],
                  )
                ],
              ),
              const Expanded(
                child: TagsGrid(),
              )
            ],
          ),
        ));
  }
}

class TagsGrid extends StatelessWidget {
  const TagsGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    initTagList();
    return gOboeIndexPageState.ob(() => GridView(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 5, mainAxisSpacing: 5),
        children: List.generate(gOboeIndexPageState.tagList.length, (index) {
          return ImageButton(
            Text(
              "${gOboeIndexPageState.tagList[index].tagName}(${gOboeIndexPageState.tagList[index].num})",
            ),
            img: (gOboeIndexPageState.tagList[index].coverImg == null ||
                    gOboeIndexPageState.tagList[index].coverImg == "")
                ? Image.asset(
                    'img/default.jpg',
                    fit: BoxFit.fill,
                  )
                : CachedNetworkImage(
                    fit: BoxFit.fill,
                    imageUrl: gOboeIndexPageState.tagList[index].coverImg!,
                    errorWidget: (context, url, error) => Image.asset(
                      "img/default.jpg",
                      fit: BoxFit.fill,
                    ),
                  ),
            // imgSrc: tagList[index].coverImg,
            onPressed: () async {
              await _indexPageToMusicPage(
                  gOboeIndexPageState.tagList[index], context);
            },
            onLongPress: () {
              showDialog(
                  context: context,
                  builder: (BuildContext buildContext) {
                    return SimpleDialog(
                      children: [
                        SingleChildScrollView(
                          child:
                              TagForm(tag: gOboeIndexPageState.tagList[index]),
                        )
                      ],
                    );
                  });
              // showDialog(
              //     context: context,
              //     builder: (BuildContext buildContext) {
              //       return CupertinoAlertDialog(
              //         title: Text("是否删除${gOboeTagList.tagList[index].tagName}"),
              //         actions: [
              //           TextButton(
              //             child: const Text("取消"),
              //             onPressed: () => Navigator.of(context).pop(), //关闭对话框
              //           ),
              //           TextButton(
              //             child: const Text("删除"),
              //             onPressed: () async {
              //               ResponseEntity response =
              //                   await delTag(gOboeTagList.tagList[index].id!);
              //               if (response.code == '200') {
              //                 initTagList();
              //                 navigator.pop();
              //               }
              //               //关闭对话框
              //             },
              //           ),
              //         ],
              //       );
              //     });
            },
          );
        })));
  }
}
