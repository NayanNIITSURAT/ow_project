import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:owlet/db/messages_db.dart';
import 'package:owlet/enum.dart';
import 'package:owlet/models/Message.dart';
import 'package:owlet/models/User.dart';

final String chatTable = 'chat_users';

final String chatsDbName = 'chats.db';

final int11 = 'int(11)';
final notNull = 'NOT NULL';
final idType = '$int11 $notNull PRIMARY KEY';
final boolType = 'BOOLEAN DEFAULT FALSE';
final String createChatTableQuery = '''CREATE TABLE $chatTable (
        `${ChatFields.id}` $idType,
        `${ChatFields.username}` TEXT $notNull,
        `${ChatFields.avartar}` TEXT $notNull,
        `${ChatFields.confirmed}` $boolType,
        `${ChatFields.iFollow}` $boolType,
        `${ChatFields.isOnline}` $boolType,
        `${ChatFields.lastSeen}` TEXT $notNull,
        `${ChatFields.hasVerifiedCompany}` $boolType
      );''';

class ChatFields {
  static final List<String> values = [
    /// Add all fields
    id,
    username,
    avartar,
    isOnline, confirmed,
    iFollow, hasVerifiedCompany,
  ];

  static final String id = 'id';
  static final String username = 'username';
  static final String avartar = 'avartar';
  static final String confirmed = 'confirmed';
  static final String iFollow = 'iFollow';
  static final String isOnline = 'isOnline';
  static final String lastSeen = 'lastSeen';
  static final String hasVerifiedCompany = 'hasVerifiedCompany';
}

class ChatUser {
  int id;
  String username;
  String avartar;
  bool confirmed;
  bool iFollow;
  bool isOnline;
  bool hasVerifiedCompany;
  DateTime lastSeen;
  List<Message> messages;
  ChatUser({
    required this.id,
    required this.username,
    required this.avartar,
    this.confirmed = false,
    this.iFollow = false,
    this.isOnline = false,
    this.hasVerifiedCompany = false,
    required this.lastSeen,
    this.messages = const [],
  }) {
    setMessages();
  }

  setMessages() async {
    if (messages.isEmpty)
      messages =
          (await MessageDB.instance.getUserMessages(this.id)).reversed.toList();
  }

  ChatUser copyWith({
    int? id,
    String? username,
    String? avartar,
    bool? confirmed,
    bool? iFollow,
    bool? isOnline,
    bool? hasVerifiedCompany,
    DateTime? lastSeen,
    List<Message>? messages,
  }) {
    return ChatUser(
      id: id ?? this.id,
      username: username ?? this.username,
      avartar: avartar ?? this.avartar,
      confirmed: confirmed ?? this.confirmed,
      iFollow: iFollow ?? this.iFollow,
      isOnline: isOnline ?? this.isOnline,
      hasVerifiedCompany: hasVerifiedCompany ?? this.hasVerifiedCompany,
      lastSeen: lastSeen ?? this.lastSeen,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'avartar': avartar,
      'confirmed': confirmed == true ? 1 : 0,
      'iFollow': iFollow == true ? 1 : 0,
      'isOnline': isOnline == true ? 1 : 0,
      'hasVerifiedCompany': hasVerifiedCompany == true ? 1 : 0,
      'lastSeen': lastSeen.toIso8601String(),
      // 'messages': messages.map((x) => x.toMap()).toList(),
    };
  }

  factory ChatUser.fromMap(Map<String, dynamic> map) {
    return ChatUser(
      id: map['id']?.toInt() ?? 0,
      username: map['username'] ?? '',
      avartar: map['avartar'] ?? '',
      confirmed: map['confirmed'] == 1,
      iFollow: map['iFollow'] == 1,
      isOnline: map['isOnline'] == 1,
      hasVerifiedCompany: map['hasVerifiedCompany'] == 1,
      lastSeen: DateTime.parse(map['lastSeen'] ??
          map['lastQueryAt'] ??
          DateTime.now().toIso8601String()),
      messages: List<Message>.from(
          (map['messages'] ?? []).map((x) => Message.fromMap(x))),
    );
  }

  User get getUser => User(id: id, username: username, avtar: avartar);

  String toJson() => json.encode(toMap());

  factory ChatUser.fromJson(String source) =>
      ChatUser.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ChatUser(id: $id, username: $username, avartar: $avartar, confirmed: $confirmed, iFollow: $iFollow, isOnline: $isOnline, hasVerifiedCompany: $hasVerifiedCompany, lastSeen: $lastSeen, messages: $messages)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatUser &&
        other.id == id &&
        other.username == username &&
        other.avartar == avartar &&
        other.confirmed == confirmed &&
        other.iFollow == iFollow &&
        other.isOnline == isOnline &&
        other.hasVerifiedCompany == hasVerifiedCompany &&
        other.lastSeen == lastSeen &&
        listEquals(other.messages, messages);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        avartar.hashCode ^
        confirmed.hashCode ^
        iFollow.hashCode ^
        isOnline.hashCode ^
        hasVerifiedCompany.hashCode ^
        lastSeen.hashCode ^
        messages.hashCode;
  }

  int get unSeenMsgCount => messages.reversed
      .takeWhile((_) => _.status != ChatState.SEEN && _.senderId == id)
      .length;
}
