import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_common/entity/music.dart';
import 'package:music_common/utils/log.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../common/components/music_add_form.dart';
import '../global/g_state.dart';

class YoutubePlayerPage extends StatefulWidget {
  const YoutubePlayerPage({Key? key}) : super(key: key);

  @override
  State<YoutubePlayerPage> createState() => _YoutubePlayerPageState();
}

class _YoutubePlayerPageState extends State<YoutubePlayerPage> {
  final TextEditingController textEditingController = TextEditingController();
   final YoutubePlayerController _controller = YoutubePlayerController(
    params: const YoutubePlayerParams(
      mute: false,
      showControls: true,
      showFullscreenButton: true,
    ),
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:
          // persistentFooterButtons: const [Icon],
          YoutubePlayerScaffold(
        controller: _controller,
        aspectRatio: 16 / 9,
        builder: (BuildContext context, Widget player) {
          return Column(
            children: [
              player,
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                child: TextField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                      hintText: "搜索",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () async {
                          var yt = YoutubeExplode();
                          var search = await yt.search
                              .search(textEditingController.text);
                          gOboeYoutubeState.updateVideoList(search);
                        },
                      )),
                ),
              ),
              Expanded(
                  child: gOboeYoutubeState.ob(() => ListView.builder(
                      itemCount: gOboeYoutubeState.videoList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
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
                                                    musicName: gOboeYoutubeState
                                                        .videoList[index]
                                                        .title),
                                                type: MusicAddFormType
                                                    .addFromYoutube,
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
                            onTap: () {
                              LogE(gOboeYoutubeState.videoList[index].id);
                              _controller.loadVideo(
                                  gOboeYoutubeState.videoList[index].url);
                            },
                            title:
                                Text(gOboeYoutubeState.videoList[index].title));
                      }))),
              IconButton(
                  onPressed: () {
                    _controller.loadVideoById(videoId: "2WaPDP6vcmY");
                  },
                  icon: const Icon(Icons.play_circle)),
            ],
          );
        },
      ),
    );
  }
}
