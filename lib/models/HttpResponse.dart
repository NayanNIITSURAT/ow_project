import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:owlet/Preferences/UserPreferences.dart';
import 'package:owlet/Providers/Flag.dart';
import 'package:owlet/Providers/HashTagProvider.dart';
import 'package:owlet/enum.dart';
import 'package:owlet/models/Comment.dart';
import 'package:owlet/models/Listing.dart';
import 'package:owlet/models/Notification.dart' as N;
import 'package:owlet/models/Story.dart';
import 'package:owlet/models/User.dart';
import 'package:owlet/services/user.dart';
import 'package:owlet/services/utils.dart';

import '../services/auth.dart';
import 'Requestuser.dart';

class ListingResponse extends ChangeNotifier {
  int totalItems;
  List<Listing> listings;
  int totalPages;
  int currentPage;

  ListingResponse({
    required this.totalItems,
    this.listings: const [],
    required this.totalPages,
    required this.currentPage,
  });

  factory ListingResponse.fromJson(Map<String, dynamic> json) {
    return ListingResponse(
      totalItems: json['totalItems'],
      listings: List.from(json['listings'] ?? json['rows'] ?? [])
          .map((e) => Listing.fromJson(e))
          .toList(),
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
    );
  }

  set setListingsData(ListingResponse newData) =>
      UserPreferences().hiddenListings.then((hiddenListings) {
        // if (currentPage + 1 == newData.currentPage) {
        final totalNewListings = newData.totalItems - totalItems;
        listings = newData.currentPage == 0
            ? newData.listings
            : [
          ...listings,
          ...(totalNewListings > 0 && listings.length > 0
              ? newData.listings.skip(totalNewListings)
              : newData.listings)
              .where(
                (element) => !hiddenListings.contains(element.id.toString()),
          )
        ];
        totalItems = newData.totalItems;
        totalPages = newData.totalPages;
        currentPage = newData.currentPage;
        notifyListeners();
        // }
      });

  set addComment(int id) {
    listings = listings.map((listing) {
      if (listing.id == id) {
        listing.totalComments =  listing.totalComments +=1;
      }
      return listing;
    }).toList();
  }
  set newListing(Listing newListing) {
    listings.insert(0, newListing);
    totalItems += 1;
    notifyListeners();
  }

  set updatedListing(Listing updatedListing) {
    listings = listings.map((listing) {
      if (listing.id == updatedListing.id)
        listing.caption = updatedListing.caption;
      return listing;
    }).toList();
    notifyListeners();
  }

  set removeListing(int listingId) {
    listings.removeWhere((listing) => listing.id == listingId);
    totalItems -= 1;
    notifyListeners();
  }

  set hideListing(int id) {
    listings.removeWhere((element) => element.id == id);
    UserPreferences().hideListing(id);
    notifyListeners();
  }

  set toggleLike(int id) {
    listings = listings.map((listing) {
      if (listing.id == id) {
        listing.iLike = !listing.iLike;
        listing.iLike ? listing.totalLikes += 1 : listing.totalLikes -= 1;
      }
      return listing;
    }).toList();
  }

  set unfollowUser(User user) {
    listings =
        listings.where((element) => element.owner.id != user.id).toList();
    notifyListeners();
  }
}

class UserResponse extends ChangeNotifier {
  int totalItems;
  List<User> users;
  int totalPages;
  int currentPage;

  UserResponse({
    required this.totalItems,
    this.users: const [],
    required this.totalPages,
    required this.currentPage,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      totalItems: json['totalItems'],
      users: List.from(json['users'] ?? json['rows'])
          .map((e) => User.fromJson(e))
          .toList(),
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
    );
  }

  set updateUsersData(UserResponse userData) {
    users = [
      ...users,
      ...userData.users,
    ];
    totalItems = userData.totalItems;
    totalPages = userData.totalPages;
    currentPage = userData.currentPage;
  }

  set newUser(User newUser) => users.add(newUser);
}

class HashTagResponse extends ChangeNotifier {
  int totalItems;
  List<HashTag> tags;
  int totalPages;
  int currentPage;

  HashTagResponse({
    required this.totalItems,
    this.tags: const [],
    required this.totalPages,
    required this.currentPage,
  });

  factory HashTagResponse.fromJson(Map<String, dynamic> json) {
    return HashTagResponse(
      totalItems: json['totalItems'],
      tags: List.from(json['listings'] ?? json['rows'])
          .map((e) => HashTag.fromJson(e))
          .toList(),
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
    );
  }

  set updateTagsData(HashTagResponse tagData) {
    tags = [
      ...tags,
      ...tagData.tags,
    ];
    totalItems = tagData.totalItems;
    totalPages = tagData.totalPages;
    currentPage = tagData.currentPage;
  }

  set newUser(HashTag newHashCount) => tags.add(newHashCount);
}

class FlagResponse extends ChangeNotifier {
  int totalItems;
  List<Flag> flags;
  int totalPages;
  int currentPage;

  FlagResponse({
    required this.totalItems,
    this.flags: const [],
    required this.totalPages,
    required this.currentPage,
  });

  factory FlagResponse.fromJson(Map<String, dynamic> json) {
    return FlagResponse(
      totalItems: json['totalItems'],
      flags: List.from(json['flags'] ?? json['rows'])
          .map((e) => Flag.fromJson(e))
          .toList(),
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
    );
  }

  set setFlagsData(FlagResponse newData) {
    // if (currentPage + 1 == newData.currentPage) {
    flags = [
      ...(newData.currentPage == 0 ? [] : flags),
      ...newData.flags,
    ];
    totalItems = newData.totalItems;
    totalPages = newData.totalPages;
    currentPage = newData.currentPage;
    notifyListeners();
    // }
  }
}

class ChatResponse extends ChangeNotifier {
  int totalItems;
  List<User> chats;
  int totalPages;
  int currentPage;

  ChatResponse({
    required this.totalItems,
    this.chats: const [],
    required this.totalPages,
    required this.currentPage,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      totalItems: json['totalItems'],
      chats: List.from(json['chats'] ?? json['rows'])
          .map((e) => User.fromJson(e))
          .toList(),
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
    );
  }

  set setChatsData(ChatResponse newData) {
    // if (currentPage + 1 == newData.currentPage) {
    // final totalNewChats = newData.totalItems - totalItems;
    // stories = newData.currentPage == 0
    chats = [
      ...chats,
      ...newData.chats,
    ];
    totalItems = newData.totalItems;
    totalPages = newData.totalPages;
    currentPage = newData.currentPage;
    notifyListeners();
    // }
  }
}

class NotificationResponse extends ChangeNotifier {
  int totalItems;
  List<N.Notification> notifications;
  int totalPages;
  int currentPage;

  NotificationResponse({
    required this.totalItems,
    this.notifications: const [],
    required this.totalPages,
    required this.currentPage,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      totalItems: json['totalItems'],
      notifications: List.from(json['rows'])
          .map((e) => N.Notification.fromJson(e))
          .toList(),
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
    );
  }

  set setData(NotificationResponse newData) {
    // if (currentPage + 1 == newData.currentPage) {
    notifications = [
      ...notifications,
      ...newData.notifications,
    ];
    totalItems = newData.totalItems;
    totalPages = newData.totalPages;
    currentPage = newData.currentPage;
    notifyListeners();
    // }
  }

  List<N.Notification> get newNotifications =>
      notifications.where((n) => !n.isOpened).toList();
  List<N.Notification> get oldNotifications =>
      notifications.where((n) => n.isOpened).toList();
}



class CommentResponse extends ChangeNotifier {
  int totalItems;
  List<Comment> comments;
  int totalPages;
  int currentPage;

  CommentResponse({
    required this.totalItems,
    required this.comments,
    required this.totalPages,
    required this.currentPage,
  });

  CommentResponse copyWith({
    int? totalItems,
    List<Comment>? comments,
    int? totalPages,
    int? currentPage,
  }) {
    return CommentResponse(
      totalItems: totalItems ?? this.totalItems,
      comments: comments ?? this.comments,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  factory CommentResponse.fromMap(Map<String, dynamic> map) {
    return CommentResponse(
      totalItems: map['totalItems']?.toInt() ?? 0,
      comments:
      List<Comment>.from(map['comments']?.map((x) => Comment.fromMap(x))),
      totalPages: map['totalPages']?.toInt() ?? 0,
      currentPage: map['currentPage']?.toInt() ?? 0,
    );
  }

  factory CommentResponse.fromJson(String source) =>
      CommentResponse.fromMap(json.decode(source));

  @override
  String toString() {
    return 'CommentResponse(totalItems: $totalItems, comments: $comments, totalPages: $totalPages, currentPage: $currentPage)';
  }

  set setCommentsData(CommentResponse newData) {
    // UserPreferences().hiddenListings.then((hiddenListings) {
    // if (currentPage + 1 == newData.currentPage) {
    final totalNewComments = newData.totalItems - totalItems;
    comments = newData.currentPage == 0
        ? newData.comments
        : [
      ...comments,
      ...(totalNewComments > 0 && comments.length > 0
          ? newData.comments.skip(totalNewComments)
          : newData.comments)
    ];
    totalItems = newData.totalItems;
    totalPages = newData.totalPages;
    currentPage = newData.currentPage;
    notifyListeners();
    // }
    // });
  }

  set newComment(Comment newComment) {
    comments.insert(0, newComment);
    totalItems += 1;
    notifyListeners();
  }

  set removeComment(int commentId) {
    comments.removeWhere((comment) => comment.id == commentId);
    totalItems -= 1;
    notifyListeners();
  }

  // set toggleLike(int id) {
  //   comments = comments.map((comment) {
  //     if (comment.id == id) {
  //       comment.iLike = !comment.iLike;
  //       comment.iLike ? comment.totalLikes += 1 : comment.totalLikes -= 1;
  //     }
  //     return comment;
  //   }).toList();
  // }

  Future<bool> like(Comment comment) async {
    if (comment.id != null)
      try {
        await toggleLike(
            RequestAction.Follow, LikeableType.COMMENT, comment.id!);
        comments = comments.map((_) {
          if (_.id == comment.id) {
            _.iLike = true;
            _.totalLikes += 1;
          }
          return _;
        }).toList();
        notifyListeners();
        return true;
      } catch (error) {
        print(error);
        return false;
      }
    else
      return false;
  }

  Future<bool> unLike(Comment comment) async {
    if (comment.id != null)
      try {
        await toggleLike(
            RequestAction.UnFollow, LikeableType.COMMENT, comment.id!);
        comments = comments.map((_) {
          if (_.id == comment.id) {
            _.iLike = false;
            _.totalLikes -= 1;
          }
          return _;
        }).toList();
        notifyListeners();
        return false;
      } catch (error) {
        return true;
      }
    else
      return true;
  }

  Map<String, dynamic> toMap() {
    return {
      'totalItems': totalItems,
      'comments': comments.map((x) => x.toMap()).toList(),
      'totalPages': totalPages,
      'currentPage': currentPage,
    };
  }

  String toJson() => json.encode(toMap());
}

class StoryResponse extends ChangeNotifier {
  int totalItems;
  List<Story> stories;
  int totalPages;
  int currentPage;

  StoryResponse({
    required this.totalItems,
    required this.stories,
    required this.totalPages,
    required this.currentPage,
  });

  StoryResponse copyWith({
    int? totalItems,
    List<Story>? stories,
    int? totalPages,
    int? currentPage,
  }) {
    return StoryResponse(
      totalItems: totalItems ?? this.totalItems,
      stories: stories ?? this.stories,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  factory StoryResponse.fromMap(Map<String, dynamic> map) {
    return StoryResponse(
      totalItems: map['totalItems']?.toInt() ?? 0,
      stories: List<Story>.from(map['stories']?.map((x) => Story.fromMap(x))),
      totalPages: map['totalPages']?.toInt() ?? 0,
      currentPage: map['currentPage']?.toInt() ?? 0,
    );
  }

  factory StoryResponse.fromJson(String source) =>
      StoryResponse.fromMap(json.decode(source));

  @override
  String toString() {
    return 'StoryResponse(totalItems: $totalItems, stories: $stories, totalPages: $totalPages, currentPage: $currentPage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StoryResponse &&
        other.totalItems == totalItems &&
        listEquals(other.stories, stories) &&
        other.totalPages == totalPages &&
        other.currentPage == currentPage;
  }

  @override
  int get hashCode {
    return totalItems.hashCode ^
    stories.hashCode ^
    totalPages.hashCode ^
    currentPage.hashCode;
  }

  set setStoriesData(StoryResponse newData) {
    // UserPreferences().hiddenListings.then((hiddenListings) {
    // if (currentPage + 1 == newData.currentPage) {
    final totalNewStories = newData.totalItems - totalItems;
    stories = newData.currentPage == 0
        ? newData.stories
        : [
      ...stories,
      ...(totalNewStories > 0 && stories.length > 0
          ? newData.stories.skip(totalNewStories)
          : newData.stories)
    ];
    totalItems = newData.totalItems;
    totalPages = newData.totalPages;
    currentPage = newData.currentPage;
    notifyListeners();
    // }
    // });
  }

  set newStory(Story newStory) {
    stories.insert(0, newStory);
    totalItems += 1;
    notifyListeners();
  }

  set removeStory(int storyId) {
    stories.removeWhere((story) => story.id == storyId);
    totalItems -= 1;
    notifyListeners();
  }

  set viewStory(int id) {
    stories = stories.map((story) {
      if (story.id == id && !story.iViewed) {
        story.totalView += 1;
      }
      return story;
    }).toList();
  }
}

/*class ConfirmData extends ChangeNotifier {

  ConfirmData({
    required this.data,
  });
  List<Datum> data;
  Product product;

  List<Datum> get items {
    product = Product(data: data);
    return [...data];
  }

  void removedata(int index) {
    data.removeAt(index);
    notifyListeners();
  }
}*/













