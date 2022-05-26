import 'package:flutter/material.dart';
import 'package:owlet/Components/Toast.dart';
import 'package:owlet/Providers/Auth.dart';
import 'package:owlet/Providers/HashTagProvider.dart';
import 'package:owlet/Providers/Listing.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Providers/UtilsProvider.dart';
import 'package:owlet/Screens/Login.dart';
import 'package:owlet/models/HttpResponse.dart';
import 'package:owlet/models/User.dart';
import 'package:owlet/services/listing.dart';
import 'package:provider/provider.dart';

import '../Preferences/UserPreferences.dart';

class InitData {
  ListingResponse listingData;
  List<User> topFollowing;
  InitData({required this.listingData, required this.topFollowing});

  factory InitData.fromJson(Map<String, dynamic> json) {
    // print(json['users'][10]);
    return InitData(
      listingData: ListingResponse.fromJson(json['listingsData']),
      topFollowing:
          List.from(json['users']).map((e) => User.fromJson(e)).toList(),
    );
  }
}

enum ListingProviderType {
  USER,
  LISTING,
  HASHTAG,
  SELLER,
  SEARCHLISTING,
}

class GlobalProvider with ChangeNotifier {
  BuildContext context;
  GlobalProvider(this.context);

  GlobalProvider inti() {
    return this;
  }

  set toggleLikeListing(int id) {
    Provider.of<UtilsProvider>(context, listen: false).toggleLike = id;
    Provider.of<ListingProvider>(context, listen: false).toggleLike = id;
    Provider.of<HashTagProvider>(context, listen: false).toggleLike = id;
    Provider.of<UserProvider>(context, listen: false).toggleLike = id;
  }

  UserProvider get userProvider =>
      Provider.of<UserProvider>(context, listen: false);
  UtilsProvider get utilsProvider => Provider.of<UtilsProvider>(context);
  HashTagProvider get tagProvider => Provider.of<HashTagProvider>(context);
  AuthProvider get authProvider => Provider.of<AuthProvider>(context);
  AuthProvider get authProListenFalse =>
      Provider.of<AuthProvider>(context, listen: false);
  ListingProvider get listingProvider =>
      Provider.of<ListingProvider>(context, listen: false);

  Status _initStatus = Status.Idle;
  Status get initStatus => _initStatus;

  initMarketData() async {
    await fetchInitData('market').then((res) {
      userProvider.usersWithStory = res.topFollowing;
      listingProvider.listingData.setListingsData = res.listingData;
    }).catchError((onError) {
      Toast(
        context,
        message: onError.toString() + ', kindly restart',
        type: ToastType.ERROR,
      ).showTop();
      print(onError.toString());
      _initStatus = Status.Failed;
      notifyListeners();
    });
  }

  initFollowingData() async {
    await listingProvider.getListingsForMe(refresh: true);
    await userProvider.getListings(refresh: true);
    await userProvider.loadChats(refresh: true);
  }

  logOut() async {
    UserPreferences().removeUser();
      await initMarketData();
      Navigator.pushNamedAndRemoveUntil(
          context, LoginScreen.routeName, (route) => false);

  }

  Future loadData() async {
    final auth = authProListenFalse;
    await initMarketData();
    if (auth.isLoggedIn) initFollowingData();
  }
}
