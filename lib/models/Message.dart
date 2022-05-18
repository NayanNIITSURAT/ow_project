import 'dart:convert';

import 'package:owlet/enum.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:owlet/models/ChatUser.dart';
import 'package:owlet/models/Listing.dart';
import 'package:owlet/models/Story.dart';
import 'package:owlet/models/User.dart';

final String messageTable = 'messages';

final String int11 = 'int(11)';
final String notNull = 'NOT NULL';
final String idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
final String boolType = 'BOOLEAN DEFAULT FALSE';
final String defaultNull = 'DEFAULT NULL';
final String createMessageTableQuery = '''
  CREATE TABLE $messageTable (
    `${MessageFields.id}` $idType,
    `${MessageFields.incomingId}` $int11 $defaultNull,
    `${MessageFields.content}` longtext,
    `${MessageFields.media}` TEXT,
    `${MessageFields.mediaType}` TEXT $defaultNull,
    `${MessageFields.status}` TEXT DEFAULT DELIVERED,
    `${MessageFields.refType}` TEXT $defaultNull,
    `${MessageFields.time}` TEXT $notNull,
    `${MessageFields.chatableId}` $int11 $defaultNull,
    `${MessageFields.chatable}`  TEXT $defaultNull,
    `${MessageFields.parentId}` $int11 $defaultNull,
    `${MessageFields.senderId}` $int11 $defaultNull,
    `${MessageFields.receiverId}` $int11 $defaultNull,
    CONSTRAINT `${messageTable}_2` FOREIGN KEY (`parentId`) REFERENCES `$messageTable` (`id`) ON DELETE CASCADE,
    CONSTRAINT `${chatTable}_2` FOREIGN KEY (`senderId`, `receiverId`) REFERENCES `$chatTable` (`id`, `id`) ON DELETE CASCADE
  );
''';
final String insertFields =
    'incomingId,content,media,mediaType,status,refType,time,chatableId,parentId,senderId,receiverId';

class MessageFields {
  static final List<String> values = [
    /// Add all fields
    id,
    incomingId,
    content,
    media,
    mediaType, status, refType, time, senderId, receiverId, parentId,
    chatableId, chatable,
  ];

  static final String id = 'id';
  static final String incomingId = 'incomingId';
  static final String content = 'content';
  static final String status = 'status';
  static final String senderId = 'senderId';
  static final String media = 'media';
  static final String mediaType = 'mediaType';
  static final String receiverId = 'receiverId';
  static final String parentId = 'parentId';
  static final String refType = 'refType';
  static final String chatableId = 'chatableId';
  static final String chatable = 'chatable';
  static final String time = 'time';
}

class Message {
  final int id;
  final int? incomingId;
  final int? senderId;
  final int? receiverId;
  final String content;
  final String? time;
  final String? media;
  final MediaType? mediaType;
  final ChatableType? refType;
  ChatState status;
  final User? sender;
  final Message? parentMessage;
  final Listing? listing;
  final Story? story;
  Message({
    required this.id,
    this.incomingId,
    this.senderId,
    this.receiverId,
    required this.content,
    this.time,
    this.media,
    this.mediaType,
    this.refType,
    this.status = ChatState.SNEDING,
    this.sender,
    this.parentMessage,
    this.listing,
    this.story,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      incomingId: map['incomingId'] ?? map['id'],
      content: map['content'] ?? map['message'] ?? '',
      time: map['time'] ?? map['createdAt'],
      media: map['media'],
      mediaType: map['mediaType'] == 'image'
          ? MediaType.IMAGE
          : map['mediaType'] == 'video'
              ? MediaType.VIDEO
              : map['mediaType'] == 'audio'
                  ? MediaType.AUDIO
                  : null,
      status: map['status'] == 'sending'
          ? ChatState.SNEDING
          : map['status'] == 'sent'
              ? ChatState.SENT
              : map['status'] == 'delivered'
                  ? ChatState.DELIVERED
                  : map['status'] == 'seen'
                      ? ChatState.SEEN
                      : ChatState.FAILED,
      sender: map['sender'] != null ? User.fromJson(map['sender']) : null,
      parentMessage: map['parentMessage'] != null
          ? Message.fromMap(map['parentMessage'])
          : null,
      listing: map['listing'] != null
          ? Listing.fromJson(map['listing'])
          : map['chatable'] != null
              ? (() {
                  final chatable = jsonDecode(map['chatable']);
                  return map['refType'] == 'listing'
                      ? Listing.fromMap(chatable)
                      : null;
                })()
              : null,
      story: map['story'] != null
          ? Story.fromMap(map['story'])
          : map['chatable'] != null
              ? (() {
                  final chatable = jsonDecode(map['chatable']);

                  return map['refType'] == 'story'
                      ? Story.fromMap(chatable)
                      : null;
                })()
              : null,
      refType: map['refType'] == 'listing'
          ? ChatableType.STORY
          : map['refType'] == 'story'
              ? ChatableType.LISTING
              : null,
    );
  }

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source));

  String toDbValues() {
    return '($incomingId, $content, $media, $mediaType, delivered, ${listing != null ? 'listing' : story != null ? 'story' : null}, $time, ${listing?.id ?? story?.id}, ${parentMessage?.id ?? null}, $senderId, $receiverId)';
  }

  bool get isSending => status == ChatState.SNEDING;
  bool get isSent => status == ChatState.SENT;
  bool get isDelivered => status == ChatState.DELIVERED;
  bool get isSeen => status == ChatState.SEEN;
  bool get failed => status == ChatState.FAILED;
  bool get isReply => parentMessage != null && listing != null && story != null;

  Map<String, dynamic> toMap() {
    return {
      'id': id < 1 ? null : id,
      'incomingId': incomingId,
      'content': content,
      'status': chatableType(status),
      'time': time,
      'media': media,
      'mediaType': mediaType == MediaType.IMAGE
          ? 'image'
          : mediaType == MediaType.VIDEO
              ? 'video'
              : mediaType == MediaType.AUDIO
                  ? 'audo'
                  : mediaType == MediaType.DOC
                      ? 'doc'
                      : null,
      'senderId': sender?.id ?? senderId,
      'refType': story != null
          ? 'story'
          : listing != null
              ? 'listing'
              : null,
      'receiverId': receiverId,
      'parentId': parentMessage?.id,
      'chatableId': listing?.id ?? story?.id,
      'chatable': (listing?.id ?? story?.id) != null
          ? jsonEncode(listing?.toMap() ?? story?.toMap())
          : null
    };
  }

  String toJson() => json.encode(toMap());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Message &&
        other.id == id &&
        other.incomingId == incomingId &&
        other.content == content &&
        other.time == time &&
        other.media == media &&
        other.status == status &&
        other.sender == sender &&
        other.parentMessage == parentMessage &&
        other.listing == listing &&
        other.story == story;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        incomingId.hashCode ^
        content.hashCode ^
        time.hashCode ^
        media.hashCode ^
        status.hashCode ^
        sender.hashCode ^
        parentMessage.hashCode ^
        listing.hashCode ^
        story.hashCode;
  }

  Message copyWith({
    int? id,
    int? incomingId,
    int? senderId,
    int? receiverId,
    String? content,
    String? time,
    String? media,
    MediaType? mediaType,
    ChatableType? refType,
    ChatState? status,
    User? sender,
    Message? parentMessage,
    Listing? listing,
    Story? story,
  }) {
    return Message(
      id: id ?? this.id,
      incomingId: incomingId ?? this.incomingId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      time: time ?? this.time,
      media: media ?? this.media,
      mediaType: mediaType ?? this.mediaType,
      refType: refType ?? this.refType,
      status: status ?? this.status,
      sender: sender ?? this.sender,
      parentMessage: parentMessage ?? this.parentMessage,
      listing: listing ?? this.listing,
      story: story ?? this.story,
    );
  }

  bool get hasListing => listing != null;
  bool get hasStory => story != null;

  // Map<String, dynamic> get chatableMap {
  //   return {
  //     'type': hasStory
  //         ? 'story'
  //         : hasListing
  //             ? 'listing'
  //             : null,
  //     'id': story?.id ?? listing?.id,
  //     'content': hasListing
  //         ? listing?.caption
  //         : hasStory
  //             ? story?.type == StoryType.TEXT
  //                 ? story?.content
  //                 : story?.caption
  //             : null,
  //     'contentType': story?.type == StoryType.IMAGE
  //         ? 'image'
  //         : story?.type == StoryType.TEXT
  //             ? 'text'
  //             : 'video',
  //     'username': listing?.owner.username ?? story?.user?.username,
  //     'thumbnail': hasListing
  //         ? listing?.images[0]
  //         : story?.type == StoryType.IMAGE || story?.type == StoryType.VIDEO
  //             ? story?.content
  //             : null,
  //     ' createdAt': listing?.createdAt ?? story?.createdAt
  //   };
  // }

  @override
  String toString() {
    return 'Message(id: $id, incomingId: $incomingId, senderId: $senderId, receiverId: $receiverId, content: $content, time: $time, media: $media, mediaType: $mediaType, refType: $refType, status: $status, sender: $sender, parentMessage: $parentMessage, listing: $listing, story: $story)';
  }
}
