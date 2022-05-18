import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:owlet/enum.dart';
import 'package:owlet/models/HttpResponse.dart';
import 'package:owlet/models/User.dart';
import 'package:owlet/services/comment.dart';
import 'package:owlet/services/user.dart';
import 'package:owlet/services/utils.dart';

class Comment with ChangeNotifier {
  int? id;
  int? parentId;
  int commentableId;
  String message;
  String createdAt;
  bool iLike;
  int totalLikes;
  int totalReplies;
  User author;
  CommentResponse? replyData;
  Comment({
    this.id,
    required this.commentableId,
    this.parentId,
    required this.message,
    this.createdAt: 'now',
    this.iLike: false,
    this.totalLikes: 0,
    this.totalReplies: 0,
    required this.author,
    this.replyData,
  });

  Comment copyWith({
    int? id,
    int? commentableId,
    int? parentId,
    String? message,
    String? createdAt,
    bool? iLike,
    int? totalLikes,
    int? totalReplies,
    User? author,
    CommentResponse? replyData,
  }) {
    return Comment(
      id: id ?? this.id,
      commentableId: commentableId ?? this.commentableId,
      parentId: parentId ?? this.parentId,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      iLike: iLike ?? this.iLike,
      totalLikes: totalLikes ?? this.totalLikes,
      totalReplies: totalReplies ?? this.totalReplies,
      author: author ?? this.author,
      replyData: replyData ?? this.replyData,
    );
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id']?.toInt(),
      parentId: map['parentId']?.toInt(),
      commentableId: map['commentableId']?.toInt() ?? 0,
      message: map['message'] ?? '',
      createdAt: map['createdAt'] ?? '',
      iLike: map['iLike'] == 1,
      totalLikes: map['totalLikes']?.toInt() ?? 0,
      totalReplies: map['totalReplies']?.toInt() ?? 0,
      author: User.fromJson(map['author'] ?? map['user']),
      replyData: CommentResponse(
          totalItems: 0, comments: [], totalPages: 1, currentPage: -1),
    );
  }

  factory Comment.fromJson(String source) =>
      Comment.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Comment(id: $id, parentId: $parentId, message: $message, createdAt: $createdAt, iLike: $iLike, totalLikes: $totalLikes, totalReplies: $totalReplies, author: $author, replyData: $replyData)';
  }

  Future loadReplies(CommentableType commentableType) async {
    // print(replyData);
    try {
      replyData!.setCommentsData = await fetchComments(
        commentableType,
        commentableId,
        replyData!.currentPage + 1,
        parentId: id,
      );
      notifyListeners();
    } catch (err) {
      print(err);
      return 'An error occured while fetching comments';
    }
  }

  Future<bool> like() async {
    if (id != null)
      try {
        await toggleLike(RequestAction.Follow, LikeableType.COMMENT, id!);
        notifyListeners();
        return true;
      } catch (error) {
        print(error);
        return false;
      }
    else
      return false;
  }

  Future<bool> unLike() async {
    if (id != null)
      try {
        await toggleLike(RequestAction.UnFollow, LikeableType.COMMENT, id!);
        notifyListeners();
        return false;
      } catch (error) {
        return true;
      }
    else
      return true;
  }

  get fetchedRepliesCount => replyData?.comments.length ?? 0;

  get remainingRepliesCount => totalReplies - fetchedRepliesCount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parentId': parentId,
      'commentableId': commentableId,
      'message': message,
      'createdAt': createdAt,
      'iLike': iLike,
      'totalLikes': totalLikes,
      'totalReplies': totalReplies,
      'author': author.toMap(),
    };
  }

  String toJson() => json.encode(toMap());
}
