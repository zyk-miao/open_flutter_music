class Music {
  Music(
      {String? id,
      String? musicName,
      String? artistName,
      String? musicUrl,
      String? fileName,
      String? createTime,
      String? minioFileName,
      String? md5,
      num? index,
      bool ifLove = false,
      bool selected = false}) {
    _id = id;
    _musicName = musicName;
    _artistName = artistName;
    _musicUrl = musicUrl;
    _fileName = fileName;
    _createTime = createTime;
    _minioFileName = minioFileName;
    _md5 = md5;
    _index = index;
    _ifLove = ifLove;
    selected = selected;
  }

  Music.fromJson(dynamic json) {
    _id = json['id'];
    _musicName = json['musicName'];
    _artistName = json['artistName'];
    _musicUrl = json['musicUrl'];
    _fileName = json['fileName'];
    _createTime = json['createTime'];
    _minioFileName = json['minioFileName'];
    _md5 = json['md5'];
    _index = json['index'];
    _ifLove = json['ifLove'] ?? false;
    selected = json['selected'] ?? false;
  }

  String? _id;
  String? _musicName;
  String? _artistName;
  String? _musicUrl;
  String? _fileName;
  String? _createTime;
  dynamic _minioFileName;
  dynamic _md5;
  num? _index;
  bool _ifLove = false;
  bool selected = false;
  bool playing = false;

  Music copyWith({
    String? id,
    String? musicName,
    String? artistName,
    String? musicUrl,
    String? fileName,
    String? createTime,
    dynamic minioFileName,
    dynamic md5,
    num? index,
  }) =>
      Music(
        id: id ?? _id,
        musicName: musicName ?? _musicName,
        artistName: artistName ?? _artistName,
        musicUrl: musicUrl ?? _musicUrl,
        fileName: fileName ?? _fileName,
        createTime: createTime ?? _createTime,
        minioFileName: minioFileName ?? _minioFileName,
        md5: md5 ?? _md5,
        index: index ?? _index,
      );

  String? get id => _id;

  String? get musicName => _musicName;

  String? get artistName => _artistName;

  String? get musicUrl => _musicUrl;

  String? get fileName => _fileName;

  String? get createTime => _createTime;

  dynamic get minioFileName => _minioFileName;

  dynamic get md5 => _md5;

  num? get index => _index;

  bool get ifLove => _ifLove;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['musicName'] = _musicName;
    map['artistName'] = _artistName;
    map['musicUrl'] = _musicUrl;
    map['fileName'] = _fileName;
    map['createTime'] = _createTime;
    map['minioFileName'] = _minioFileName;
    map['md5'] = _md5;
    map['index'] = _index;
    map['ifLove'] = _ifLove;
    return map;
  }

  @override
  String toString() {
    return 'Music{_id: $_id, _musicName: $_musicName, _artistName: $_artistName, _musicUrl: $_musicUrl, _fileName: $_fileName, _createTime: $_createTime, _minioFileName: $_minioFileName, _md5: $_md5, _index: $_index, _ifLove: $_ifLove}';
  }
}
