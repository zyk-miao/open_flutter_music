import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_app/common/function.dart';
import 'package:music_common/api/api.dart';
import 'package:music_common/entity/response_entity.dart';
import 'package:music_common/entity/tag.dart';
import 'package:music_common/utils/log.dart';

import '../global/g_state.dart';

class TagManagerPage extends StatefulWidget {
  const TagManagerPage({Key? key}) : super(key: key);

  @override
  State<TagManagerPage> createState() => _TagManagerPageState();
}

class _TagManagerPageState extends State<TagManagerPage> {
  final Set<String> selectedTagIds = {};
  List<Tag> tagList = Tag.copyList(gOboeIndexPageState.tagList);

  resetTagList() {
    tagList = Tag.copyList(gOboeIndexPageState.tagList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "取消",
              style: TextStyle(color: Colors.white),
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  final navigator = Navigator.of(context);
                  showDialog(
                      context: context,
                      builder: (BuildContext buildContext) {
                        return CupertinoAlertDialog(
                          title: Text("确认删除${selectedTagIds.length}个歌单?"),
                          actions: [
                            TextButton(
                              child: const Text("取消"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }, //关闭对话框
                            ),
                            TextButton(
                              child: const Text("删除"),
                              onPressed: () async {
                                ResponseEntity response =
                                    await delTags(selectedTagIds.toList());
                                if (response.code == '200') {
                                  await initTagList();
                                  setState(() {
                                    resetTagList();
                                  });
                                  navigator.pop();
                                  selectedTagIds.clear();
                                }
                                //关闭对话框
                              },
                            ),
                          ],
                        );
                      });
                },
                icon: const Icon(Icons.delete))
          ],
          title: const Text("管理歌单"),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Center(
              child: Text(
                "已选${selectedTagIds.length}个",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Expanded(
                child: SingleChildScrollView(
              child: DataTable(
                  columns: const [
                    DataColumn(label: Text("")),
                    DataColumn(label: Text("歌单"))
                  ],
                  rows: List<DataRow>.generate(tagList.length, (index) {
                    return DataRow(
                        cells: [
                          DataCell(tagList[index].coverImg != null
                              ? CachedNetworkImage(
                                  width: 100,
                                  height: 100,
                                  imageUrl: tagList[index].coverImg!,
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    "img/default.jpg",
                                    fit: BoxFit.fill,
                                  ),
                                )
                              : Image.asset(
                                  "img/default.jpg",
                                  fit: BoxFit.fill,
                                )),
                          DataCell(
                            ListTile(title: Text(tagList[index].tagName!)),
                          )
                        ],
                        onSelectChanged: (selected) {
                          setState(() {
                            if (selected!) {
                              selectedTagIds.add(tagList[index].id!);
                            } else {
                              selectedTagIds.remove(tagList[index].id!);
                            }
                            tagList[index].selected = selected;
                          });
                        },
                        selected: tagList[index].selected);
                  })),
            ))
          ],
        ));
  }
}
