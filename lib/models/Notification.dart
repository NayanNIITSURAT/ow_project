import 'package:owlet/models/Listing.dart';
import 'package:owlet/services/apiUrl.dart';

enum NotificationType {
  MENTION,
  LIKE,
  FOLLOW,
  GENERAL,
  COMMENT,
  NEW_POST,
  SUBSCRIPTION,

}

class NotificationUser {
  String avartar;
  int id;
  String username;
  bool iFollow;

  NotificationUser({
    required this.username,
    required this.id,
    required this.avartar,
    required this.iFollow,
  });

  factory NotificationUser.fromJson(Map<String, dynamic> json) {
    return NotificationUser(
      id: json['id'],
      avartar:
          AppUrl.profileImageBaseUrl + (json['avartar'] ?? 'avatar_2.jpeg'),
      username: json['username'],
      iFollow: json['iFollow'] == 1 ? true : false,
    );
  }
}

class Notification {
  final int id;
  final NotificationType notifyableType;
  final NotificationUser sender;
  final Listing? listing;
  final int notifyableId;
  final bool isOpened;

  Notification(
      {required this.id,
      required this.notifyableType,
      required this.notifyableId,
      required this.sender,
      required this.isOpened,
      this.listing});

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      notifyableType: json['notifyableType'] == 'mention'
          ? NotificationType.MENTION
          : json['notifyableType'] == 'follow'
              ? NotificationType.FOLLOW
              : json['notifyableType'] == 'like'
                  ? NotificationType.LIKE
                  : NotificationType.GENERAL,
      notifyableId: json['notifyableId'],
      sender: NotificationUser.fromJson(json['sender']),
      listing:
          json['listing'] != null ? Listing.fromJson(json['listing']) : null,
      isOpened: json['read'],
    );
  }
}
