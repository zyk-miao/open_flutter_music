import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_music_app/global/g_variable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_common/api/api.dart';
import 'package:music_common/api/request.dart';
import 'package:music_common/entity/music.dart';
import 'package:music_common/entity/response_entity.dart';
import 'package:music_common/entity/tag.dart';
import 'package:music_common/utils/log.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../global/g_state.dart';
import '../pages/music.dart';
import '../player/player.dart';


initTagList() async {
  ResponseEntity responseEntity = await getTagList();
  List<Tag> list =
      List<Tag>.from((responseEntity.data as List<dynamic>).map((item) {
    return Tag.fromJson(item);
  }));
  gOboeIndexPageState.updateOboeTagList(list);
}

getMusicListByTag(Tag tag) async {
  ResponseEntity response;
  if ("喜欢" == tag.tagName) {
    response = await selectLoveMusic();
  } else {
    response = await selectMusicList(tag);
  }
  var list =
      List<Music>.from((response.data['dataList'] as List<dynamic>).map((e) {
    return Music.fromJson(e);
  }));
  return list;
}

initMusicList() async {
  var list = await getMusicListByTag(gOboeMusicPageState.tag);
  gOboeMusicPageState.updateOboeMusicList(list);
  // search(textEditingController.text);
}

jumpToPlaying() {
  var index = Player.getCurrentIndex();
  if (observerController != null && index != null) {
    observerController!.animateTo(
      index: index,
      offset: (offset) {
        // The height of the SliverAppBar is calculated base on target offset and is returned in the current callback.
        // The observerController internally adjusts the appropriate offset based on the return value.
        return ObserverUtils.calcPersistentHeaderExtent(
              key: appBarKey,
              offset: offset,
            ) +
            ObserverUtils.calcPersistentHeaderExtent(
              key: persistentHeaderKey,
              offset: offset,
            ) +
            gHeight * 0.2;
        ;
      },
      duration: const Duration(milliseconds: 1000),
      curve: Curves.ease,
    );
  }
}

updatePlaying({bool notify = true}) {
  for (int i = 0; i < gOboeMusicPageState.musicList.length; i++) {
    if (gOboeMusicPageState.musicList[i].id == gOboePlayState.playingMusic.id) {
      gOboeMusicPageState.musicList[i].playing = true;
    } else {
      gOboeMusicPageState.musicList[i].playing = false;
    }
  }
  // jumpToPlaying();
  if (notify) {
    gOboeMusicPageState.next();
  }
}

initMusicListAndTag(Tag tag) async {
  var list = await getMusicListByTag(tag);
  gOboeMusicPageState.update(tag, list);
}

searchLyric() async {
  // int? index = Player.getCurrentIndex();
  // if (index != null) {
  //   var result =
  //       await NeteaseApi.cloudsearch(gOboePlayState.playingMusic.musicName!);
  //   int songCount = result['result']['songCount'] ?? 0;
  //   if (songCount > 0) {
  //     List<Map> songs = List<Map>.from(result['result']['songs']);
  //     String songLyc = (await NeteaseApi.lyric(songs[0]["id"]))['lrc']['lyric'];
  //     return songLyc;
  //   }
  // }
  return "ttt";
}

createNormalMsg(msg) {
  AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: Random().nextInt(pow(2, 16).toInt()),
          channelKey: "normal_msg",
          body: msg,
          autoDismissible: true));
}

downloadMusic(Music music, {VoidCallback? success, VoidCallback? fail}) async {
  var directory = await getExternalStorageDirectory();
  LogD("下载地址：${music.musicUrl} ");
  LogD("保存地址：${directory!.path}/${music.fileName!} ");
  downloadFile(music.musicUrl, "${directory.path}/${music.fileName!}",
      success: success, fail: fail);
}

bool equalsStringAndMusic(
    List<Music>? list1, List<LockCachingAudioSource>? list2) {
  if (list1 == null || list2 == null || list1.length != list2.length) {
    return false;
  } else {
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].musicUrl != list2[i].uri.toString()) {
        return false;
      }
    }
  }
  return true;
}
