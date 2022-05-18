import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:owlet/Components/CircleButton.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Screens/Login.dart';
import 'package:owlet/Screens/NotificationScreen.dart';
import 'package:owlet/Screens/SearchScreen.dart';
import 'package:owlet/constants/images.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../Screens/ChatListScreen.dart';

class CustomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<UserProvider>(
        builder: (_, userData, __) {
          final hasAlert = userData.profile.totalNotifications > 0;
          return VStack([
            HStack(
              [
                Expanded(
                  child: Image.asset(
                    logo,
                    height: 40,
                    alignment: Alignment.centerLeft,
                  ),
                ),
                CircleButton(
                  iconSize: 22,
                  bgColor: Colors.transparent,
                  margin: EdgeInsets.all(7),
                  onPressed: () =>
                      Navigator.pushNamed(context, ChatListScreen.routeName),
                  imageIcon: true,
                  imagePath: chat,
                  color: Colors.grey,
                ),
                CircleButton(
                  iconSize: 22,
                  bgColor: Colors.transparent,
                  margin: EdgeInsets.all(7),
                  onPressed: () =>
                      Navigator.pushNamed(context, SearchScreen.routeName),
                  imageIcon: true,
                  imagePath: search,
                  color: Colors.grey,
                ),
                !hasAlert
                    ? Center(
                        child: Stack(
                          children: [
                            CircleButton(
                              iconSize: 22,
                              bgColor: Colors.transparent,
                              margin: EdgeInsets.all(7),
                              onPressed: () => Navigator.pushNamed(
                                  context,
                                  userData.isLoggedIn
                                      ? NotificationScreen.routeName
                                      : LoginScreen.routeName),
                              // Navigator.pushNamed(context, ChatListScreen.routeName),
                              imageIcon: true,
                              imagePath: notification,

                              color: Colors.grey,
                            ),
                            Positioned(
                                top: 5,
                                right: 10,
                                child: Container(
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                    color: Palette.primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        width: 0.4,
                                        color: Palette.primaryColorLight),
                                  ),
                                ))
                          ],
                        ),
                      )
                    : CircleButton(
                        iconSize: 22,
                        bgColor: Colors.transparent,
                        margin: EdgeInsets.all(7),
                        onPressed: () => Navigator.pushNamed(
                            context,
                            userData.isLoggedIn
                                ? NotificationScreen.routeName
                                : LoginScreen.routeName),
                        // Navigator.pushNamed(context, ChatListScreen.routeName),
                        imageIcon: true,
                        imagePath: notification,

                        color: Colors.grey,
                      ),
              ],
            )
                .box
                .white
                .outerShadowSm
                .padding(EdgeInsets.symmetric(horizontal: 15, vertical: 5))
                .width(context.screenWidth)
                .make(),
          ]).box.transparent.make();
        },
      ),
    );
  }
}
