import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owlet/Components/Button.dart';
import 'package:owlet/Components/Input.dart';
import 'package:owlet/Components/Loading.dart';
import 'package:owlet/Providers/Auth.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Providers/UtilsProvider.dart';
import 'package:owlet/Screens/Login.dart';
import 'package:owlet/Widgets/DismissKeyboard.dart';
import 'package:owlet/Widgets/PullToRefresh.dart';
import 'package:owlet/constants/images.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:owlet/modals/ProfileViewModal.dart';
import 'package:owlet/models/Comment.dart';
import 'package:owlet/models/User.dart';
import 'package:provider/provider.dart';

import '../Components/bottomsheetbutton.dart';
import '../helpers/helpers.dart';

class FollowerScreenArguments {
  final User user;
  final FollowType? type;

  FollowerScreenArguments(this.user, {this.type: FollowType.FOLLOWERS});
}

class Followers extends StatefulWidget {
  static const routeName = 'followers';

  @override
  State<Followers> createState() => _FollowersState();
}

class _FollowersState extends State<Followers> {
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).resetFollowData();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as FollowerScreenArguments;

    final tabHeaderWrapper = ({
      required String title,
      bool loading: false,
      required int total,
    }) =>
        Tab(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            loading
                ? CupertinoActivityIndicator()
                : Text(
                    total.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                    // style: TextStyle(color: Colors.black),
                  ),
            SizedBox(width: 7),
            Text(
              '$title',
              style: TextStyle(fontWeight: FontWeight.bold),
              // style: TextStyle(color: Colors.black, fontSize: 15),
            ),
          ],
        ));

    return Scaffold(
      body: DefaultTabController(
        initialIndex: args.type == FollowType.FOLLOWERS ? 0 : 1,
        length: 2,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Builder(builder: (context) {
                final utility =
                    Provider.of<UtilsProvider>(context, listen: false);
                final userData =
                    Provider.of<UserProvider>(context, listen: false);
                var seller = utility.currentSellerProfile;

                final TabController tabController =
                    DefaultTabController.of(context)!;
                tabController.addListener(() {
                  if (!tabController.indexIsChanging) {
                    if (tabController.index == 0)
                      userData.getUserFollowers(args.user.id, refresh: true);
                    else
                      userData.getUserFollowing(args.user.id, refresh: true);
                  }
                });
                return Builder(builder: (context) {
                  return Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: Row(
                                children: [
                                  InkWell(
                                      onTap: () {
                                        {
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: Icon(
                                        Icons.arrow_back,
                                        color: Colors.black,
                                        size: 20,
                                      )),
                                  SizedBox(
                                    width: 120,
                                  ),
                                  Text(
                                    args.user.username,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.width * 0.05,
                                width: MediaQuery.of(context).size.width,
                                child: Divider(
                                    thickness: 1,
                                    color: divider.withOpacity(0.5))),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30))),
                        child: TabBar(
                          unselectedLabelColor: Colors.black45,
                          indicatorColor: Colors.blue,
                          indicatorSize: TabBarIndicatorSize.label,
                          labelColor: Colors.black,
                          enableFeedback: false,
                          tabs: [
                            tabHeaderWrapper(
                              title: 'Followers',
                              total: seller!.totalFollowers,
                              loading: utility.userStatus == Status.Processing,
                            ),
                            tabHeaderWrapper(
                              title: 'Following',
                              total: seller.totalFollowing,
                              loading:
                                  utility.hashTagStatus == Status.Processing,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                });
              }),
              Flexible(
                child: TabBarView(
                  children: [
                    AccountList(
                        userId: args.user.id, type: FollowType.FOLLOWERS),
                    AccountList(
                        userId: args.user.id, type: FollowType.FOLLOWING),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   child: Icon(
      //     Icons.person_add_alt_1,
      //   ),
      // ),
    );
  }
}

class AccountList extends StatelessWidget {
  final int userId;
  final FollowType type;

  AccountList({required this.userId, required this.type});

  List<dynamic> detail = [];

  @override
  Widget build(BuildContext context) {
    final utility = Provider.of<UtilsProvider>(context);
    final userData = Provider.of<UserProvider>(context);

    final users = type == FollowType.FOLLOWING
        ? userData.userFollowing
        : userData.userFollowers;

    final loadData;
    final String title;

    if (type == FollowType.FOLLOWING) {
      loadData = userData.getUserFollowing;
      title = 'following';
    } else {
      loadData = userData.getUserFollowers;
      title = 'follower(s)';
    }

    final processing = type == FollowType.FOLLOWING
        ? userData.getFollowingStatus == Status.Requesting
        : userData.getFollowersStatus == Status.Requesting;

    onInput(String query) async =>
        await loadData(userId, refresh: true, searchQuery: query);

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: [
            Input(
              islable: false,
              // preWidget: processing ? CupertinoActivityIndicator() : null,
              padding: const EdgeInsets.symmetric(vertical: 3),
              icon: Icons.search,
              containtpadding: EdgeInsets.fromLTRB(10, 11, 0, 11),
              hintText: "Search",
              width: double.infinity,
              elevate: false,
              rightIcon: Icons.search,
              onSaved: (val) => onInput(val ?? ''),
            ),
            if (processing && users.length < 1)
              Loading(
                message: 'Fetching $title data',
              ),
            Flexible(
              child: PullToLoad(
                refresh: () => loadData(userId, refresh: true),
                load: () => loadData(userId),
                child: (users.length > 0 || processing)
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: users.length,
                        itemBuilder: (_, i) {
                          final seller = users[i];
                          return SearchItem(
                              title: seller.username,
                              // press: userData.isLoggedIn
                              //     ? seller.iFollow ||
                              //             userData.profile.id == seller.id
                              //         ? null
                              //         : () => userData.followUser(seller)
                              //     : () => Navigator.of(context)
                              //         .pushNamed(LoginScreen.routeName),
                              press: () {
                                showModalBottomSheet<void>(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(25),
                                    ),
                                  ),
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      height: 230,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                color: Colors.grey
                                                    .withOpacity(0.3),
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            height: 3,
                                            width: 80,
                                          ),
                                          CircleAvatar(
                                            backgroundColor: Colors.white30,
                                            backgroundImage:
                                                AssetImage(loadingGif),
                                            foregroundImage:
                                                NetworkImage(seller.avartar),
                                          ),
                                          Text(
                                            "Remove follower?",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: Text(
                                              "Owlet Wont's tell me"
                                              '  ${seller.username} that they have been removed from your followers.',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.poppins(
                                                textStyle: TextStyle(
                                                    color: icolor,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ),
                                          bottomsheetbutton(
                                            text: 'Remove',
                                            press: () {
                                              detail.removeAt(i)
                                                  ? seller.iFollow ||
                                                      userData.profile.id ==
                                                          seller.id
                                                  : () => userData
                                                      .followUser(seller);
                                            },
                                          ),
                                          // bottomsheetbutton(
                                          //   text: 'Remove',
                                          //   press: () {
                                          //     userData.isLoggedIn
                                          //         ? seller.iFollow ||
                                          //         userData.profile.id ==
                                          //             seller.id
                                          //         ? null
                                          //         : () => userData
                                          //         .followUser(seller)
                                          //         : () => Navigator.of(context)
                                          //         .pushNamed(LoginScreen
                                          //         .routeName);
                                          //   },
                                          // ),
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                "Cancel",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              subtitle: seller.fullName,
                              imageUrl: seller.avartar,
                              view: () async {
                                await utility.getCurrentSellerProfile(seller);
                                ProfileViewModal.show(context);
                                dismissKeyBoard(context);
                              },
                              isAccount: true);
                        },
                      )
                    : Center(
                        child: Text('No $title found!'),
                      ),
              ),
            ),
          ],
        ));
  }
}

class SearchItem extends StatelessWidget {
  const SearchItem({
    Key? key,
    required this.title,
    this.isAccount: false,
    required this.subtitle,
    required this.imageUrl,
    required this.press,
    this.view,
  }) : super(key: key);

  final String title;
  final bool isAccount;
  final String imageUrl;
  final String subtitle;
  final Function()? press;
  final Function()? view;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: view,
      child: ListTile(
        onTap: view,
        leading: CircleAvatar(
          backgroundColor: Colors.white30,
          backgroundImage: AssetImage(loadingGif),
          foregroundImage: NetworkImage(imageUrl),
        ),
        title: Text(
          '${isAccount ? "@" : "#"}$title',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: press == null
            // ? Text(
            //     'following',
            //     style:
            //         TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            //   )
            // : Button(
            //     text: 'Follow',
            //     press: press!,
            //     paddingVert: 5,
            //     paddingHori: 30,
            //   ),
            ? Container(
                height: 40,
                width: 105,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Following',
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            : Button(
                text: 'Remove',
                press: press!,
                paddingVert: 5,
                paddingHori: 25,
              ),
        contentPadding: EdgeInsets.symmetric(horizontal: 0),
      ),
    );
  }
}
