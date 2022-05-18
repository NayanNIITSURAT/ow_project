import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:owlet/enum.dart';
import 'package:owlet/models/HttpResponse.dart';
import 'package:owlet/models/User.dart';
import 'package:owlet/services/apiUrl.dart';
import 'package:owlet/services/comment.dart';
import 'package:owlet/services/user.dart';
import 'package:owlet/services/utils.dart';

class Listing with ChangeNotifier {
  dynamic id;
  List<String> images;
  String caption;
  String createdAt;
  User owner;
  int totalFollowers;
  int totalLikes;
  int totalComments;
  bool iLike;
  CommentResponse commentsData;

  Listing({
    required this.id,
    required this.images,
    required this.caption,
    required this.owner,
    this.totalFollowers: 0,
    this.totalLikes: 0,
    this.totalComments: 0,
    this.iLike: false,
    required this.commentsData,
    required this.createdAt,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'],
      images: List.from(json['images'])
          .map((image) => AppUrl.listingImageBaseUrl + image)
          .toList(),
      caption: json['caption'],
      owner: User.fromJson(json['user'] ?? {'id': -1, 'username': ''}),
      totalLikes: json['totalLikes']?.toInt() ?? 0,
      totalComments: json['totalComments']?.toInt() ?? 0,
      iLike: json['iLike'] == 1 ? true : false,
      commentsData: json['commentsData'] != null
          ? CommentResponse.fromMap(json['commentsData'])
          : CommentResponse(
              totalItems: 0, comments: [], totalPages: 1, currentPage: 1),
      createdAt: json['createdAt'] ?? null,
    );
  }

  Future<bool> like() async {
    try {
      await toggleLike(RequestAction.Follow, LikeableType.LISTING, id);
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<bool> unLike() async {
    try {
      await toggleLike(RequestAction.UnFollow, LikeableType.LISTING, id);
      return false;
    } catch (error) {
      return true;
    }
  }

  Future<Map<String, dynamic>> postComment(String message, int listingId,
      {int? parentId}) async {
    notifyListeners();
    try {
      final comment = await createComment(
          message, listingId, CommentableType.LISTING,
          parentId: parentId);
      if (comment['parentId'] != null) {
        commentsData.comments
            .firstWhere((_) => _.id == parentId)
            .replyData!
            .comments[0]
            .id = comment['id'];
        commentsData.comments
            .firstWhere((_) => _.id == parentId)
            .totalReplies += 1;
      } else
        commentsData.comments[0].id = comment['id'];
      notifyListeners();

      return {
        'message': 'Comment posted',
        'status': true,
      };
    } catch (error) {
      print("the error is $error here");

      return {'message': error.toString(), 'status': false};
    }
  }

  Listing copyWith({
    dynamic? id,
    List<String>? images,
    String? caption,
    User? owner,
    int? totalFollowers,
    int? totalLikes,
    int? totalComments,
    bool? iLike,
    CommentResponse? commentsData,
    String? createdAt,
  }) {
    return Listing(
      id: id ?? this.id,
      images: images ?? this.images,
      caption: caption ?? this.caption,
      owner: owner ?? this.owner,
      totalFollowers: totalFollowers ?? this.totalFollowers,
      totalLikes: totalLikes ?? this.totalLikes,
      totalComments: totalComments ?? this.totalComments,
      iLike: iLike ?? this.iLike,
      commentsData: commentsData ?? this.commentsData,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'images': images,
      'caption': caption,
      'owner': owner.toMap(),
      'totalFollowers': totalFollowers,
      'totalLikes': totalLikes,
      'totalComments': totalComments,
      'iLike': iLike,
      'commentsData': commentsData.toMap(),
    };
  }

  factory Listing.fromMap(Map<String, dynamic> map) {
    return Listing(
      id: map['id'] ?? null,
      images: List<String>.from(map['images']),
      caption: map['caption'] ?? '',
      owner: User.fromMap(map['owner']),
      totalFollowers: map['totalFollowers']?.toInt() ?? 0,
      totalLikes: map['totalLikes']?.toInt() ?? 0,
      totalComments: map['totalComments']?.toInt() ?? 0,
      iLike: map['iLike'] ?? false,
      commentsData: CommentResponse.fromMap(map['commentsData']),
      createdAt: map['createdAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Listing(id: $id, images: $images, caption: $caption, owner: $owner, totalFollowers: $totalFollowers, totalLikes: $totalLikes, totalComments: $totalComments, iLike: $iLike, commentsData: $commentsData)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Listing &&
        other.id == id &&
        listEquals(other.images, images) &&
        other.caption == caption &&
        other.owner == owner &&
        other.totalFollowers == totalFollowers &&
        other.totalLikes == totalLikes &&
        other.totalComments == totalComments &&
        other.iLike == iLike &&
        other.commentsData == commentsData;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        images.hashCode ^
        caption.hashCode ^
        owner.hashCode ^
        totalFollowers.hashCode ^
        totalLikes.hashCode ^
        totalComments.hashCode ^
        iLike.hashCode ^
        commentsData.hashCode;
  }
}
