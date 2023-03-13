import 'package:just_audio/just_audio.dart';
import 'package:music_common/api/api.dart';
import 'package:music_common/entity/music.dart';
import 'package:music_common/entity/response_entity.dart';
import 'package:music_common/entity/tag.dart';
import 'package:music_common/utils/log.dart';

import '../global/g_state.dart';

bool equalsStringAndMusic(List<Music>? list1, List<Music>? list2) {
  if (list1 == null || list2 == null || list1.length != list2.length) {
    return false;
  } else {
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].musicUrl != list2[i].musicUrl!) {
        return false;
      }
    }
  }
  return true;
}

bool needUpdateMusicList(
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

initTagList() async {
  ResponseEntity responseEntity = await getTagList();
  List<Tag> list =
      List<Tag>.from((responseEntity.data as List<dynamic>).map((item) {
    var tag = Tag.fromJson(item);
    if (tag.id == gOboeMusicsState.tag.id) {
      tag.selected == true;
    }
    return tag;
  }));
  list.insert(0, Tag(tagName: "喜欢",id: 'love'));
  list.insert(0, Tag(tagName: "全部",id: 'all'));
  gOboeTagsState.updateOboeTagList(list);
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