import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_app/common/components/play_bottom_control.dart';
import 'package:flutter_music_app/global/g_state.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:music_common/api/api.dart';
import 'package:music_common/entity/music.dart';
import 'package:music_common/entity/response_entity.dart';
import 'package:music_common/entity/tag.dart';
import 'package:music_common/utils/log.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:text_scroll/text_scroll.dart';

import '../Icons/Icons.dart';
import '../common/components/music_add_form.dart';
import '../common/function.dart';
import '../player/player.dart';

SliverObserverController? observerController;
final GlobalKey appBarKey = GlobalKey();
final GlobalKey persistentHeaderKey = GlobalKey();

class MusicPage extends StatelessWidget {
  MusicPage({Key? key}) : super(key: key);
  final ScrollController _controller = ScrollController();
  final Tag tag = gOboeMusicPageState.tag;

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((d){
    //   LogE(d);
    //   updatePlaying();
    // });
    observerController = SliverObserverController(controller: _controller);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        foregroundColor: const Color.fromRGBO(255, 255, 255, 0.5),
        backgroundColor:  const Color.fromRGBO(240, 255, 255, 0.5),
        onPressed: () {
          jumpToPlaying();
        },
        mini: true,
        child: const Icon(Icons.location_searching),
      ),
      persistentFooterButtons: const [PlayBottomControl()],
      body: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white54,
          ),
          child: SliverViewObserver(
            controller: observerController,
            // leadingOffset:40,
            child: CustomScrollView(
              controller: _controller,
              slivers: [
                SliverAppBar(
                  key: appBarKey,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  pinned: true,
                  expandedHeight: 200,
                  flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text(tag.tagName!
                          // (ModalRoute.of(context)?.settings.arguments as Tag)
                          //     .tagName!
                          ),
                      background: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: (tag.coverImg == null || tag.coverImg == "")
                            ? Image.asset(
                                'img/default.jpg',
                                fit: BoxFit.fill,
                              )
                            : CachedNetworkImage(
                                fit: BoxFit.fill,
                                imageUrl: tag.coverImg!,
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  "img/default.jpg",
                                  fit: BoxFit.fill,
                                ),
                              ),
                      )),
                ),
                SliverPersistentHeader(
                  key: persistentHeaderKey,
                  pinned: true,
                  delegate: SliverMusicMenu(),
                ),
                gOboeMusicPageState.ob(() => SliverList(
                        delegate: SliverChildBuilderDelegate(
                            childCount: gOboeMusicPageState.musicList.length,
                            (context, index) {
                      return TextButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith((states) {
                              if (gOboeMusicPageState
                                  .musicList[index].playing) {
                                return Colors.lightBlueAccent;
                              }
                            }),
                          ),
                          onPressed: () async {
                            gOboePlayState.updateTag(tag);
                            await Player.playByIndex(
                                gOboeMusicPageState.musicList, index);
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: Row(
                                  children: [
                                    Container(
                                      constraints:
                                          const BoxConstraints(minWidth: 20),
                                      child: Text(
                                        "${gOboeMusicPageState.musicList[index].index}",
                                        maxLines: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    IconButton(
                                        onPressed: () async {
                                          ResponseEntity response;
                                          if (gOboeMusicPageState
                                              .musicList[index].ifLove) {
                                            response = await cancelLoveMusic(
                                                gOboeMusicPageState
                                                    .musicList[index].id);
                                          } else {
                                            response = await addLoveMusic(
                                                gOboeMusicPageState
                                                    .musicList[index].id);
                                          }
                                          if (response.code == "200") {
                                            initMusicList();
                                          }
                                        },
                                        icon: gOboeMusicPageState
                                                .musicList[index].ifLove
                                            ? const Icon(
                                                Icons_.love2,
                                                color: Colors.red,
                                              )
                                            : const Icon(Icons_.love)),
                                    const SizedBox(width: 5),
                                    Expanded(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextScroll(
                                          "${gOboeMusicPageState.musicList[index].musicName}",
                                          mode: TextScrollMode.bouncing,
                                          velocity: const Velocity(
                                              pixelsPerSecond: Offset(25, 0)),
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        Text(
                                          "${gOboeMusicPageState.musicList[index].artistName}",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ],
                                    )),
                                  ],
                                )),
                                IconButton(
                                    onPressed: () {
                                      showCupertinoModalBottomSheet(
                                        expand: false,
                                        context: context,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) => MusicRowMoreMenu(
                                          music: gOboeMusicPageState
                                              .musicList[index],
                                          tag: tag,
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.more_vert)),
                              ],
                            ),
                          ));
                    }))),
              ],
            ),
          )),
    );
  }
}

class SliverMusicMenu extends SliverPersistentHeaderDelegate {
  final TextEditingController textEditingController = TextEditingController();

  // SliverMusicMenu();

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12,
                offset: Offset(0.0, 2.0), //阴影xy轴偏移量
                blurRadius: 15.0, //阴影模糊程度
                spreadRadius: 5.0 //阴影扩散程度
                )
          ]),
      height: 50,
      // width: double.maxFinite,
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Container(
            margin: const EdgeInsets.only(left: 10),
            child: TextField(
              onSubmitted: (value) {
                print(value);
                // _search(value);
              },
              onChanged: (value) {
                //todo
                // musicPageKey.currentState!.search(value);
              },
              controller: textEditingController,
              decoration: InputDecoration(
                  hintText: "搜索",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      // var value = textEditingController.text;
                      // _search(value);
                      //todo
                      textEditingController.clear();
                      //   musicPageKey.currentState!
                      //       .search(textEditingController.text);
                    },
                  )),
            ),
          )),
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, "/music/manager").then((value) {});
              },
              icon: const Icon(Icons_.multiselect))
        ],
      ),
    );
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class MusicRowMoreMenu extends StatelessWidget {
  const MusicRowMoreMenu({required this.music, required this.tag, Key? key})
      : super(key: key);
  final Music music;
  final Tag tag;

  @override
  Widget build(BuildContext context) {
    NavigatorState navigatorState = Navigator.of(context);
    return Material(
        child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: const Text('添加到歌单'),
            leading: const Icon(Icons.add_box_rounded),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return MusicAddToTagWidget(musicId: music.id!);
              }));
            },
          ),
          ListTile(
            title: const Text('下载'),
            leading: const Icon(Icons.download_outlined),
            onTap: () {
              downloadMusic(music, success: () {
                createNormalMsg("${music.musicName}下载成功");
              }, fail: () {
                createNormalMsg("${music.musicName}下载失败");
              });
              navigatorState.pop();
            },
          ),
          ListTile(
            title: const Text("编辑"),
            leading: const Icon(Icons.edit),
            onTap: () async {
              showDialog(
                  context: context,
                  builder: (BuildContext buildContext) {
                    return SimpleDialog(
                      children: [
                        SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: MusicAddForm(
                              type:MusicAddFormType.edit,
                              music: music,
                            ),
                          ),
                        )
                      ],
                    );
                  });
            },
          ),
          Offstage(
            offstage: tag.id == null,
            child: ListTile(
              title: const Text('移除'),
              leading: const Icon(Icons.delete),
              onTap: () async {
                ResponseEntity response = await removeMusics([music.id!], tag);
                if (response.code == "200") {
                  initMusicList();
                  initTagList();
                  navigatorState.pop();
                }
              },
            ),
          ),
          Offstage(
            offstage: tag.tagName != "全部",
            child: ListTile(
              title: const Text('删除'),
              leading: const Icon(Icons.delete),
              onTap: () async {
                ResponseEntity response = await delMusics(music);
                if (response.code == "200") {
                  initMusicList();
                  initTagList();
                  navigatorState.pop();
                }
              },
            ),
          ),
          ListTile(
            title: const Text('取消'),
            leading: const Icon(Icons.close_outlined),
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    ));
  }
}

class MusicAddToTagWidget extends StatefulWidget {
  const MusicAddToTagWidget({this.musicId, this.musicIds = const [], Key? key})
      : super(key: key);
  final String? musicId;
  final List<String>? musicIds;

  @override
  State<MusicAddToTagWidget> createState() => _MusicAddToTagWidgetState();
}

class _MusicAddToTagWidgetState extends State<MusicAddToTagWidget> {
  List<Tag> tagList = [];
  Set<String> selectedTagIds = {};

  _getTagList() async {
    ResponseEntity response;
    if (widget.musicIds!.isEmpty) {
      response = await getTagListWithFlag(widget.musicId);
    } else {
      response = await getTagList();
    }
    initTagList();
    setState(() {
      tagList = List<Tag>.from(
          (response.data as List<dynamic>).map((e) => Tag.fromJson(e)));
    });
  }

  @override
  void initState() {
    super.initState();
    _getTagList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("添加到歌单"),
        centerTitle: true,
        leading: TextButton(
          child: const Text(
            "取消",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.of(context)
              ..pop()
              ..pop();
          },
        ),
        actions: [
          IconButton(
              onPressed: () async {
                ResponseEntity response;
                response = await addMusicsToTags(selectedTagIds.toList(),
                    musicId: widget.musicId, musicIds: widget.musicIds);
                if (response.code == '200') {
                  initTagList();
                  _getTagList();
                }
              },
              icon: const Icon(Icons.save))
        ],
      ),
      body: Column(
        children: [
          Center(
            child: Text(
              "已选${selectedTagIds.length}个",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            child: DataTable(
              columns: const [DataColumn(label: Text("歌单"))],
              rows: List<DataRow>.generate(tagList.length, (index) {
                return DataRow(
                    selected: tagList[index].selected,
                    onSelectChanged: tagList[index].flag!
                        ? null
                        : (selected) {
                            setState(() {
                              if (selected!) {
                                selectedTagIds.add(tagList[index].id!);
                              } else {
                                selectedTagIds.remove(tagList[index].id!);
                              }
                              tagList[index].selected = selected;
                            });
                          },
                    cells: [
                      DataCell(ListTile(
                        title: Text(
                          "${tagList[index].tagName}(${tagList[index].num})",
                          style: TextStyle(
                              color: tagList[index].flag!
                                  ? Colors.black12
                                  : Colors.black),
                        ),
                      ))
                    ]);
              }),
            ),
          ))
        ],
      ),
    );
  }
}
