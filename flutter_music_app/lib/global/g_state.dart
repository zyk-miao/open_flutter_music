import 'package:flutter_lyric/lyrics_model_builder.dart';
import 'package:flutter_music_app/common/function.dart';
import 'package:flutter_music_app/player/player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_common/entity/YoutubeVideo.dart';
import 'package:music_common/entity/music.dart';
import 'package:music_common/entity/tag.dart';
import 'package:music_common/utils/log.dart';
import 'package:oboe/oboe.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class OboeIndexPageState extends Oboe {
  List<Tag> _tagList = [];

  void updateOboeTagList(list) {
    _tagList = list;
    next();
  }

  List<Tag> get tagList => _tagList;
}

var gOboeIndexPageState = OboeIndexPageState();

class OboeMusicPageState extends Oboe {
  List<Music> _musicList = [];
  Tag _tag = Tag();

  List<Music> get musicList => _musicList;

  void updateOboeMusicList(list, {bool notify = true}) {
    _musicList = list;
    updatePlaying(notify: false);
    if (notify) {
      next();
    }
  }

  void updateOboeTag(Tag tag, {bool notify = true}) {
    _tag = tag;
    if (notify) {
      next();
    }
  }

  void update(tag, list) {
    _musicList = list;
    _tag = tag;
    updatePlaying(notify: false);
    next();
  }

  Tag get tag => _tag;
}

var gOboeMusicPageState = OboeMusicPageState();

var gOboePlayState = PlayState();

class PlayState extends Oboe {
  bool _buffering = false;
  bool _playStatus = false;
  final List<Music> _playingMusics = [];
  Music _playingMusic = Music();
  Duration _position = const Duration(seconds: 3);
  Duration _total = const Duration();
  Duration _buffer = const Duration();
  Tag _playingTag = Tag();
  late bool _shuffleModeEnabled;
  late LoopMode _loopMode;

  bool get shuffleModeEnabled => _shuffleModeEnabled;

  Duration get position => _position;
  var lyricModel;

  changeLoopMood(LoopMode loopMode) {
    _loopMode = loopMode;
    next();
  }

  changeShuffleModeEnabled(bool b) {
    _shuffleModeEnabled = b;
    next();
  }

  updateLyricModel() async {
    String s = await searchLyric();
    lyricModel = LyricsModelBuilder.create().bindLyricToMain(s).getModel();
    next();
  }

  updateTag(Tag tag) {
    _playingTag = tag;
    next();
  }

  changePlayStatus({status}) {
    if (status != null) {
      _playStatus = status;
    } else {
      _playStatus = Player.getPlayStatus();
    }
    _buffering = false;
    next();
  }

  changeBuffering(bool value) {
    _buffering = value;
  }

  changePlayingMusic(Music value) {
    _playingMusic = value;
    next();
  }

  void updateTotal(Duration value) {
    _total = value;
    next();
  }

  void updateBuffer(Duration value) {
    _buffer = value;
    next();
  }

  void updatePosition(Duration value) {
    _position = value;
    next();
  }

  bool get buffering => _buffering;

  bool get playStatus => _playStatus;

  Music get playingMusic => _playingMusic;

  List<Music> get playingMusics => _playingMusics;

  Duration get total => _total;

  Duration get buffer => _buffer;

  Tag get playingTag => _playingTag;

  LoopMode get loopMode => _loopMode;
}

var gOboeYoutubeState = YoutubePlayerPageState();

class YoutubePlayerPageState extends Oboe {
  final List<Video> _videoList = [];

  updateVideoList(List<Video> list) {
    _videoList.clear();
    _videoList.addAll(list);
    next();
  }

  List<Video> get videoList => _videoList;
}

var gOboeAudioState = AudioPlayerPageState();

class AudioPlayerPageState extends Oboe {
  final List<YoutubeVideo> _videoList = [];

  updateVideoList(List<YoutubeVideo> list) {
    _videoList.clear();
    _videoList.addAll(list);
    next();
  }

  changeSelected(index) {

    for (int i = 0; i < gOboeAudioState.videoList.length; i++) {
      if (index == i) {
        gOboeAudioState.videoList[i].selected = true;
      } else {
        gOboeAudioState.videoList[i].selected = false;
      }
    }
    next();
  }

  List<YoutubeVideo> get videoList => _videoList;
}
