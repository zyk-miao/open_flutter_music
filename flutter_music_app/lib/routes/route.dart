import 'package:flutter/material.dart';
import 'package:flutter_music_app/pages/music_manager.dart';
import 'package:flutter_music_app/pages/audio_player.dart';
import 'package:flutter_music_app/pages/youtube_player.dart';

import '../pages/index.dart';
import '../pages/login.dart';
import '../pages/music.dart';
import '../pages/music_play.dart';
import '../pages/tag_manager.dart';

var routes = <String, WidgetBuilder>{
  '/login': (context) => const LoginPage(),
  '/index': (context) => const IndexPage(),
  '/music/list': (context) => MusicPage(),
  '/tag/manager': (context) => const TagManagerPage(),
  '/music/manager': (context) => const MusicManagerPage(),
  '/music/music_play': (context) => const MusicPlayPage(),
  '/youtube_player': (context) => const YoutubePlayerPage(),
  '/audio_player': (context) => const AudioPlayerPage(),
  // '/search': (context) => MusicSearchWidget(),
};
