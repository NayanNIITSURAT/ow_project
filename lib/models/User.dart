import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:owlet/Providers/Package.dart';
import 'package:owlet/enum.dart';
import 'package:owlet/models/ChatUser.dart';
import 'package:owlet/models/Company.dart';
import 'package:owlet/models/Listing.dart';
import 'package:owlet/models/Message.dart';
import 'package:owlet/models/Story.dart';
import 'package:owlet/models/Subscription.dart';
import 'package:owlet/services/apiUrl.dart';
import 'package:owlet/services/utils.dart';

class NewMessage {
  final String content;
  final int? parentId;
  final int? listingId;
  final int? senderId;
  final int? receiverId;
  final int? story;
  final User? sender;
  final String? time;
  NewMessage({
    required this.content,
    this.parentId,
    this.listingId,
    this.senderId,
    this.receiverId,
    this.story,
    this.sender,
    this.time,
  });
}

class User with ChangeNotifier {
  final int id;
  String fullName;
  String username;
  String? fname;
  String? lname;
  String? country;
  String? email;
  String avartar;
  String? phone;
  String? website;
  bool private;
  bool confirmed;
  bool iFollow;

  dynamic whatsapp;
  bool isOnline;
  bool isAdmin;
  bool hasVerifiedCompany;
  bool hasPendingLoan;
  String? bio;
  int totalFollowers;
  int totalFollowing;
  List<Listing> listings;
  List<Story> stories;
  // StoryResponse? storiesData;
  Subscription? subscription;
  Company? company;
  // String type;
  String token;
  int totalListing;
  int totalNotifications;
  String renewalToken;
  String? lastSeen;
  String joinedAt;
  List<Message> messages;

  User({
    required this.id,
    required this.username,
    this.fullName: '',
    this.fname,
    this.lname,
    this.country,
    this.avartar: AppUrl.profileImageBaseUrl + 'avatar_2.jpeg',
    this.email,
    this.phone,
    this.whatsapp,
    this.bio,
    this.isOnline: false,
    this.isAdmin: false,
    this.hasVerifiedCompany: false,
    this.hasPendingLoan: false,
    this.private: false,
    this.confirmed: false,
    this.iFollow: false,
    this.subscription,
    this.totalFollowers: 0,
    this.totalFollowing: 0,
    this.listings: const [],
    this.stories: const [],
    // this.storiesData,
    this.token: '',
    this.totalListing: 0,
    this.totalNotifications: 0,
    this.website,
    this.company,
    this.renewalToken: '',
    this.lastSeen,
    this.joinedAt: '',
    this.messages: const [],
  });

  set setToken(String token) {
    token = token;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['fullName'],
      avartar:
      AppUrl.profileImageBaseUrl + (json['avartar'] ?? 'avatar_2.jpeg'),
      username: json['username'],
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      fname: json['fname'] ?? '',
      lname: json['lname'] ?? '',
      bio: json['bio'],
      website: json['website'],
      private: json['private'],
      confirmed: json['confirmed'],
      totalListing: json['totalListing'],
      totalNotifications: json['totalNotifications'],
      subscription: json['subscription'] != null
          ? Subscription.fromJson(json['subscription'])
          : Subscription(
          id: 1,
          status: 'Active',
          autorenew: true,
          createdAT: DateTime.now(),
          package: Package(id: 1, name: 'Basic', price: 0, features: [''])),
      // // type: json['type'],
      listings: json['listings'] != null
          ? List.from(json['listings']).map((e) => Listing.fromJson(e)).toList()
          : [],
      // storiesData: json['stories'] != null
      //     ? StoryResponse.fromMap(json['replyData'])
      //     : StoryResponse(
      //         totalItems: 0,
      //         stories: [],
      //         totalPages: 0,
      //         currentPage: -1,
      //       ),
      stories: List<Story>.from(
          (json['stories'] ?? []).map((x) => Story.fromMap(x))),
      totalFollowers: json['totalFollowers'],
      totalFollowing: json['totalFollowing'],
      token: json['token'],
      isAdmin: json['isAdmin'],
      iFollow: json['iFollow'] == 1 ? true : false,

      hasPendingLoan: json['hasPendingLoan'] == 1 ? true : false,
      hasVerifiedCompany: json['company'] == null
          ? false
          : json['company']['verifiedAt'] != null,
      company:
      json['company'] == null ? null : Company.fromMap(json['company']),

      joinedAt: json['createdAt'] != null
          ? DateFormat('yyyy-MM-dd kk:mm:ss')
          .format(DateTime.parse(json['createdAt']).toLocal())
          : DateTime.now().toString(),
      lastSeen: json['lastQueryAT'] != null
          ? DateFormat('yyyy-MM-dd kk:mm:ss')
          .format(DateTime.parse(json['lastSeenAT']).toLocal())
          : DateTime.now().toString(),
      // chatBuddies: List<User>.from(
      //     (json['chatBuddies'] ?? []).map((x) => User.fromJson(x))),
      messages: List<Message>.from(
          (json['messages'] ?? []).map((x) => Message.fromMap(x))),
    );
  }

  set updateFromMap(Map<String, dynamic> map) {
    if (map['fullName'] != null) fullName = map['fullName'];
    if (map['username'] != null) username = map['username'];
    if (map['phone'] != null) phone = map['phone'];
    if (map['bio'] != null) bio = map['bio'];
    if (map['website'] != null) website = map['website'];
    if (map['avartar'] != null)
      avartar = AppUrl.profileImageBaseUrl + map['avartar'];
    // if(json['email'] != null) email = json['email'];
  }

  User copyWith({
    int? id,
    String? fullName,
    String? username,
    String? fname,
    String? lname,
    String? country,
    String? email,
    String? avartar,
    String? phone,
    String? website,
    bool? private,
    bool? confirmed,
    bool? iFollow,
    dynamic? whatsapp,
    bool? isOnline,
    bool? isAdmin,
    bool? hasVerifiedCompany,
    bool? hasPendingLoan,
    String? bio,
    int? totalFollowers,
    int? totalFollowing,
    List<Listing>? listings,
    List<Story>? stories,
    Subscription? subscription,
    Company? company,
    String? token,
    int? totalListing,
    int? totalNotifications,
    String? renewalToken,
    String? lastSeen,
    String? joinedAt,
    List<User>? chatBuddies,
    List<Message>? messages,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      fname: fname ?? this.fname,
      lname: lname ?? this.lname,
      country: country ?? this.country,
      email: email ?? this.email,
      avartar: avartar ?? this.avartar,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      private: private ?? this.private,
      confirmed: confirmed ?? this.confirmed,
      iFollow: iFollow ?? this.iFollow,
      whatsapp: whatsapp ?? this.whatsapp,
      isOnline: isOnline ?? this.isOnline,
      isAdmin: isAdmin ?? this.isAdmin,
      hasVerifiedCompany: hasVerifiedCompany ?? this.hasVerifiedCompany,
      hasPendingLoan: hasPendingLoan ?? this.hasPendingLoan,
      bio: bio ?? this.bio,
      totalFollowers: totalFollowers ?? this.totalFollowers,
      totalFollowing: totalFollowing ?? this.totalFollowing,
      listings: listings ?? this.listings,
      stories: stories ?? this.stories,
      subscription: subscription ?? this.subscription,
      company: company ?? this.company,
      token: token ?? this.token,
      totalListing: totalListing ?? this.totalListing,
      totalNotifications: totalNotifications ?? this.totalNotifications,
      renewalToken: renewalToken ?? this.renewalToken,
      lastSeen: lastSeen ?? this.lastSeen,
      joinedAt: joinedAt ?? this.joinedAt,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'username': username,
      'fname': fname,
      'lname': lname,
      'country': country,
      'email': email,
      'avartar': avartar,
      'phone': phone,
      'website': website,
      'private': private,
      'confirmed': confirmed,
      'iFollow': iFollow,
      'whatsapp': whatsapp,
      'isOnline': isOnline,
      'isAdmin': isAdmin,
      'hasVerifiedCompany': hasVerifiedCompany,
      'hasPendingLoan': hasPendingLoan,
      'bio': bio,
      'totalFollowers': totalFollowers,
      'totalFollowing': totalFollowing,
      'stories': stories.map((x) => x.toMap()).toList(),
      'company': company?.toMap(),
      'token': token,
      'totalListing': totalListing,
      'totalNotifications': totalNotifications,
      'renewalToken': renewalToken,
      'lastSeen': lastSeen,
      'joinedAt': joinedAt,
      'messages': messages.map((x) => x.toMap()).toList(),
    };
  }

  Map<String, dynamic> toJason(User user) {
    return {
      'id': user.id,
      'fullName': user.fullName,
      'username': user.username,
      'fname': user.fname,
      'lname': user.lname,
      'country': user.country,
      'email': user.email,
      'avartar': user.avartar,
      'phone': user.phone,
      'website': user.website,
      'private': user.private,
      'confirmed': user.confirmed,
      'iFollow': user.iFollow,
      'whatsapp': user.whatsapp,
      'isOnline': user.isOnline,
      'isAdmin': user.isAdmin,
      'hasVerifiedCompany': user.hasVerifiedCompany,
      'hasPendingLoan': user.hasPendingLoan,
      'bio': user.bio,
      'totalFollowers': user.totalFollowers,
      'totalFollowing': user.totalFollowing,
      'stories': user.stories.map((x) => x.toMap()).toList(),
      'company': user.company?.toMap(),
      'token': user.token,
      'totalListing': user.totalListing,
      'totalNotifications': user.totalNotifications,
      'renewalToken': user.renewalToken,
      'lastSeen': user.lastSeen,
      'joinedAt': user.joinedAt,
      'messages': user.messages.map((x) => x.toMap()).toList(),
    };
  }

  String encode(List<User> user) => json.encode(
    user.map<Map<String, dynamic>>((user) => toJason(user)).toList(),
  );

  static List<User> decode(String musics) =>
      (json.decode(musics) as List<dynamic>)
          .map<User>((item) => User.fromJson(item))
          .toList();

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toInt() ?? 0,
      fullName: map['fullName'] ?? '',
      username: map['username'] ?? '',
      fname: map['fname'],
      lname: map['lname'],
      country: map['country'],
      email: map['email'],
      avartar: map['avartar'] ?? '',
      phone: map['phone'],
      website: map['website'],
      private: map['private'] ?? false,
      confirmed: map['confirmed'] ?? false,
      iFollow: map['iFollow'] ?? false,
      whatsapp: map['whatsapp'] ?? null,
      isOnline: map['isOnline'] ?? false,
      isAdmin: map['isAdmin'] ?? false,
      hasVerifiedCompany: map['hasVerifiedCompany'] ?? false,
      hasPendingLoan: map['hasPendingLoan'] ?? false,
      bio: map['bio'],
      totalFollowers: map['totalFollowers']?.toInt() ?? 0,
      totalFollowing: map['totalFollowing']?.toInt() ?? 0,
      listings: map['listings'] == null
          ? []
          : List<Listing>.from(
          map['listings']?.map((x) => Listing.fromJson(x))),
      stories:
      List<Story>.from((map['stories'] ?? []).map((x) => Story.fromMap(x))),
      subscription: map['subscription'] != null
          ? Subscription.fromJson(map['subscription'])
          : null,
      company: map['company'] != null ? Company.fromMap(map['company']) : null,
      token: map['token'] ?? '',
      totalListing: map['totalListing']?.toInt() ?? 0,
      totalNotifications: map['totalNotifications']?.toInt() ?? 0,
      renewalToken: map['renewalToken'] ?? '',
      lastSeen: map['lastSeen'] ?? '',
      joinedAt: map['joinedAt'] ?? '',
      messages: List<Message>.from(
          (map['messages'] ?? []).map((x) => Message.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'User(id: $id, fullName: $fullName, username: $username, fname: $fname, lname: $lname, country: $country, email: $email, avartar: $avartar, phone: $phone, website: $website, private: $private, confirmed: $confirmed, iFollow: $iFollow, whatsapp: $whatsapp, isOnline: $isOnline, isAdmin: $isAdmin, hasVerifiedCompany: $hasVerifiedCompany, hasPendingLoan: $hasPendingLoan, bio: $bio, totalFollowers: $totalFollowers, totalFollowing: $totalFollowing, listings: $listings, stories: $stories, subscription: $subscription, company: $company, token: $token, totalListing: $totalListing, totalNotifications: $totalNotifications, renewalToken: $renewalToken, lastSeen: $lastSeen, joinedAt: $joinedAt, messages: $messages)';
  }

  ChatUser get chat => ChatUser(
    id: id,
    username: username,
    avartar: avartar,
    confirmed: confirmed,
    iFollow: iFollow,
    isOnline: isOnline,
    hasVerifiedCompany: hasVerifiedCompany,
    lastSeen: DateTime.parse(lastSeen ?? DateTime.now().toString()),
  );

  set follower(String follower) {
    if (totalFollowers != null) totalFollowers += 1;
    iFollow = true;
    notifyListeners();
  }

  set follows(String user) {
    totalFollowing += 1;
    notifyListeners();
  }

  set unFollower(String follower) {
    totalFollowers -= 1;
    iFollow = false;
    notifyListeners();
  }

  set unFollows(String user) {
    totalFollowing -= 1;
    notifyListeners();
  }

  set reduceTotalListing(listingId) => totalListing -= 1;

  set newStory(Story newStory) {
    stories.insert(0, newStory);
    notifyListeners();
  }

  set removeStory(int storyId) {
    stories.removeWhere((story) => story.id == storyId);
    notifyListeners();
  }

  set viewStory(int id) {
    stories = stories.map((story) {
      if (story.id == id && !story.iViewed) {
        story.iViewed = true;
        story.totalView += 1;
        view(ViewableType.STORY, id)
            .then((value) => print(value))
            .catchError((onError) => print(onError));
      }
      return story;
    }).toList();
    notifyListeners();
  }

  set addNewMessage(NewMessage msg) {
    final newMsg = Message(
      id: -1,
      content: msg.content,
      sender: msg.sender,
    );
    messages.add(newMsg);
    notifyListeners();
    // return newMsg;
  }

// get hasUnseenStory => stories.any((_) => !_.iViewed);
// get totalStories => stories..length;
// get orderStories => stories.sort((a, b) => (a.iViewed == b.iViewed)
//     ? 0
//     : a.iViewed
//         ? 1
//         : -1);
}
