import 'dart:convert';
import 'package:just_audio/just_audio.dart';
import 'package:music_common/entity/music.dart';
import 'package:music_common/utils/log.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart' as aplayer;
import '../common/function.dart';
import '../global/g_state.dart';

class JPlayer {
  JPlayer._();

  static final _player = AudioPlayer()
    ..playerStateStream.listen((state) {
      switch (state.processingState) {
        case ProcessingState.idle:
          LogD('空闲中');
          break;
        case ProcessingState.loading:
          LogD("载入中");
          gOboeJPlayState.changeBuffering(true);
          break;
        case ProcessingState.buffering:
          LogD("缓冲中");
          gOboeJPlayState.changeBuffering(true);
          break;
        case ProcessingState.ready:
          LogD("音乐就绪");
          gOboeJPlayState.changePlayStatus();
          // notifyPlayStatus();
          break;
        case ProcessingState.completed:
          gOboeJPlayState.changePlayStatus();
          LogD("缓冲完成");
          break;
      }
    })
    ..durationStream.listen((duration) {
      if (duration != null) {
        gOboeJPlayState.updateTotal(duration);
      }
    })
    ..positionStream.listen((duration) {
      gOboeJPlayState.updatePosition(duration);
    })
    ..bufferedPositionStream.listen((duration) {
      gOboeJPlayState.updateBuffer(duration);
    })..volumeStream.listen((event) {
      LogD("volume: $event");
    });

  // ..setAudioSource(_playingAudioSourceList);
  static final List<LockCachingAudioSource> _playingMusicUrlList = [];
  static final _playingAudioSourceList = ConcatenatingAudioSource(
      shuffleOrder: DefaultShuffleOrder(), children: _playingMusicUrlList);

  static play() async {
    int? index = getCurrentIndex();
    if (index != null) {
      gOboeJPlayState.changePlayingMusic(gOboeJPlayState.playingMusics[index]);
    }
    // provider.playMusic(_playingMusicList[_player.currentIndex!]);
    if (!_player.playing) {
      _player.play();
    }
  }

  static getPlayStatus() {
    return _player.playing;
  }

  static playOrPause() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
    if (_player.currentIndex != null) {}
  }
static adjustVolume({double? up,double? down})async{
    var v=_player.volume;
    if(up!=null){
      v+=up;
    }
    if(down!=null){
      v-=down;
    }
    await _player.setVolume(v);
}
  static setMusicList(List<Music> musicList) async {
    gOboeJPlayState.playingMusics.clear();
    gOboeJPlayState.playingMusics.addAll(musicList);
    await _player.pause();
    LogD("切换列表");
    await _playingAudioSourceList.clear();
    await _playingAudioSourceList.addAll(List<LockCachingAudioSource>.from(
        musicList.map((e) => LockCachingAudioSource(
              Uri.parse(e.musicUrl!),
            ))));
  }

  static playByIndex(List<Music> musicList, int index) async {
    if (!needUpdateMusicList(musicList, _playingMusicUrlList)) {
      await setMusicList(musicList);
    }
    await seekByIndex(index);
  }

  static seekByDuration(Duration duration) async {
    await _player.seek(duration);
    play();
  }

  static seekByIndex(int index) async {
    await _player.seek(Duration.zero, index: index);
    // var instance = await SharedPreferences.getInstance();
    play();
  }

  static playNext() async {
    await _player.seekToNext();
    play();
  }

  static changePlayStatus(bool status) {
    if (status) {
      _player.play();
    } else {
      _player.pause();
    }
  }

  static int? getCurrentIndex() {
    return _player.currentIndex;
  }

  static setLoopMood(LoopMode loopMode) {
    _player.setLoopMode(loopMode);
  }

  static setShuffleModeEnabled(bool b) {
    _player.setShuffleModeEnabled(b);
  }

  static dispose() async {
    await _player.dispose();
  }

  static init() async {
    await aplayer.AudioPlayer.global.changeLogLevel(aplayer.LogLevel.info);
    await _player.setAudioSource(_playingAudioSourceList);
    var instance = await SharedPreferences.getInstance();
    var shuffleEnabled = instance.getBool("shuffleMood");
    var loopMode = instance.getString("loopMode");
    if (shuffleEnabled != null) {
      await _player.setShuffleModeEnabled(shuffleEnabled);
    } else {
      await _player.setShuffleModeEnabled(false);
    }
    switch (loopMode) {
      case "all":
        await _player.setLoopMode(LoopMode.all);
        break;
      case "one":
        await _player.setLoopMode(LoopMode.one);
        break;
      default:
        await _player.setLoopMode(LoopMode.all);
    }
    _player.loopModeStream.listen((mood) {
      switch (mood.name) {
        case "all":
          instance.setString("loopMode", "all");
          break;
        case "one":
          instance.setString("loopMode", "one");
          break;
      }
      gOboeJPlayState.changeLoopMood(mood);
    });
    _player.shuffleModeEnabledStream.listen((b) {
      instance.setBool("shuffleMood", b);
      gOboeJPlayState.changeShuffleModeEnabled(b);
    });
    var s = instance.getString("_playingMusicList");
    var i = instance.getInt("currentIndex");
    var t = instance.getString("currentTag");
    if (s != null && i != null && t != null) {
      // var tag = Tag.fromJson(json.decode(t));
      // gOboeJPlayState.updateTag(tag);
      // var tmpList =
      //     List<Music>.from(json.decode(s).map((e) => Music.fromJson(e)));
      // await setMusicList(tmpList);
      // await _player.seek(Duration.zero, index: i);
      // gOboeJPlayState.changePlayingMusic(gOboeJPlayState.playingMusics[i]);
    }
    _player.currentIndexStream.listen((index) {
      LogD("index:$index");
      LogD(_playingAudioSourceList.length);
      if (index != null && index < gOboeJPlayState.playingMusics.length) {
        gOboeJPlayState
            .changePlayingMusic(gOboeJPlayState.playingMusics[index]);
        // updatePlaying();
        // gOboeJPlayState.updateLyricModel();
        SharedPreferences.getInstance().then((instance) async {
          instance.setString(
              "_playingMusicList", json.encode(gOboeJPlayState.playingMusics));
          instance.setInt("currentIndex", index);
          instance.setString(
              "currentTag", json.encode(gOboeJPlayState.playingTag));
        });
      }
    });
  }
}
