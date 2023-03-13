import 'dart:convert';

Tag tagFromJson(String str) => Tag.fromJson(json.decode(str));

String tagToJson(Tag data) => json.encode(data.toJson());

class Tag {
  Tag(
      {String? id,
      String? tagName,
      String? createTime,
      String? userId,
      String? coverImg,
      bool? flag,
      bool selected = false,
      int? num}) {
    _id = id;
    _tagName = tagName;
    _createTime = createTime;
    _userId = userId;
    _coverImg = coverImg;
    this.selected;
    _flag = flag;
    _num = num;
  }

  Tag.fromJson(dynamic json) {
    _id = json['id'];
    _tagName = json['tagName'];
    _createTime = json['createTime'];
    _userId = json['userId'];
    _coverImg = json['coverImg'];
    _flag = json['flag'];
    _num = json['num'];
  }

  String? _id;
  String? _tagName;
  String? _createTime;
  String? _userId;
  String? _coverImg;
  bool selected = false;
  bool? _flag;
  int? _num;
  Tag copyWith({
    String? id,
    String? tagName,
    String? createTime,
    String? userId,
    String? coverImg,
  }) =>
      Tag(
        id: id ?? _id,
        tagName: tagName ?? _tagName,
        createTime: createTime ?? _createTime,
        userId: userId ?? _userId,
        coverImg: coverImg ?? _coverImg,
      );

  String? get id => _id;

  String? get tagName => _tagName;

  String? get createTime => _createTime;

  String? get userId => _userId;

  String? get coverImg => _coverImg;

  bool? get flag => _flag;

  int? get num => _num;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['tagName'] = _tagName;
    map['createTime'] = _createTime;
    map['userId'] = _userId;
    map['coverImg'] = _coverImg;
    return map;
  }

  @override
  String toString() {
    return 'Tag{_id: $_id, _tagName: $_tagName, _userId: $_userId, _coverImg: $_coverImg, selected: $selected, _num: $_num}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is Tag) {
      return _id == other.id && _tagName == other.tagName;
    } else {
      return false;
    }
  }

  static List<Tag> copyList(List<Tag> source) {
    List<Tag> list = [];
    for (var element in source) {
     list.add(element.copyWith());
    }
    return list;
  }


  @override
  int get hashCode => _id.hashCode ^ _tagName.hashCode;
}
