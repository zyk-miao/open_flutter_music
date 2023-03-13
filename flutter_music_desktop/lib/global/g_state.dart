import 'package:just_audio/just_audio.dart' as JAudio;
import 'package:music_common/entity/YoutubeVideo.dart';
import 'package:music_common/entity/music.dart';
import 'package:music_common/entity/tag.dart';
import 'package:oboe/oboe.dart';

import '../player/j_player.dart';

class OboeTagsState extends Oboe {
  List<Tag> _tagList = [];

  void updateOboeTagList(list) {
    _tagList = list;
    next();
  }

  List<Tag> get tagList => _tagList;
}

var gOboeTagsState = OboeTagsState();

class OboeMusicsState extends Oboe {
  List<Music> _musicList = [];
  Tag _tag = Tag();

  List<Music> get musicList => _musicList;

  void updateOboeMusicList(list, {bool notify = true}) {
    _musicList = list;
    // updatePlaying(notify: false);
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
    // updatePlaying(notify: false);
    next();
  }

  Tag get tag => _tag;
}

var gOboeMusicsState = OboeMusicsState();

var gOboeJPlayState = JPlayState();

class JPlayState extends Oboe {
  bool _buffering = false;
  bool _playStatus = false;
  final List<Music> _playingMusics = [];
  Music _playingMusic = Music();
  Duration _position = const Duration(seconds: 3);
  Duration _total = const Duration();
  Duration _buffer = const Duration();
  Tag _playingTag = Tag();
  late bool _shuffleModeEnabled = false;
  late JAudio.LoopMode _loopMode = JAudio.LoopMode.all;

  bool get shuffleModeEnabled => _shuffleModeEnabled;

  Duration get position => _position;
  var lyricModel;

  changeLoopMood(JAudio.LoopMode loopMode) {
    _loopMode = loopMode;
    next();
  }

  changeShuffleModeEnabled(bool b) {
    _shuffleModeEnabled = b;
    next();
  }

  updateLyricModel() async {
    // String s = await searchLyric();
    // lyricModel = LyricsModelBuilder.create().bindLyricToMain(s).getModel();
    // next();
  }

  updateTag(Tag tag) {
    _playingTag = tag;
    next();
  }

  changePlayStatus({status}) {
    if (status != null) {
      _playStatus = status;
    } else {
      _playStatus = JPlayer.getPlayStatus();
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

  JAudio.LoopMode get loopMode => _loopMode;
}

var gOboeYoutubeAudioState = YoutubeAudioPageState();

class YoutubeAudioPageState extends Oboe {
  final List<YoutubeVideo> _videoList = [];
  Duration _total = const Duration();
  bool _playing = false;

  bool get playing => _playing;

  Duration get total => _total;
  Duration _position = const Duration();

  changePlaying(bool p) {
    _playing = p;
    next();
  }

  updateVideoList(List<YoutubeVideo> list) {
    _videoList.clear();
    _videoList.addAll(list);
    next();
  }

  changeTotal(Duration value) {
    _total = value;
    next();
  }

  changeSelected(index) {
    for (int i = 0; i < _videoList.length; i++) {
      if (index == i) {
        _videoList[i].selected = true;
      } else {
        _videoList[i].selected = false;
      }
    }
    next();
  }

  List<YoutubeVideo> get videoList => _videoList;

  Duration get position => _position;

  changePosition(Duration value) {
    _position = value;
    next();
  }
}
