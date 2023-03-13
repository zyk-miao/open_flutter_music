import 'package:flutter/material.dart';
import 'package:flutter_music_desktop/pages/youtube_audio_player.dart';

import '../pages/index.dart';
import '../pages/login.dart';

var routes = <String, WidgetBuilder>{
  '/login': (context) => const LoginPage(),
  '/index': (context) => const IndexPage(),
  '/searchFromYoutube':(context)=>const YoutubePlayerPage()
  // '/music/list': (context) => MusicPage(),
  // '/tag/manager': (context) => const TagManagerPage(),
  // '/music/manager': (context) => const MusicManagerPage(),
  // '/music/music_play': (context) => const MusicPlayPage(),
  // '/youtube_player': (context) => const YoutubePlayerPage(),
  // '/audio_player': (context) => const AudioPlayerPage(),
  // '/search': (context) => MusicSearchWidget(),
};
