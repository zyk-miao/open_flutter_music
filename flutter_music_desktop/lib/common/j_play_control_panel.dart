import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_common/utils/log.dart';
import 'package:text_scroll/text_scroll.dart';

import '../Icons/Icons.dart';
import '../global/g_state.dart';
import '../player/j_player.dart';

class JPlayControlPanel extends StatelessWidget {
  const JPlayControlPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:  const BoxDecoration(border: Border(top: BorderSide(width: 1,color: Colors.lightBlue)),boxShadow:[
        BoxShadow(
            color: Color.fromRGBO(248, 255, 255, 0.8),
            offset: Offset(2.0, 2.0), //阴影xy轴偏移量
            blurRadius: 2.0, //阴影模糊程度
            spreadRadius: 2.0 //阴影扩散程度
        )
      ]),
      padding: const EdgeInsets.all(5),
      child: gOboeJPlayState.ob(() => Row(
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: TextScroll(
                    "${gOboeJPlayState.playingMusic.musicName}-${gOboeJPlayState.playingMusic.artistName}",
                    textAlign: TextAlign.left,
                    velocity: const Velocity(pixelsPerSecond: Offset(25, 0)),
                    style: const TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
              ),
              Expanded(
                flex: 12,
                child: Column(
                  children: [
                    Expanded(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            LogD("点击切换模式");
                            if (gOboeJPlayState.shuffleModeEnabled) {
                              JPlayer.setShuffleModeEnabled(false);
                              JPlayer.setLoopMood(LoopMode.all);
                            } else if (gOboeJPlayState.loopMode ==
                                LoopMode.all) {
                              JPlayer.setShuffleModeEnabled(false);
                              JPlayer.setLoopMood(LoopMode.one);
                            } else {
                              JPlayer.setShuffleModeEnabled(true);
                              JPlayer.setLoopMood(LoopMode.all);
                            }
                          },
                          child: Icon(
                            gOboeJPlayState.shuffleModeEnabled
                                ? Icons_.random
                                : gOboeJPlayState.loopMode == LoopMode.all
                                    ? Icons_.loopPlayback
                                    : Icons_.singleTuneCirculation,
                            size: 18,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            LogD("点击播放");
                            JPlayer.playOrPause();
                          },
                          child: Icon(
                            gOboeJPlayState.buffering
                                ? Icons.circle_outlined
                                : gOboeJPlayState.playStatus
                                    ? Icons.pause
                                    : Icons.play_arrow,
                            size: 18,
                          ),
                        ),
                        InkWell(
                            onTap: () {
                              LogD("点击下一曲");
                              JPlayer.playNext();
                            },
                            child: const Icon(
                              Icons.skip_next,
                              size: 18,
                            )),
                        Listener(onPointerSignal: (PointerSignalEvent event)async{
                          if (event is PointerScrollEvent) {
                            var v=event.scrollDelta.dy;
                            if(v<0){
                              await JPlayer.adjustVolume(up: 500);
                            }else{
                              await JPlayer.adjustVolume(down: 500);
                            }
                          }
                        },child: const Icon(Icons.volume_up,size: 18,),),
                      ],
                    )),
                    ProgressBar(
                      barHeight: 2,
                      thumbRadius: 6,
                      buffered: gOboeJPlayState.buffer,
                      progress: gOboeJPlayState.position,
                      total: gOboeJPlayState.total,
                      onSeek: (duration) {
                        JPlayer.seekByDuration(duration);
                      },
                    )
                  ],
                ),
              ),
              const Expanded(
                flex: 2,
                child: Center(
                  child: Text("列表"),
                ),
              )
            ],
          )),
    );
  }
}
