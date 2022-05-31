import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:owlet/enum.dart';
import 'package:owlet/models/User.dart';

class Story with ChangeNotifier {
  int id;
  String content;
  String? caption;
  User? user;
  StoryType type;
  bool iViewed;
  int totalView;
  Duration duration;
  String createdAt;

  Story({
    required this.id,
    required this.content,
    required this.caption,
    this.user,
    this.iViewed = false,
    required this.type,
    this.totalView: 0,
    this.duration: const Duration(milliseconds: 0),
    this.createdAt: 'now',
  });

  Story copyWith({
    int? id,
    String? content,
    String? caption,
    User? user,
    bool? iViewed,
    StoryType? type,
    int? totalView,
    Duration? duration,
    String? createdAt,
  }) {
    return Story(
      id: id ?? this.id,
      content: content ?? this.content,
      caption: caption ?? this.caption,
      user: user ?? this.user,
      iViewed: iViewed ?? this.iViewed,
      type: type ?? this.type,
      totalView: totalView ?? this.totalView,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'caption': caption,
      'user': user,
      'iViewed': iViewed,
      'type': type == StoryType.IMAGE
          ? 'image'
          : type == StoryType.TEXT
              ? 'text'
              : 'video',
      'totalView': totalView,
      'duration': duration.inMilliseconds,
    };
  }

  factory Story.fromMap(Map<String, dynamic> map) {
    return Story(
      id: map['id'] ?? null,
      content: map['content'] ?? '',
      caption: map['caption'] == null || map['caption'].length < 1
          ? null
          : map['caption'],
      user: map['user'] == null
          ? null
          : User.fromMap(map['user'].runtimeType == String
              ? jsonDecode(map['user'])
              : map['user']),
      iViewed: map['iViewed'] == 1 ? true : false,
      type: map['type'] == 'image'
          ? StoryType.IMAGE
          : map['type'] == 'video'
              ? StoryType.VIDEO
              : map['type'] == 'text'
                  ? StoryType.TEXT
                  : StoryType.NULL,
      totalView: map['totalView'] ?? 0,
      duration: Duration(milliseconds: map['duration'] ?? 4000),
      createdAt: map['createdAt'] != null
          ? DateFormat('yyyy-MM-dd kk:mm:ss')
              .format(DateTime.parse(map['createdAt']).toLocal())
          : DateTime.now().toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Story.fromJson(String source) => Story.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Story(id: $id, content: $content, caption: $caption, user: $user, iViewed: $iViewed, totalView: $totalView, duration: $duration, createdAt: $createdAt)';
  }
}
