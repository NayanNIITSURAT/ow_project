import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:owlet/Components/Toast.dart';
import 'package:owlet/Providers/GlobalProvider.dart';
import 'package:owlet/Screens/NavScreen.dart';
import 'package:owlet/Screens/Register.dart';
import 'package:owlet/Widgets/CustomAppBar.dart';
import 'package:owlet/constants/images.dart';

import '../../Components/bottomsheetbutton.dart';
import '../../Preferences/UserPreferences.dart';
import '../../constants/constants.dart';
import '../../constants/palettes.dart';
import '../../models/User.dart';
import '../../services/utils.dart';
import '../Login.dart';
import 'AboutScreen.dart';
import 'HelpScreen.dart';
import 'PrivacyScreen.dart';
import 'SecurityScreen.dart';
import 'WalletScreen.dart';
import 'followAndInviteDetails.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settingsScreen';

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SettingsScreenState();
  }
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isload = false;
  bool check = false;

  @override
  Widget build(BuildContext context) {
    final globalProvider = GlobalProvider(context);





    void doLogout() {
      socket.dispose();
      globalProvider.logOut();
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppBar(),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FollowAndInviteDetailsScreen()));
              },
              leading: Icon(Icons.person_add_alt_1_outlined),
              title: Text("Follow and invite friends"),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.black54,
              ),
            ),
            ListTile(
                leading: Icon(Icons.notifications_none_outlined),
                title: Text("Notifications"),
                trailing: Container(
                  width: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      isload == true
                          ? SizedBox(
                              height: 20, child: CupertinoActivityIndicator())
                          : SizedBox.shrink(),
                      Container(
                        child: CupertinoSwitch(
                            thumbColor: Colors.black54,
                            value: check,
                            activeColor: kPrimaryColor,
                            onChanged: (value) {
                              setState(() {
                                isload = true;

                                check = value;
                              });
                              callapi();
                            }),
                      ),
                    ],
                  ),
                )),
            ListTile(
              leading: Icon(Icons.account_balance_wallet_outlined),
              title: Text("Wallet"),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.black54,
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => WalletScreen()));
              },
            ),
            ListTile(
              leading: SvgPicture.asset(privacy_icon),
              title: Text("Privacy"),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.black54,
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PrivacyScreen()));
              },
            ),
            ListTile(
              leading: SvgPicture.asset(security_icon),
              title: Text("Security"),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.black54,
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Security()));
              },
            ),
            ListTile(
              leading: SvgPicture.asset(help_icon),
              title: Text("Help"),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.black54,
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HelpScren()));
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text("About"),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.black54,
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AboutScren()));
              },
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                      onPressed: () {
                        _modalBottomSheetMenu();
                      },
                      child: Text(
                        "Add Account",
                        style: TextStyle(fontSize: 16),
                      )),
                  TextButton(
                      onPressed: () {
                        doLogout();
                      },
                      child: Text(
                        "Log out",
                        style: TextStyle(fontSize: 16),
                      )),TextButton(
                      onPressed: () {
                        switch_account_bottom_sheet();
                      },
                      child: Text(
                        "Switch Account",
                        style: TextStyle(fontSize: 16),
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _modalBottomSheetMenu() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25),
          ),
        ),
        context: context,
        builder: (context) => Container(
              height: 230,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20)),
                    height: 3,
                    width: 80,
                  ),
                  Text(
                    "Add Account",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  bottomsheetbutton(
                    text: 'Log in to Existing Account',
                    press: () {
                      // Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (r) => false);
                      Navigator.pushNamed(context, LoginScreen.routeName);
                    },
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, RegisterScreen.routeName, (r) => false);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        "Create New Account",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ));
  }
  Future<void> switch_account_bottom_sheet() async {
    List<User> userspref=[];
    var preferenceuserlist = await UserPreferences().getuserlist();
    if (preferenceuserlist != null && preferenceuserlist.isNotEmpty) {
       userspref = User.decode(preferenceuserlist);
      print("settings data"+userspref.length.toString());
      // for (int i = 0; i < userspref.length; i++) {
      //   if (userspref[i].id == user.id) {
      //     userspref[i] = user;
      //     print(user.username);
      //   } else {
      //     userspref.add(user);
      //     print("newuseradded");
      //     print(user.username);
      //   }
      // }
    }

    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25),
          ),
        ),
        context: context,
        builder: (context) => Container(
              height: 230,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20)),
                    height: 2,
                    width: 80,
                  ),
                  Text(
                    "switch Account",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Container(
                    height: 150,
                    child: ListView.builder(
                      itemCount: userspref.length,
                      itemBuilder: (context, position) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              userspref[position].id.toString(),
                              style: TextStyle(fontSize: 10 , color: Colors.black),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // bottomsheetbutton(
                  //   text: 'Log in to Existing Account',
                  //   press: () {
                  //     // Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (r) => false);
                  //     Navigator.pushNamed(context, LoginScreen.routeName);
                  //   },
                  // ),
                  // InkWell(
                  //   onTap: () {
                  //     Navigator.pushNamedAndRemoveUntil(
                  //         context, RegisterScreen.routeName, (r) => false);
                  //   },
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(5.0),
                  //     child: Text(
                  //       "Create New Account",
                  //       style: TextStyle(
                  //         color: Colors.red,
                  //         fontWeight: FontWeight.w500,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ));
  }

  callapi() async {
    var onoff = "";
    if (check) {
      onoff = "on";
    }
    else
    {
      onoff = "off";
    }

    Map<String, dynamic> getdatamodel = await on_off_notification(onoff);
    if (!getdatamodel['isError']) {
      var data = getdatamodel['response'];
      var mesg = data['message'];
      Toast(
        context,
        message: mesg,
        duration: Duration(milliseconds: 100),
        type: ToastType.SUCCESS,
      ).showTop();
      setState(() {
        isload = false;
      });
    } else {
      var data = getdatamodel['response'];
      var mesg = data['message'];

      Toast(
        context,
        message: mesg,
        duration: Duration(milliseconds: 100),
        type: ToastType.ERROR,
      ).showTop();
      setState(() {
        isload = false;});
      // throw HttpException(data['message']);
    }
  }
  // new
  // callapi() async {
  //   var onof = "";
  //   if (check) {
  //     onof = "on";
  //   } else {
  //     onof = "off";
  //   }
  //   final userid=await getuserid;
  //   final headers = Global.jsonHeaders;
  //   headers
  //       .addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  //   final response = await http.get(
  //     Uri.parse(
  //         'https://api.the-owlette.com/v4/users/notificationUpdate?userId=$userid&value=$onof'),
  //     headers: headers,
  //   );
  //   if (response.statusCode == 200) {
  //     var data = jsonDecode(response.body);
  //     var mesg = data['message'];
  //
  //     Toast(
  //       context,
  //       message: mesg,
  //       duration: Duration(milliseconds: 100),
  //       type: ToastType.SUCCESS,
  //     ).showTop();
  //     setState(() {
  //       isload = false;
  //     });
  //   } else {
  //     var data = jsonDecode(response.body);
  //     var mesg = data['message'];
  //     Toast(
  //       context,
  //       message: mesg,
  //       duration: Duration(milliseconds: 100),
  //       type: ToastType.ERROR,
  //     ).showTop();
  //     setState(() {
  //       isload = false;
  //     });
  //     throw HttpException(data['message']);
  //   }
  // }
}
