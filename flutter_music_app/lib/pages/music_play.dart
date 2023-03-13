import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyric_ui/ui_netease.dart';
import 'package:flutter_lyric/lyrics_reader_widget.dart';
import 'package:flutter_music_app/global/g_state.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_common/utils/log.dart';

import '../Icons/Icons.dart';
import '../common/components/play_bottom_control.dart';
import '../player/player.dart';

final lyricUI = UINetease();

class MusicPlayPage extends StatelessWidget {
  const MusicPlayPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    gOboePlayState.updateLyricModel();
    return gOboePlayState.ob(
      () => Scaffold(
          appBar: AppBar(
            title: Text("${gOboePlayState.playingMusic.musicName}"),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                flex: 10,
                child: Container(
                    color: Colors.blueAccent,
                    child: LyricsReader(
                      model: gOboePlayState.lyricModel,
                      playing: false,
                      position: gOboePlayState.position.inMilliseconds,
                      emptyBuilder: () => Center(
                        child: Text(
                          "搜索歌词中",
                          style: lyricUI.getOtherMainTextStyle(),
                        ),
                      ),
                    )
                    // LyricWidget(
                    //   size: Size(double.infinity, double.infinity),
                    //   lyrics: lyric,
                    //   controller:  LyricController()..progress=state.position,
                    // ),
                    ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      ProgressBar(
                        barHeight: 2,
                        thumbRadius: 6,
                        buffered: gOboePlayState.buffer,
                        progress: gOboePlayState.position,
                        total: gOboePlayState.total,
                        onSeek: (duration) {
                          Player.seekByDuration(duration);
                        },
                      ),
                      Expanded(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                              flex: 1,
                              child: IconButton(
                                onPressed: () {
                                  LogD("点击切换模式");
                                  if (gOboePlayState.shuffleModeEnabled) {
                                    Player.setShuffleModeEnabled(false);
                                    Player.setLoopMood(LoopMode.all);
                                  } else if (gOboePlayState.loopMode ==
                                      LoopMode.all) {
                                    Player.setShuffleModeEnabled(false);
                                    Player.setLoopMood(LoopMode.one);
                                  } else {
                                    Player.setShuffleModeEnabled(true);
                                    Player.setLoopMood(LoopMode.all);
                                  }
                                },
                                icon: Icon(gOboePlayState.shuffleModeEnabled
                                    ? Icons_.random
                                    : gOboePlayState.loopMode == LoopMode.all
                                        ? Icons_.loopPlayback
                                        : Icons_.singleTuneCirculation),
                                color: Colors.blueAccent,
                              )),
                          Expanded(
                              flex: 1,
                              child: IconButton(
                                onPressed: () {
                                  LogD("点击播放");
                                  Player.playOrPause();
                                },
                                icon: Icon(gOboePlayState.buffering
                                    ? Icons.circle_outlined
                                    : gOboePlayState.playStatus
                                        ? Icons.pause
                                        : Icons.play_arrow),
                                color: Colors.blueAccent,
                              )),
                          Expanded(
                            flex: 1,
                            child: IconButton(
                                onPressed: () {
                                  LogD("点击下一曲");
                                  Player.playNext();
                                },
                                icon: const Icon(Icons.skip_next,
                                    color: Colors.blueAccent)),
                          ),
                          const Expanded(
                            flex: 1,
                            child: ShowPlayingButton(
                              color: Colors.blueAccent,
                            ),
                          )
                        ],
                      ))
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }
}
