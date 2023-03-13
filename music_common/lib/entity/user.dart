import 'dart:convert';

/// id : "1"
/// username : "1"
User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  User({
    this.id,
    this.username,
  });

  User.fromJson(dynamic json) {
    id = json['id'];
    username = json['username'];
    token=json['token'];
  }

  String? id;
  String? username;
  String? token;
  User copyWith({
    String? id,
    String? username,
  }) =>
      User(
        id: id ?? this.id,
        username: username ?? this.username,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['username'] = username;
    return map;
  }

  @override
  String toString() {
    return 'User{id: $id, username: $username, token: $token}';
  }
}
