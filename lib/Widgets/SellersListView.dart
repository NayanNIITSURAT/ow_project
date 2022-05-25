import 'package:flutter/material.dart';
import 'package:owlet/Components/CircleButton.dart';
import 'package:owlet/Components/ProfileAvatar.dart';
import 'package:owlet/Components/ReadMore.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Screens/CameraScreen.dart';
import 'package:owlet/Screens/Stories.dart';
import 'package:owlet/models/User.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

class SellersListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserProvider>(context);
    final users = userData.usersWithStory;
    return Column(
      children: [
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) {
              final user = users.length > 0
                  ? users[i > 0 && userData.isLoggedIn ? i - 1 : i]
                  : User(id: 0, username: '');
              return i == 0 && userData.isLoggedIn
                  ? Padding(
                      padding: EdgeInsets.only(right: 10, left: i == 0 ? 8 : 0),
                      child: Column(
                        children: [
                          ZStack(
                            [
                              ProfileAvatar(
                                // withBorder: true,
                                storyNum: userData.storyLen,
                                avatar: userData.profile.avartar,
                                size: 60,
                                onPressed: () async {
                                  Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        opaque: false, // set to false
                                        pageBuilder: (_, __, ___) =>
                                            userData.hasStory
                                                ? Stories(isUserStory: true)
                                                : CameraScreen(),
                                      ));
                                  // ProfileViewModal.show(context);
                                  // await Provider.of<UtilsProvider>(context,
                                  //         listen: false)
                                  //     .getCurrentSellerProfile(user);
                                },
                              ),
                              Positioned(
                                bottom: -10,
                                right: -10,
                                child: CircleButton(
                                    icon: Icons.add,
                                    // onPressed: () => ,
                                    iconSize: 14,
                                    color: Colors.white,
                                    bgColor: Colors.green,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    )),
                              )
                            ],
                          ),
                          5.heightBox,
                          Text(
                            'Recents',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.only(right: 10, left: i == 0 ? 8 : 0),
                      child: Column(
                        children: [
                          ProfileAvatar(
                            storyNum: user.stories.length,
                            lastViewdIndex:
                                user.stories.lastIndexWhere((_) => _.iViewed),
                            // withBorder: true,
                            avatar: user.avartar,
                            // isOnline: user.isOnline,
                            size: 60,
                            onPressed: () async {
                              Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    opaque: false, // set to false
                                    pageBuilder: (_, __, ___) => Stories(
                                      initialPage: i - 1,
                                    ),
                                  ));
                              // ProfileViewModal.show(context);
                              // await Provider.of<UtilsProvider>(context,
                              //         listen: false)
                              //     .getCurrentSellerProfile(user);
                            },
                          ),
                          ReadMore(
                            caption: user.username,
                            showReadmore: false,
                            maxLength: 11,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
            },
            itemCount: users.length + (userData.isLoggedIn ? 1 : 0),
          ),
        ),
        Divider(
          height: 1,
          color: Colors.grey.shade400,
        )
      ],
    );
  }
}
