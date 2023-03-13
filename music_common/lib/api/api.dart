import 'package:dio/dio.dart';
import 'package:music_common/api/request.dart';

import '../entity/music.dart';
import '../entity/tag.dart';
import '../utils/log.dart';

login(username, password) async {
  return await postAction("login",
      data: {"username": username, "password": password});
}

getTagList() async {
  return await postAction("selectTagList");
}

getTagListWithFlag(musicId) async {
  return await getAction("selectTagListWithFlag", params: {"id": musicId});
}

addTag(Tag tag, {FormData? formData}) async {
  return postAction("addTag", data: formData, params: {
    'tagName': tag.tagName,
  });
}

delTags(List<String> list) async {
  return await postAction("delTags", data: list);
}

putTag(Tag tag, {String? filePath}) async {
  var formData = FormData.fromMap({
    'file': filePath == null ? null : await MultipartFile.fromFile(filePath),
  });
  return await postAction("putTag",
      data: formData, params: {'tagName': tag.tagName, 'id': tag.id});
}

delTag(String tagId) async {
  return postAction('delTag', params: {'tagId': tagId});
}

addLoveMusic(musicId) async {
  return await postAction(
    "addLoveMusic",
    data: [musicId],
  );
}

cancelLoveMusic(musicId) async {
  return await delAction(
    "cancelLoveMusic",
    params: {"musicId": musicId},
  );
}

removeMusics(List<String> musicIds, Tag tag) async {
  return await postAction(
    "removeMusics",
    data: musicIds,
    params: {"tagId": tag.id},
  );
}

delMusics(Music music) async {
  return await postAction(
    "delMusic",
    params: {"musicId": music.id},
  );
}

selectLoveMusic() async {
  return await getAction('selectLoveList');
}

selectMusicList(Tag tag) async {
  return await postAction('selectMusicList', params: {"tagId": tag.id});
}

addMusicsToTags(List<String> tagIds,
    {String? musicId, List<String>? musicIds}) async {
  return await postAction(
    "addMusicsToTags",
    params: {
      'tagIds': tagIds.toList(),
    },
    data: musicId == null ? musicIds : [musicId],
  );
}

putMusic(Music music) async {
  return await postAction('editMusic', data: music);
}

addMusic(String filePath, Music music) async {
  var formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(filePath),
  });
  return await sendRequest('addMusic',
      method: METHOD.post.name,
      data: formData,
      contentType: Headers.multipartFormDataContentType,
      params: {'musicName': music.musicName, "artistName": music.artistName},
      receiveTimeout: const Duration(minutes: 3));
}

searchFromYoutube(String key) async {
  return await getAction("searchVideoFromYoutube", params: {"key": key});
}

addMusicFromYoutube(Music music, videoId) async {
  return await postAction("addMusicFromYoutube",
      params: {"videoId": videoId}, data: music);
}
