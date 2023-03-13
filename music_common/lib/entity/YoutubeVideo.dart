import 'dart:convert';

/// videoId : "123sad"
/// title : "ad"

YoutubeVideo youtubeVideoFromJson(String str) =>
    YoutubeVideo.fromJson(json.decode(str));

String youtubeVideoToJson(YoutubeVideo data) => json.encode(data.toJson());

class YoutubeVideo {
  YoutubeVideo({
    String? videoId,
    String? title,
    required int lengthSeconds,
  }) {
    _videoId = videoId;
    _title = title;
    _lengthSeconds = lengthSeconds;
  }

  YoutubeVideo.fromJson(dynamic json) {
    _videoId = json['videoId'];
    _title = json['title'];
    _lengthSeconds = json['lengthSeconds'];
  }

  String? _videoId;
  String? _title;
  bool selected = false;
  int _lengthSeconds = 0;

  YoutubeVideo copyWith({
    String? videoId,
    String? title,
    int? lengthSeconds,
  }) =>
      YoutubeVideo(
        videoId: videoId ?? _videoId,
        title: title ?? _title,
        lengthSeconds: lengthSeconds??_lengthSeconds
      );

  String? get videoId => _videoId;

  int get lengthSeconds => _lengthSeconds;

  String? get title => _title;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['videoId'] = _videoId;
    map['title'] = _title;
    map['lengthSeconds'] = _lengthSeconds;
    return map;
  }
}
