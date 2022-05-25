import 'package:flutter/material.dart';
import 'package:owlet/Components/ProfileAvatar.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Screens/AddListingScreen.dart';
import 'package:owlet/Screens/AddMarketSquare.dart';
import 'package:owlet/Screens/CameraScreen.dart';
import 'package:owlet/Screens/PicturePreviewScreen.dart';
import 'package:owlet/Screens/Stories.dart';
import 'package:owlet/constants/images.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:owlet/models/User.dart';
import 'package:provider/provider.dart';

class StatusScrollView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserProvider>(context);
    final users = userData.usersWithStory;
    return Container(
      height: screenSize(context).height * 0.1,
      width: screenSize(context).width,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.only(left: 18, top: 10),
          child: Row(
              children: List.generate(
                  users.length + (userData.isLoggedIn ? 1 : 0), (index) {
            final user = users.length > 0
                ? users[index > 0 && userData.isLoggedIn ? index - 1 : index]
                : User(id: 0, username: '');
            return index == 0 && userData.isLoggedIn
                ? Stack(
                    children: [
                      Container(
                        width: 75,
                        child: ProfileAvatar(
                          withBorder: true,
                          storyNum: userData.storyLen,
                          avatar: userData.profile.avtar,
                          size: 70,
                          onPressed: () async {
                            Navigator.push(
                                context,
                                PageRouteBuilder(
                                    opaque: false, // set to false
                                    pageBuilder: (_, __, ___) =>
                                        userData.hasStory
                                            ? Stories(isUserStory: true)
                                            : AddMarketSquareScreen()));
                            // ProfileViewModal.show(context);
                            // await Provider.of<UtilsProvider>(context,
                            //         listen: false)
                            //     .getCurrentSellerProfile(user);
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 0.5,
                        right: 1,
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                                context, CameraScreen.routeName);
                          },
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 3),
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment(0.1,
                                      0.0), // 10% of the width, so there are ten blinds.
                                  colors: [
                                    Color(0xffee0000),
                                    Palette.primaryColor,
                                    Color.fromARGB(255, 240, 102, 11),
                                  ], // red to yellow
                                ),
                                shape: BoxShape.circle),
                            child: Center(
                              child: Icon(
                                Icons.add,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                : ProfileAvatar(
                    storyNum: user.stories.length,
                    lastViewdIndex:
                        user.stories.lastIndexWhere((_) => _.iViewed),
                    withBorder: true,
                    avatar: user.avtar,
                    //isOnline: user.isOnline,
                    size: 70,
                    onPressed: () async {
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                            opaque: false, // set to false
                            pageBuilder: (_, __, ___) => Stories(
                              initialPage: index - 1,
                            ),
                          ));
                      // ProfileViewModal.show(context);
                      // await Provider.of<UtilsProvider>(context,
                      //         listen: false)
                      //     .getCurrentSellerProfile(user);
                    },
                  );
          })),
        ),
      ),
    );
  }
}
