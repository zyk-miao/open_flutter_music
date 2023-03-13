import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_app/common/function.dart';
import 'package:flutter_music_app/config/config_request.dart';
import 'package:music_common/api/api.dart';
import 'package:music_common/entity/YoutubeVideo.dart';
import 'package:music_common/entity/music.dart';
import 'package:music_common/entity/response_entity.dart';
import 'package:music_common/utils/function.dart';
import 'package:music_common/utils/log.dart';

import '../common/components/music_add_form.dart';
import '../global/g_state.dart';

class AudioPlayerPage extends StatefulWidget {
  const AudioPlayerPage({Key? key}) : super(key: key);

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  final TextEditingController textEditingController = TextEditingController();
  final assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (!const bool.fromEnvironment('dart.vm.product')) {
      textEditingController.text = "烟花易冷";
      _search();
    }
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    assetsAudioPlayer.dispose();
  }

  @override
  dispose() {
    super.dispose();
    assetsAudioPlayer.dispose();
  }

  _search() async {
    ResponseEntity response =
        await searchFromYoutube(textEditingController.text);
    List<YoutubeVideo> list = List.from(
        (response.data as List<dynamic>).map((e) => YoutubeVideo.fromJson(e)));
    gOboeAudioState.updateVideoList(list);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
            child: TextField(
              controller: textEditingController,
              decoration: InputDecoration(
                  hintText: "搜索",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      _search();
                    },
                  )),
            ),
          ),
          Expanded(
              child: gOboeAudioState.ob(() => ListView.builder(
                  itemCount: gOboeAudioState.videoList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                        selected: gOboeAudioState.videoList[index].selected,
                        selectedColor: Colors.lightBlueAccent,
                        trailing: IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext buildContext) {
                                  return SimpleDialog(
                                    children: [
                                      SingleChildScrollView(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: MusicAddForm(
                                            music: Music(
                                                musicName: gOboeAudioState
                                                    .videoList[index].title),
                                            type:
                                                MusicAddFormType.addFromYoutube,
                                            youtubeVideoId: gOboeAudioState
                                                .videoList[index].videoId,
                                          ),
                                        ),
                                      )
                                    ],
                                  );
                                });
                          },
                          icon: const Icon(Icons.add),
                        ),
                        dense: true,
                        onTap: () async {
                          gOboeAudioState.changeSelected(index);
                          await assetsAudioPlayer.open(
                              Audio.network(
                                  "${baseUrl}playMusicFromYoutube?youtubeVideoId=${gOboeAudioState.videoList[index].videoId}"),
                              playInBackground: PlayInBackground.disabledPause);
                          assetsAudioPlayer.play();
                        },
                        title: Text(
                            "${gOboeAudioState.videoList[index].title}\n${formatDuration(Duration(seconds: gOboeAudioState.videoList[index].lengthSeconds))})"));
                  }))),
          Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.grey),
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                assetsAudioPlayer.builderIsPlaying(
                    builder: (context, isPlaying) {
                  return IconButton(
                      onPressed: () {
                        assetsAudioPlayer.playOrPause();
                      },
                      icon: Icon(
                          isPlaying ? Icons.pause_circle : Icons.play_circle));
                }),
                Expanded(child: assetsAudioPlayer.builderRealtimePlayingInfos(
                    builder: (context, r) {
                  return ProgressBar(
                    barHeight: 2,
                    thumbRadius: 6,
                    progress: r.currentPosition,
                    total: r.duration,
                    onSeek: (duration) {
                      assetsAudioPlayer.seek(duration);
                      // gOboeAudioState.changePosition(duration);
                    },
                  );
                }))
              ],
            ),
          )
        ],
      ),
    ));
  }
}
