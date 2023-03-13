import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_music_app/global/g_state.dart';
import 'package:flutter_music_app/global/g_variable.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:music_common/utils/log.dart';
import 'package:text_scroll/text_scroll.dart';

import '../../player/player.dart';

class PlayBottomControl extends StatelessWidget {
  const PlayBottomControl({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // margin: EdgeInsets.all(5),
      // padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
          // borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.grey),
      child: gOboePlayState.ob(() => Row(
            children: [
              Expanded(
                  flex: 6,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed('/music/music_play');
                    },
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 20),
                      margin: const EdgeInsets.all(15),
                      child: TextScroll(
                        gOboePlayState.playingMusic.musicName ?? "null",
                        textAlign: TextAlign.left,
                        // maxLines: 1,
                        velocity:
                            const Velocity(pixelsPerSecond: Offset(25, 0)),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  )),
              // const Expanded(
              //   flex: 6,
              //   child: MusicProgressBar(),
              // ),
              Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Row(
                      children: [
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
                              color: Colors.white,
                            )),
                        Expanded(
                          flex: 1,
                          child: IconButton(
                              onPressed: () {
                                LogD("点击下一曲");
                                Player.playNext();
                              },
                              icon: const Icon(Icons.skip_next,
                                  color: Colors.white)),
                        ),
                        const Expanded(
                          flex: 1,
                          child: ShowPlayingButton(),
                        ),
                      ],
                    ),
                  ))
            ],
          )),
    );
  }
}

class ShowPlayingButton extends StatelessWidget {
  const ShowPlayingButton({Key? key, this.color = Colors.white})
      : super(key: key);
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          showCupertinoModalBottomSheet(
            enableDrag: false,
            context: context,
            builder: (context) => SingleChildScrollView(
              controller: ModalScrollController.of(context),
              child: Container(
                decoration: const BoxDecoration(
                    // color: Colors.lightBlueAccent,
                    ),
                // height: globalHeight / 2,
                height: gHeight / 2,
                child: Column(
                  children: [
                    gOboePlayState.ob(() => Text(
                          "${gOboePlayState.playingTag.tagName}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                        child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                              gOboePlayState.playingMusics.length, (index) {
                            return GestureDetector(
                              onTap: () {
                                Player.seekByIndex(index);
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(0.0, 0.0),
                                      //阴影xy轴偏移量
                                      blurRadius: 1.0,
                                      //阴影模糊程度
                                      spreadRadius: 1.0 //阴影扩散程度
                                      )
                                ]),
                                padding: const EdgeInsets.all(10),
                                child: TextScroll(
                                  "${gOboePlayState.playingMusics[index].musicName}-${gOboePlayState.playingMusics[index].artistName}",
                                  textDirection: TextDirection.ltr,
                                  style: TextStyle(
                                      // color: Colors.black12
                                      ),
                                ),
                              ),
                            );
                          })),
                    ))
                  ],
                ),
              ),
            ),
          );
        },
        icon: Icon(Icons.list, color: color));
  }
}
