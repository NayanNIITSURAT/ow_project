import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:owlet/Components/Button.dart';
import 'package:owlet/Components/Input.dart';
import 'package:owlet/Components/Loading.dart';
import 'package:owlet/Providers/Auth.dart';
import 'package:owlet/Providers/GlobalProvider.dart';
import 'package:owlet/Providers/HashTagProvider.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Providers/UtilsProvider.dart';
import 'package:owlet/Screens/ChatScreen.dart';
import 'package:owlet/Screens/HashTagScreen.dart';
import 'package:owlet/Screens/Login.dart';
import 'package:owlet/Widgets/DismissKeyboard.dart';
import 'package:owlet/Widgets/ListingGridView.dart';
import 'package:owlet/Widgets/PullToRefresh.dart';
import 'package:owlet/constants/images.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:owlet/modals/ProfileViewModal.dart';
import 'package:owlet/models/User.dart';
import 'package:owlet/services/apiUrl.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../services/utils.dart';

class SearchScreen extends StatelessWidget {
  static const routeName = "search";

  @override
  Widget build(BuildContext context) {
    final utility = Provider.of<UtilsProvider>(context);
    onInput(String query) async => await utility.searchAll(query);

    final tabHeaderWrapper = ({
      required String title,
      bool loading: false,
      required int total,
    }) =>
        Tab(
            child: Text(
          '$title',
          style: TextStyle(color: Colors.black, fontSize: 15),
        )
            // Column(
            //   children: [
            // searchingAll || loading
            //     ? CupertinoActivityIndicator()
            //     : Text(
            //         total.toString(),
            //         style: TextStyle(color: Colors.black),
            //       ),

            //   ],
            // ),
            );

    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            VxBox(
              child: SafeArea(
                bottom: false,
                child: VStack([
                  HStack(
                    [
                      IconButton(
                        padding: EdgeInsets.only(left: 15),
                        alignment: Alignment.centerLeft,
                        icon: Icon(
                          Icons.arrow_back,
                          color: Vx.black,
                          size: 26,
                        ),
                        onPressed: context.pop,
                      ),
                      'Search'.text.size(20).make(),
                      IconButton(
                        padding: EdgeInsets.all(0),
                        alignment: Alignment.centerRight,
                        icon: Icon(
                          Icons.more_vert_outlined,
                          color: Vx.white,
                          size: 26,
                        ),
                        onPressed: () {},
                      )
                    ],
                    alignment: MainAxisAlignment.spaceBetween,
                    axisSize: MainAxisSize.max,
                  ),
                  SizedBox(
                      child: Divider(
                          thickness: 1, color: divider.withOpacity(0.5))),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                    child: Input(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      islable: false,
                      icon: Icons.search,
                      hintText: "Search",
                      topPadding: 0,
                      containtpadding: EdgeInsets.fromLTRB(10, 11, 0, 11),
                      width: double.infinity,
                      onSaved: (val) => onInput(val ?? ''),
                      radius: 10,
                      rightIcon: Icons.search,
                      bgColor: fieldcolor,
                      elevate: false,
                    ),
                  ),
                  TabBar(
                    indicatorColor: Colors.blue,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: [
                      tabHeaderWrapper(
                        title: 'Accounts',
                        total: utility.userSearchResult.totalItems,
                        loading: utility.userStatus == Status.Processing,
                      ),
                      tabHeaderWrapper(
                        title: 'Hashtags',
                        total: utility.tagSearchResult.totalItems,
                        loading: utility.hashTagStatus == Status.Processing,
                      ),
                      tabHeaderWrapper(
                        title: 'Listings',
                        total: utility.listingSearchResult.totalItems,
                        loading: utility.listingStatus == Status.Processing,
                      ),
                    ],
                  ),
                ]),
              ),
            ).bottomRounded(value: 25).color(Vx.white).outerShadowSm.make(),
            Flexible(
              child: TabBarView(
                children: [
                  AccountList(data: utility),
                  HashtagList(utility: utility),
                  Column(
                    children: [
                      ListingGridView(
                        listings: utility.listings,
                        load: () => utility.searchListings(),
                        refresh: () => utility.searchListings(refresh: true),
                        providerType: ListingProviderType.SEARCHLISTING,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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

class HashtagList extends StatelessWidget {
  final UtilsProvider utility;

  HashtagList({
    required this.utility,
  });

  @override
  Widget build(BuildContext context) {
    final hashProvider = Provider.of<HashTagProvider>(context, listen: false);
    final data = utility.tagSearchResult;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
      child: data.totalItems == 0
          ? Center(
              child: Text('No result for your search'),
            )
          : Column(
              children: [
                if (hashProvider.hashTagStatus == Status.Processing)
                  Loading(
                    message: 'Loading',
                  ),
                Flexible(
                  child: PullToLoad(
                    refresh: () => utility.searchHashtags(refresh: true),
                    load: () => utility.searchHashtags(),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: data.tags.length,
                      itemBuilder: (_, i) {
                        final tagData = data.tags[i];
                        return Consumer<UserProvider>(
                            builder: (_, userData, __) {
                          return SearchItem(
                            title: tagData.tag,
                            press: userData.isLoggedIn
                                ? tagData.iFollow
                                    ? null
                                    : () => tagData.toggleHashTagFollow()
                                : () => Navigator.of(context)
                                    .pushNamed(LoginScreen.routeName),
                            subtitle: tagData.totalListings.toString(),
                            imageUrl:
                                AppUrl.listingImageBaseUrl + 'hashtag.jpeg',
                            view: () {
                              hashProvider.setTagData(tagData.tag);

                              dismissKeyBoard(context);
                              Navigator.pushNamed(
                                  context, HashTagScreen.routeName);
                            },
                          );
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class AccountList extends StatelessWidget {
  final UtilsProvider data;
  final bool isChat;
  final Function(User)? callBack;

  AccountList({
    required this.data,
    this.isChat: false,
    this.callBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
      child: data.userSearchResult.totalItems == 0
          ? Center(
              child: Text('No result for your search'),
            )
          : Column(
              children: [
                if (data.userStatus == Status.Processing)
                  Loading(
                    message: 'Loading',
                  ),
                Flexible(
                  child: PullToLoad(
                    refresh: () => data.searchUsers(refresh: true),
                    load: () => data.searchUsers(),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: data.users.length,
                      itemBuilder: (_, i) {
                        final seller = data.users[i];
                        return Consumer<UserProvider>(
                          builder: (_, user, __) {
                            return SearchItem(
                              seller: seller,
                              title: seller.username,
                              press: user.isLoggedIn
                                  ? seller.iFollow ||
                                          user.profile.id == seller.id
                                      ? null
                                      : seller.private == true
                                          ? () => getdata(seller.id)
                                          : () => user.followUser(seller)
                                  : () => Navigator.of(context)
                                      .pushNamed(LoginScreen.routeName),
                              subtitle: seller.fullName,
                              imageUrl: seller.avtar,
                              view: callBack != null
                                  ? () => callBack!(seller)
                                  : isChat
                                      ? () {
                                          user.curChatUser = seller.chat;
                                          Navigator.of(context)
                                              .pushNamed(ChatScreen.routeName);
                                        }
                                      : () async {
                                          await data
                                              .getCurrentSellerProfile(seller);
                                          ProfileViewModal.show(context);
                                          dismissKeyBoard(context);
                                        },
                              isAccount: true,
                              isChat: isChat,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

callfollow(UserProvider user, User seller) {
  print("make the flooow ");
  user.followUser(seller);
}

getdata(int id) {
  print("make  the private");
}

// user.isLoggedIn
//     ? seller.iFollow ||
//             user.profile.id == seller.id
//         ? null
//         : () => user.followUser(seller)
//     : () => Navigator.of(context)
//         .pushNamed(LoginScreen.routeName),
class SearchItem extends StatelessWidget {
  const SearchItem({
    Key? key,
    required this.title,
    this.isAccount: false,
    this.isChat: false,
    required this.subtitle,
    required this.imageUrl,
    required this.press,
    this.seller,
    this.view,
  }) : super(key: key);

  final String title;
  final bool isAccount;
  final bool isChat;
  final String imageUrl;
  final String subtitle;
  final Function()? press;
  final Function()? view;
  final User? seller;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: view,
      child: ListTile(
        onTap: view,
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.red.shade400,
          backgroundImage: AssetImage(loadingGif),
          foregroundImage: NetworkImage(imageUrl),
        ),
        title: '${isAccount ? "@" : "#"}$title'.text.semiBold.size(15).make(),
        subtitle: Text(subtitle),
        trailing: isChat
            ? Icon(Icons.chevron_right)
            : press == null
                ? Container(
                    height: 40,
                    width: 105,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        seller?.private == true ? 'Requested' : 'Following',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                // Text(
                //             seller!.private == true ? 'Requested' : 'Following',
                //             style: TextStyle(decorationStyle: TextDecorationStyle.wavy),
                //           )
                : Button(
                    text: 'Follow',
                    press: press!,
                    paddingVert: 0,
                    paddingHori: 30,
                  ),
        contentPadding: EdgeInsets.symmetric(horizontal: 0),
      ),
    );
  }
}
