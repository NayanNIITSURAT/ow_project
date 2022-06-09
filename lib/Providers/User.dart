import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:owlet/Providers/Auth.dart';
import 'package:owlet/Providers/Package.dart';
import 'package:owlet/Screens/NavScreen.dart';
import 'package:owlet/db/chat_user_db.dart';
import 'package:owlet/db/messages_db.dart';
import 'package:owlet/enum.dart';
import 'package:owlet/models/ChatUser.dart';
import 'package:owlet/models/Company.dart';
import 'package:owlet/models/HttpResponse.dart';
import 'package:owlet/models/Listing.dart';
import 'package:owlet/models/Message.dart';
import 'package:owlet/models/Story.dart';
import 'package:owlet/models/Subscription.dart';
import 'package:owlet/models/User.dart';
import 'package:owlet/services/apiUrl.dart';
import 'package:owlet/services/listing.dart';
import 'package:owlet/services/stories.dart';
import 'package:owlet/services/user.dart';

import '../models/Requestuser.dart';

enum FollowType { FOLLOWERS, FOLLOWING }

class UserProvider with ChangeNotifier {
  AuthProvider? authProvider;

  User _profile = User(
    id: 0,
    fullName: '',
    username: '',
    email: '',
    phone: '',
  );
  Status _userProcessStatus = Status.Idle;
  Status _initStatus = Status.Idle;

  UserProvider();

  get initStatus {
    return _initStatus;
  }

  UserProvider update({required AuthProvider auth}) {
    authProvider = auth;
    _initStatus = Status.Processing;
    final user = authProvider?.authProfile;
    if (user != null) {
      _profile = user;
    }
    _initStatus = Status.Completed;
    return this;
  }

  /* ------------------------------------------------------ */
  // Following Section
  /* ------------------------------------------------------ */

  List<User> _usersWithStory = [];

  set usersWithStory(List<User> users) {
    _usersWithStory = users;
    // orderedUsersWithStory();
    notifyListeners();
  }

  List<User> get usersWithStory => _usersWithStory;
  // orderedUsersWithStory() =>
  //     _usersWithStory.sort((a, b) => (a.stories[0] == b.stories[0])
  //         ? 0
  //         : a.stories[0].iViewed
  //             ? 1
  //             : -1);

  int get storyLen => _profile.stories.length;
  bool get hasStory => storyLen > 0;

  set setNewStory(Story newStory) {
    _profile.newStory = newStory;
    notifyListeners();
  }

  /// Update the view status to true if exists. Takes in and [int] value
  set storyViewed(int index) {
    usersWithStory
        .firstWhere((u) => u.stories.any((s) => s.id == index))
        .viewStory = index;
    // orderedUsersWithStory();
    notifyListeners();
  }

  Future addSory({
    required NewStory newStory,
    Function(double value)? onProgress,
    Function()? onSuccess,
    Function(Object? e)? onError,
    Function()? onComplete,
  }) async {
    final cloudinary =
        CloudinaryPublic('cybertech-digitals-ltd', 'theowlet', cache: false);
    try {
      CloudinaryResponse? res;

      if (newStory.type == StoryType.IMAGE || newStory.type == StoryType.VIDEO)
        res = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(newStory.mediaFile!.path),
          onProgress: (count, total) => (onProgress ?? () {})(count / total),
        );

      final story = await createStory(NewStory(
        content:
            newStory.type == StoryType.TEXT ? newStory.content : res!.publicId,
        type: newStory.type,
        caption: newStory.caption,
        duration: newStory.duration,
      ));

      setNewStory = story;
      notifyListeners();
      (onSuccess ?? () {})();
    } catch (e) {
      print(e);
      (onError ?? () {})(e);
    }
    (onComplete ?? () {})();
  }

  Future<dynamic> followUser(User user) async {
    var u = user.username.toLowerCase();

    user.follower = _profile.username;
    notifyListeners();
    final res = await toggleFollow(RequestAction.Follow, user.id);

    if (!res['success'])
      user.unFollower = _profile.username;
    else
      _profile.follows = u;

    notifyListeners();
    return res;
  }


  Future<dynamic> sendUserRequest(User user) async {
    var u = user.username.toLowerCase();

    user.follower = _profile.username;
    notifyListeners();
    final res = await sendRequest(user.id);

    if (!res['success'])
      user.unFollower = _profile.username;
    else
      _profile.follows = u;

    notifyListeners();
    return res;
  }

  Future<dynamic> unFollowRequest(User user) async {
    var u = user.username.toLowerCase();

    user.follower = _profile.username;
    notifyListeners();
    final res = await unfollowRequest(user.id);

    if (!res['success'])
      user.unFollower = _profile.username;
    else
      _profile.follows = u;

    notifyListeners();
    return res;
  }

  Future<dynamic> followUserReqConfirm(int user, int confirm) async {
    notifyListeners();
    final res = await followrequestconfirm(user, confirm);

    // if (!res['success'])
    //   user.unFollower = _profile.username;

    // else
    //   _profile.follows = u;
    //
    // notifyListeners();
    // return res;
  }

  Future<void> _unFollow(User user) async {
    var u = user.username.toLowerCase();

    _profile.unFollows = u;
    user.unFollower = _profile.username;
    usersWithStory =
        _usersWithStory.where((_user) => _user.id != user.id).toList();
    notifyListeners();
  }

  Future<void> unFollow(User user) async {
    await _unFollow(user);
    await toggleFollow(RequestAction.UnFollow, user.id);
    notifyListeners();
  }

  Future<Map<String, dynamic>> getUsersWithStory() async {
    if (_userProcessStatus != Status.Processing)
      try {
        _userProcessStatus = Status.Processing;
        notifyListeners();
        usersWithStory = await fetchUsersStoru();
        _userProcessStatus = Status.Completed;
        notifyListeners();

        return {
          'status': true,
          'message': 'Fetching commpelted',
        };
      } catch (error) {
        _userProcessStatus = Status.Failed;

        return {
          'status': false,
          'message': error.toString(),
          'data': error,
        };
      }
    else {
      _userProcessStatus = Status.Completed;
      return {
        'status': false,
        'message': 'Processing',
      };
    }
  }

  /* ------------------------------------------------------ */
  // Package Subscription Section
  /* ------------------------------------------------------ */
  void subscribe(Package package, {Function(Package)? onComplete}) {
    _profile.subscription = Subscription(
      id: 1,
      status: 'active',
      autorenew: false,
      createdAT: DateTime.now(),
      package: package,
    );
    if (onComplete != null) onComplete(package);
    notifyListeners();
  }

  /* ------------------------------------------------------ */
  // User Profile and Relationships Section
  /* ------------------------------------------------------ */

  set profile(User user) {
    _profile = user;
    notifyListeners();
  }

  Future<Map<String, dynamic>> updateProfileImage(File image) async {
    _userProcessStatus = Status.ChangingAvatar;
    notifyListeners();
    try {
      var res = await updateAvatar(image);
      _profile.updateFromMap = res;

      var result = {
        'status': true,
        'message': 'Update Successfull',
      };

      _userProcessStatus = Status.Completed;
      notifyListeners();

      return result;
    } catch (error) {
      print("the error is ${error.toString()} .detail");

      _userProcessStatus = Status.NotLoggedIn;
      notifyListeners();

      return {
        'status': false,
        'message': error.toString(),
        'data': error,
      };
    }
  }

  bool get isLoggedIn => authProvider?.isLoggedIn ?? false;

  User get profile => _profile;

  get status => _userProcessStatus;

  Future<Map<String, dynamic>> updateProfile(Map<String, String> update) async {
    _userProcessStatus = Status.Processing;
    notifyListeners();
    try {
      var res = await updateUser(update);
      _profile.updateFromMap = res;

      var result = {
        'status': true,
        'message': 'Profile updted',
        'user': profile
      };

      _userProcessStatus = Status.Completed;
      notifyListeners();

      return result;
    } catch (error) {
      print("the error is ${error.toString()} .detail");

      _userProcessStatus = Status.NotLoggedIn;
      notifyListeners();

      return {
        'status': false,
        'message': error.toString(),
        'data': error,
      };
    }
  }

  Future<Map<String, dynamic>> confirmAccount(
      Map<String, String> update) async {
    var result;
    try {
      var res = await confirmUser(update);
      _profile.confirmed = true;

      result = res;

      notifyListeners();
    } catch (error) {
      result = {
        'ok': false,
        'message': error.toString(),
        'data': error,
      };
    }
    return result;
  }

  Future<Map<String, dynamic>> verifyBusiness(
      Map<String, dynamic> data, File cert) async {
    var result;
    try {
      var res = await verifyProfile(data, cert);
      profile.company = Company.fromMap(res['data']);

      result = res;

      notifyListeners();
    } catch (error) {
      result = {
        'ok': false,
        'message': error.toString(),
        'data': error,
      };
    }
    return result;
  }

  set totalNotifications(int val) {
    _profile.totalNotifications = val;
    notifyListeners();
  }

  int get totalNotifications => _profile.totalNotifications;

  Future<Map<String, dynamic>> retrieveProfile(String username) async {
    _userProcessStatus = Status.Processing;
    notifyListeners();
    try {
      User profile = await getProfile(username);
      var result = {
        'status': true,
        'message': 'Login Successful',
        'user': profile
      };

      _userProcessStatus = Status.Completed;
      notifyListeners();

      return result;
    } catch (error) {
      print("the error is $error .detail");

      _userProcessStatus = Status.NotLoggedIn;
      notifyListeners();

      return {
        'status': false,
        'message': error.toString(),
        'data': error,
      };
    }
  }

  void resetFollowData() {
    userFollowingData = UserResponse(
      totalItems: 0,
      users: [],
      totalPages: 0,
      currentPage: -1,
    );
    userFollowersData = UserResponse(
      totalItems: 0,
      users: [],
      totalPages: 0,
      currentPage: -1,
    );
    notifyListeners();
  }

  Status _getFollowingStatus = Status.Idle;
  UserResponse userFollowingData = UserResponse(
    totalItems: 0,
    users: [],
    totalPages: 0,
    currentPage: -1,
  );

  List<User> get userFollowing => userFollowingData.users;
  get getFollowingStatus => _getFollowingStatus;

  Future<Map<String, dynamic>> getUserFollowing(int id,
      {bool refresh: false, String? searchQuery}) async {
    if (_getFollowingStatus != Status.Processing) {
      try {
        _getFollowingStatus = Status.Requesting;
        notifyListeners();

        if (refresh)
          userFollowingData = await fetchUserFollowing(
              id, 0, FollowType.FOLLOWING, searchQuery);
        else
          userFollowingData.updateUsersData = await fetchUserFollowing(
              id,
              userFollowingData.currentPage + 1,
              FollowType.FOLLOWING,
              searchQuery);

        _getFollowingStatus = Status.Completed;
        notifyListeners();

        return {
          'status': true,
          'message': 'Fetching commpelted',
        };
      } catch (error) {
        _getFollowingStatus = Status.Failed;

        return {
          'status': false,
          'message': error.toString(),
          'data': error,
        };
      }
    } else {
      _listingStatus = Status.Completed;
      return {
        'status': false,
        'message': 'Processing',
      };
    }
  }

  Status _getFollowersStatus = Status.Idle;
  UserResponse userFollowersData = UserResponse(
    totalItems: 0,
    users: [],
    totalPages: 0,
    currentPage: -1,
  );

  List<User> get userFollowers => userFollowersData.users;
  get getFollowersStatus => _getFollowersStatus;

  Future<Map<String, dynamic>> getUserFollowers(int id,
      {bool refresh: false, String? searchQuery}) async {
    if (_getFollowersStatus != Status.Processing) {
      try {
        _getFollowersStatus = Status.Requesting;
        notifyListeners();

        if (refresh)
          userFollowersData = await fetchUserFollowing(
              id, 0, FollowType.FOLLOWERS, searchQuery);
        else
          userFollowersData.updateUsersData = await fetchUserFollowing(
              id,
              userFollowersData.currentPage + 1,
              FollowType.FOLLOWERS,
              searchQuery);

        _getFollowersStatus = Status.Completed;
        notifyListeners();

        return {
          'status': true,
          'message': 'Fetching commpelted',
        };
      } catch (error) {
        _getFollowersStatus = Status.Failed;
        notifyListeners();

        return {
          'status': false,
          'message': error.toString(),
          'data': error,
        };
      }
    } else {
      _listingStatus = Status.Completed;
      return {
        'status': false,
        'message': 'Processing',
      };
    }
  }

  Future<Map<String, dynamic>> sendEmailCode({String? type}) async {
    var result;
    try {
      var res = await sendEmailOtp(type ?? 'default');
      result = {
        'status': true,
        'message': res['message'],
      };
    } catch (error) {
      result = {
        'status': false,
        'message': error.toString(),
        'data': error,
      };
    }
    return result;
  }

  Future<Map<String, dynamic>> sendSmsCode({String? type}) async {
    var result;
    try {
      var res = await sendSmsOtp(type ?? 'default');
      result = {
        'status': true,
        'message': res['message'],
      };
    } catch (error) {
      result = {
        'status': false,
        'message': error.toString(),
        'data': error,
      };
    }
    return result;
  }

  /* ------------------------------------------------------ */
  // User Listing
  /* ------------------------------------------------------ */
  ListingResponse listingData = ListingResponse(
    totalItems: 0,
    listings: [],
    totalPages: 0,
    currentPage: -1,
  );

  Status _listingStatus = Status.Idle;

  List<Listing> get listings {
    return [...listingData.listings];
  }

  Status get listingStatus {
    return _listingStatus;
  }

  set toggleLike(int id) {
    listingData.toggleLike = id;
    notifyListeners();
  }

  set newListing(Listing newListing) => listingData.newListing = newListing;
  set updateListing(Listing updatedListing) =>
      listingData.updatedListing = updatedListing;

  Future<Map<String, dynamic>> deleteUserListing(int listingId) async {
    _listingStatus = Status.Deleting;
    notifyListeners();
    try {
      final res = await deleteListing(listingId);

      listingData.removeListing = listingId;
      _profile.reduceTotalListing = listingId;

      _listingStatus = Status.Completed;
      notifyListeners();

      return {
        'message': res['message'],
        'listingId': listingId,
        'status': true,
      };
    } catch (error) {
      print("the error is $error here");

      _listingStatus = Status.Failed;
      notifyListeners();

      return {'message': error.toString(), 'status': false};
    }
  }

  Status _blockingStatus = Status.Idle;

  Status get blockingStatus {
    return _blockingStatus;
  }

  Future<Map<String, dynamic>> blockSeller(User user) async {
    _blockingStatus = Status.Blocking;
    notifyListeners();
    try {
      final res = await blockUser(user.id);
      await _unFollow(user);

      _blockingStatus = Status.Completed;
      notifyListeners();

      return {
        'message': res['message'],
        'userId': user.id,
        'status': true,
      };
    } catch (error) {
      print("the error is $error here");

      _blockingStatus = Status.Failed;
      notifyListeners();

      return {'message': error.toString(), 'status': false};
    }
  }

  Future<Map<String, dynamic>> getListings({bool refresh: false}) async {
    if (_listingStatus != Status.Processing)
      try {
        _listingStatus = Status.Processing;
        notifyListeners();
        if (refresh) {
          listingData = await fetchUserListings(0, profile.username);
        } else {
          if (listingData.totalPages > listingData.currentPage)
            listingData.setListingsData = await fetchUserListings(
                listingData.currentPage + 1, profile.username);
        }
        _listingStatus = Status.Completed;
        notifyListeners();

        return {
          'status': true,
          'message': 'Fetching commpelted',
        };
      } catch (error) {
        _listingStatus = Status.Failed;
        notifyListeners();

        return {
          'status': false,
          'message': error.toString(),
          'data': error,
        };
      }
    else {
      _listingStatus = Status.Completed;
      return {
        'status': false,
        'message': 'Processing',
      };
    }
  }

  List<ChatUser> _chats = [];

  ChatUser? _currentChatUser;

  ChatUser? get curChatUser => _currentChatUser;

  List<ChatUser> get chats {
    sortChat();
    return _chats;
  }

  void sortChat() {
    _chats.sort((a, b) {
      return b.messages.last.id - a.messages.last.id;
    });
  }

  Future<dynamic> deletestory(int storyID) async {

    final res = await deleteStoryapi(storyID);

    if (res['isError']==false){
      _profile.removeStory = storyID;
      notifyListeners();
    }
    //   user.unFollower = _profile.username;

    // else
    //   _profile.follows = u;
    //
    // notifyListeners();
    // return res;
  }

  Future<ChatUser> getChat(ChatUser chat) async {
    ChatUser _newChat;
    if (await ChatDB.instance.hasChatUser(chat.id)) {
      _newChat = await ChatDB.instance.fetchChat(chat.id);
      print('fetched');
    } else {
      _newChat = await ChatDB.instance.create(chat);
      print('created');
      notifyListeners();
    }
    return _newChat;
  }

  Future<Message?> receiveMsg(Message msg) async {
    if (msg.sender != null) {
      final chat = await getChat(msg.sender!.chat);
      final newMsg = msg.copyWith(
        receiverId: profile.id,
        status: ChatState.DELIVERED,
        id: -1,
      );

      final lastMsg = await MessageDB.instance.lastMsg;
      final _msg = lastMsg?.incomingId == newMsg.incomingId
          ? lastMsg
          : await MessageDB.instance.create(newMsg);

      if (_currentChatUser != null &&
          !_currentChatUser!.messages.any((_) => _.id == _msg!.id))
        _currentChatUser?.messages.add(_msg!);

      final idxOfChat = _chats.indexWhere((_) => _.id == chat.id);
      if (idxOfChat == -1) {
        if (!chat.messages.any((_) => _.id == _msg!.id))
          chat.messages.add(_msg!);
        if (!_chats.any((_) => _.id == chat.id)) _chats.add(chat);
      } else if (!_chats[idxOfChat].messages.any((_) => _.id == _msg!.id))
        _chats[idxOfChat].messages.add(_msg!);

      notifyListeners();
      return _msg;
    }
    return null;
  }

  Future<dynamic> unFollowUser(User user) async {
    var u = user.username.toLowerCase();

    user.unFollower = _profile.username;
    notifyListeners();
    final res = await unfollowRequest(user.id);

    if (!res['success'])
      user.unFollower = _profile.username;
    else
      _profile.unFollows = u;

    notifyListeners();
    return res;
  }
  set receiveOfflineChats(Iterable<ChatUser> chatList) {
    chatList.forEach((chat) async {
      final _chat = await getChat(chat.copyWith(
          avartar: '${AppUrl.profileImageBaseUrl}${chat.avartar}'));
      final newMsgs = chat.messages;
      final _msgs = await MessageDB.instance.bulkCreate(newMsgs);
      if (_currentChatUser != null) _currentChatUser?.messages.addAll(_msgs);

      print(_msgs);
      print(newMsgs);
      final idxOfChat = _chats.indexWhere((_) => _.id == _chat.id);
      if (idxOfChat == -1) {
        _chat.messages.addAll(_msgs);
        _chats.add(_chat);
      } else
        chats[idxOfChat].messages.addAll(_msgs);
      // }
      notifyListeners();
    });
  }


  Future<dynamic> deletestory(int storyID) async {

    final res = await deleteStoryapi(storyID);

    if (res['isError']==false){
      _profile.removeStory = storyID;
      notifyListeners();
    }
    //   user.unFollower = _profile.username;

    // else
    //   _profile.follows = u;
    //
    // notifyListeners();
    // return res;
  }

  Future<Message?> sendMsg(Message msg) async {
    if (_currentChatUser != null) {
      final chat = await getChat(_currentChatUser!);
      final newMsg = msg.copyWith(
        receiverId: chat.id,
        senderId: _profile.id,
        time: DateTime.now().toIso8601String(),
      );

      final _msg = await MessageDB.instance.create(newMsg);
      if (_currentChatUser != null &&
          !_currentChatUser!.messages.any((_) => _.id == _msg.id)) {
        _currentChatUser?.messages.add(_msg);
      }

      final idxOfChat = _chats.indexWhere((_) => _.id == chat.id);
      if (idxOfChat == -1) {
        if (!chat.messages.any((_) => _.id == _msg.id)) chat.messages.add(_msg);
        if (!_chats.any((_) => _.id == chat.id)) _chats.add(chat);
      } else if (!_chats[idxOfChat].messages.any((_) => _.id == _msg.id))
        _chats[idxOfChat].messages.add(_msg);

      notifyListeners();
      return _msg;
    }
    return null;
  }

  set curChatUser(ChatUser? user) {
    if (user != null) _currentChatUser = user;
    notifyListeners();
  }

  set curChatLastSeen(int? lastSeen) {
    if (curChatUser != null) if (lastSeen != null) {
      curChatUser?.lastSeen = DateTime.fromMillisecondsSinceEpoch(lastSeen);
      curChatUser?.isOnline = false;
    } else {
      curChatUser?.isOnline = true;
      curChatUser?.lastSeen = DateTime.now();
    }
    notifyListeners();
  }

  set userOffline(int id) {
    if (_chats.indexWhere((_) => _.id == id) > -1)
      _chats = _chats
          .map((e) => e.id == id
              ? e.copyWith(lastSeen: DateTime.now(), isOnline: false)
              : e)
          .toList();

    if (curChatUser != null && curChatUser?.id == id)
      _currentChatUser =
          _currentChatUser?.copyWith(lastSeen: DateTime.now(), isOnline: false);
    notifyListeners();
  }

  set userOnline(int id) {
    if (_chats.indexWhere((_) => _.id == id) > -1)
      _chats = _chats
          .map((e) => e.id == id
              ? e.copyWith(lastSeen: DateTime.now(), isOnline: true)
              : e)
          .toList();

    if (curChatUser != null && curChatUser?.id == id)
      _currentChatUser =
          _currentChatUser?.copyWith(lastSeen: DateTime.now(), isOnline: true);
    notifyListeners();
  }

  set onlineUsers(List<dynamic> userIds) {
    _chats = _chats
        .map((e) => userIds.contains(e.id)
            ? e.copyWith(lastSeen: DateTime.now(), isOnline: true)
            : e)
        .toList();

    notifyListeners();
  }

  void updateChatState(int senderId, ChatState state) {
    print('=============== Updating Chat State =================');
    final idxOfChat = _chats.indexWhere((_) => _.id == senderId);
    if (idxOfChat > -1) {
      _chats[idxOfChat].messages = _chats[idxOfChat]
          .messages
          .map((_) => _.copyWith(status: state))
          .toList();
      notifyListeners();

      MessageDB.instance.updateChatStatus(state, senderId);
    }
  }

  void set msgSeen(Message msg) {
    MessageDB.instance.update(msg.copyWith(status: ChatState.SEEN));
    notifyListeners();
  }

  void set msgDelivered(Message msg) {
    MessageDB.instance.update(msg.copyWith(status: ChatState.DELIVERED));
    notifyListeners();
  }

  void set msgSent(Message msg) {
    MessageDB.instance.update(msg.copyWith(status: ChatState.SENT));
    notifyListeners();
  }

  bool get hasUnreadMsgs => _chats
      .any((_) => _.messages.any((__) => __.status == ChatState.DELIVERED));

  Future<int> get unreadMsgsCount async =>
      await MessageDB.instance.totalUnreadMsgs(profile.id);

  loadChats({bool refresh: false, String? q}) async {
    // await ChatDB.instance.deleteDb();
    // await ChatDB.instance.fetchTables();
    // await ChatDB.instance.database;
    try {
      _chats =
          await ChatDB.instance.fetchChats(searchParam: q, userId: profile.id);

      final chatids = _chats.map((e) => e.id).toList();
      socket.emitWithAck('refresh', chatids, ack: (Map<String, dynamic> data) {
        print(data);
        final mapOfflineChats = data['offlineChats'] as List;
        if (mapOfflineChats.isNotEmpty) {
          print(mapOfflineChats);
          receiveOfflineChats =
              mapOfflineChats.map((chat) => ChatUser.fromMap(chat));

          socket.emit('messages-delivered');
        }
        onlineUsers = data['onlineIds'];
      });

      notifyListeners();
    } catch (error) {
      print(error);
    }
  }
}
