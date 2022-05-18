import 'package:flutter/material.dart';
import 'package:owlet/models/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences extends ChangeNotifier {
  static SharedPreferences? _prefs;

  Future<void> init() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  Future saveUser(User user) async {
    _prefs!.setInt("userId", user.id);
    _prefs!.setString("avartar", user.avartar);
    _prefs!.setString("fullName", user.fullName);
    _prefs!.setString("email", user.email ?? '');
    _prefs!.setString("phone", user.phone ?? '');
    _prefs!.setString("token", user.token);
    // _prefs!.setString("type", user.type);
    // _prefs!.setString("renewalToken", user.renewalToken);
  }

  Future get registerAppToDevice async {
    _prefs!.setBool("isRegistered", true);
  }

  Future<bool> get isDeviceRegistered async {
    bool isReg = _prefs!.getBool("isRegistered") ?? false;
    // _prefs!.setBool("isRegistered", false);
    return isReg;
  }

  hideListing(int listingId) {
    SharedPreferences.getInstance().then((_prefs) {
      List<String> hiddenListings =
          _prefs.getStringList("hiddenListings") ?? [];
      // _prefs!.setBool("isRegistered", false);
      hiddenListings.add(listingId.toString());
      _prefs.setStringList('hiddenListings', hiddenListings);
    });
    notifyListeners();
  }

  unHideListing(int listingId) {
    SharedPreferences.getInstance().then((_prefs) {
      List<String> hiddenListings =
          _prefs.getStringList("hiddenListings") ?? [];
      // _prefs!.setBool("isRegistered", false);
      hiddenListings.remove(listingId.toString());
      _prefs.setStringList('hiddenListings', hiddenListings);
    });
  }

  unHideAllListing() {
    SharedPreferences.getInstance().then((_prefs) {
      _prefs.setStringList("hiddenListings", []);
    });
  }

  Future<List> get hiddenListings async {
    List<String> hiddenListings = _prefs!.getStringList("hiddenListings") ?? [];

    return hiddenListings;
  }

  Future<User> get getUser async {
    int id = (_prefs!.getInt("userId") ?? 0);
    String fullName = (_prefs!.getString("fullName") ?? '');
    String username = (_prefs!.getString("username") ?? '');
    String avartar = (_prefs!.getString("avartar") ?? '');
    String email = (_prefs!.getString("email") ?? '');
    String phone = (_prefs!.getString("phone") ?? '');
    String token = (_prefs!.getString("token") ?? '');
    // String type = (_prefs!.getString("type") ?? '');
    // String renewalToken = (_prefs!.getString("renewalToken") ?? '');

    return User(
      id: id,
      avartar: avartar,
      fullName: fullName,
      email: email,
      phone: phone,
      token: token,
      username: username,
      // type: type,
      // renewalToken: renewalToken,
    );
  }

  void removeUser() async {
    _prefs!.remove("fullName");
    _prefs!.remove("email");
    _prefs!.remove("phone");
    _prefs!.remove("type");
    _prefs!.remove("token");
  }

  Future<String> get token async {
    String token = (_prefs!.getString("token") ?? '');
    return token;
  }
}
