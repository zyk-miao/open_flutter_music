import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_common/api/api.dart';
import 'package:music_common/entity/YoutubeVideo.dart';
import 'package:music_common/entity/music.dart';
import 'package:music_common/entity/response_entity.dart';
import 'package:music_common/utils/function.dart';

import '../common/music_add_form.dart';
import '../config/config_request.dart';
import '../global/g_state.dart';

class YoutubePlayerPage extends StatefulWidget {
  const YoutubePlayerPage({Key? key}) : super(key: key);

  @override
  State<YoutubePlayerPage> createState() => _YoutubePlayerPageState();
}

class _YoutubePlayerPageState extends State<YoutubePlayerPage> {
  final TextEditingController textEditingController = TextEditingController();
  final AudioPlayer _player = AudioPlayer()
    ..durationStream.listen((event) {
      if (event != null) {
        gOboeYoutubeAudioState.changeTotal(event);
      }
    })
    ..positionStream.listen((event) {
      gOboeYoutubeAudioState.changePosition(event);
    })
    ..playerStateStream.listen((event) {
      gOboeYoutubeAudioState.changePlaying(event.playing);
    });

  @override
  void initState() {
    super.initState();
    if (!const bool.fromEnvironment('dart.vm.product')) {
      textEditingController.text = "烟花易冷";
      _search();
    }
  }



  _search() async {
    ResponseEntity response =
        await searchFromYoutube(textEditingController.text);
    List<YoutubeVideo> list = List.from(
        (response.data as List<dynamic>).map((e) => YoutubeVideo.fromJson(e)));
    gOboeYoutubeAudioState.updateVideoList(list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
              child: gOboeYoutubeAudioState.ob(() => ListView.builder(
                  itemCount: gOboeYoutubeAudioState.videoList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                        selected:
                            gOboeYoutubeAudioState.videoList[index].selected,
                        selectedColor: Colors.lightBlueAccent,
                        trailing: IconButton(
                          onPressed: () {
                            SmartDialog.show(
                                builder: (BuildContext buildContext) {
                              return SimpleDialog(
                                children: [
                                  SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: MusicAddForm(
                                        music: Music(
                                            musicName: gOboeYoutubeAudioState
                                                .videoList[index].title),
                                        type: MusicAddFormType.addFromYoutube,
                                        youtubeVideoId: gOboeYoutubeAudioState
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
                          gOboeYoutubeAudioState.changeSelected(index);
                          await _player.setUrl(
                              "${baseUrl}playMusicFromYoutube?youtubeVideoId=${gOboeYoutubeAudioState.videoList[index].videoId}");
                          await _player.play();
                        },
                        title: Text(
                            "${gOboeYoutubeAudioState.videoList[index].title}\n${formatDuration(Duration(seconds: gOboeYoutubeAudioState.videoList[index].lengthSeconds))})"));
                  }))),
          Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.grey),
            padding: const EdgeInsets.all(10),
            child: gOboeYoutubeAudioState.ob(() => Row(
                  children: [
                    IconButton(
                        onPressed: () async {
                          if (_player.playing) {
                            await _player.pause();
                          } else {
                            await _player.play();
                          }
                        },
                        icon: Icon(gOboeYoutubeAudioState.playing
                            ? Icons.pause_circle
                            : Icons.play_circle)),
                    Expanded(
                        child: ProgressBar(
                            barHeight: 2,
                            thumbRadius: 6,
                            progress: gOboeYoutubeAudioState.position,
                            total: gOboeYoutubeAudioState.total,
                            onSeek: (duration) {
                              _player.seek(duration);
                              // gOboeAudioState.changePosition(duration);
                            }))
                  ],
                )),
          )
        ],
      ),
    );
  }
}
