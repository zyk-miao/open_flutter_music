import 'dart:convert';
import 'package:flutter_music_app/common/function.dart';
import 'package:flutter_music_app/global/g_state.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_common/entity/music.dart';
import 'package:music_common/entity/tag.dart';
import 'package:music_common/utils/log.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio_background/just_audio_background.dart';

class Player {
  Player._() {}
  static final _player = AudioPlayer()
    ..playerStateStream.listen((state) {
      switch (state.processingState) {
        case ProcessingState.idle:
          LogD('空闲中');
          break;
        case ProcessingState.loading:
          LogD("载入中");
          gOboePlayState.changeBuffering(true);
          break;
        case ProcessingState.buffering:
          LogD("缓冲中");
          gOboePlayState.changeBuffering(true);
          break;
        case ProcessingState.ready:
          LogD("音乐就绪");
          gOboePlayState.changePlayStatus();
          // notifyPlayStatus();
          break;
        case ProcessingState.completed:
          gOboePlayState.changePlayStatus();
          LogD("缓冲完成");
          break;
      }
    })
    ..durationStream.listen((duration) {
      if (duration != null) {
        gOboePlayState.updateTotal(duration);
      }
    })
    ..positionStream.listen((duration) {
      gOboePlayState.updatePosition(duration);
    })
    ..bufferedPositionStream.listen((duration) {
      gOboePlayState.updateBuffer(duration);
    });

  // ..setAudioSource(_playingAudioSourceList);
  static final List<LockCachingAudioSource> _playingMusicUrlList = [];
  static final _playingAudioSourceList = ConcatenatingAudioSource(
      shuffleOrder: DefaultShuffleOrder(), children: _playingMusicUrlList);

  static play() async {
    int? index = getCurrentIndex();
    if (index != null) {
      gOboePlayState.changePlayingMusic(gOboePlayState.playingMusics[index]);
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

  static setMusicList(List<Music> musicList) async {
    gOboePlayState.playingMusics.clear();
    gOboePlayState.playingMusics.addAll(musicList);
    await _playingAudioSourceList.clear();
    await _playingAudioSourceList.addAll(List<LockCachingAudioSource>.from(
        musicList.map((e) => LockCachingAudioSource(
              Uri.parse(e.musicUrl!),
              tag: MediaItem(
                // Specify a unique ID for each media item:
                id: '1',
                // Metadata to display in the notification:
                album: e.artistName,
                title: e.musicName!,
              ),
            ))));
  }

  static playByIndex(List<Music> musicList, int index) async {
    if (!equalsStringAndMusic(musicList, _playingMusicUrlList)) {
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

  static changePlayingMusicList(List<Music> musicList) async {
    // _playingMusicList.clear();
    // _playingMusicList.addAll(musicList);
    await _playingAudioSourceList.clear();
    await _playingAudioSourceList.addAll(List<LockCachingAudioSource>.from(
        // musicList.map((e) => AudioSource.uri(Uri.parse(e.musicUrl!)))));
        musicList.map((e) => LockCachingAudioSource(
              Uri.parse(e.musicUrl!),
              tag: MediaItem(
                // Specify a unique ID for each media item:
                id: '1',
                // Metadata to display in the notification:
                album: e.artistName,
                title: e.musicName!,
              ),
            ))));
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

  static init() async {
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
      switch(mood.name){
        case "all":
          instance.setString("loopMode", "all");break;
        case "one":
          instance.setString("loopMode", "one");break;
      }
      gOboePlayState.changeLoopMood(mood);
    });
    _player.shuffleModeEnabledStream.listen((b) {
      instance.setBool("shuffleMood", b);
      gOboePlayState.changeShuffleModeEnabled(b);
    });
    var s = instance.getString("_playingMusicList");
    var i = instance.getInt("currentIndex");
    var t = instance.getString("currentTag");
    if (s != null && i != null && t != null) {
      var tag = Tag.fromJson(json.decode(t));
      gOboePlayState.updateTag(tag);
      var tmpList =
          List<Music>.from(json.decode(s).map((e) => Music.fromJson(e)));
      await setMusicList(tmpList);
      await _player.seek(Duration.zero, index: i);
      gOboePlayState.changePlayingMusic(gOboePlayState.playingMusics[i]);
    }
    _player.currentIndexStream.listen((index) {
      if (gOboePlayState.playingMusics.isNotEmpty && index != null) {
        gOboePlayState.changePlayingMusic(gOboePlayState.playingMusics[index]);
        updatePlaying();
        gOboePlayState.updateLyricModel();
        SharedPreferences.getInstance().then((instance) async {
          instance.setString(
              "_playingMusicList", json.encode(gOboePlayState.playingMusics));
          instance.setInt("currentIndex", index);
          instance.setString(
              "currentTag", json.encode(gOboePlayState.playingTag));
        });
      }
    });
  }
}
