import 'package:flutter/material.dart';
import 'package:owlet/Components/BackArrow.dart';
import 'package:owlet/Components/Button.dart';
import 'package:owlet/Components/Loading.dart';
import 'package:owlet/Components/ProfileAvatar.dart';
import 'package:owlet/Providers/Auth.dart';
import 'package:owlet/Providers/GlobalProvider.dart';
import 'package:owlet/Providers/HashTagProvider.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Screens/Login.dart';
import 'package:owlet/Widgets/ListingGridView.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:provider/provider.dart';

class ScreenArgs {
  final String hashTag;
  ScreenArgs(this.hashTag);
}

class HashTagScreen extends StatelessWidget {
  static const routeName = '/hash-tag';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: BackArrow(),
        ),
        title: Consumer<HashTagProvider>(
          builder: (_, hashTagData, __) => Text(
            '#${hashTagData.tagData.tag}',
            style: TextStyle(color: Palette.primaryColor),
          ),
        ),
        toolbarHeight: 50,
        elevation: 1,
      ),
      body: Body(),
    );
  }
}

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final liveData = Provider.of<HashTagProvider>(context);
    final total = liveData.listingData.totalItems;
    final items = liveData.listingData.listings;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              ProfileAvatar(
                avatar: total > 0 || total > 0 == null
                    ? items.first.images[0]
                    : null,
                size: 80,
              ),
              SizedBox(width: 25),
              Expanded(
                  child: Column(
                children: [
                  RichText(
                    text: TextSpan(children: [
                      WidgetSpan(
                          child: Text(
                        total < 50 ? 'Fewer than 50' : '$total+',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      )),
                      WidgetSpan(
                          child: Text(
                        ' posts',
                        style: TextStyle(fontSize: 20),
                      )),
                    ]),
                  ),
                  Consumer<UserProvider>(
                    builder: (_, userData, __) => Button(
                      text: liveData.tagData.iFollow ? 'Following' : 'Follow',
                      press: () => userData.isLoggedIn
                          ? liveData.toggleHashTagFollow()
                          : Navigator.of(context)
                              .pushNamed(LoginScreen.routeName),
                      paddingVert: 10,
                      width: double.infinity,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'view recent listings from this hash tag',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  )
                ],
              ))
            ],
          ),
        ),
        Divider(),
        Text('Recent posts',
            style: TextStyle(fontSize: 20, color: Colors.grey)),
        SizedBox(
          height: 10,
        ),
        total > 0 || total == null
            ? ListingGridView(
                listings: liveData.items,
                load: () => liveData.getListings(hashtag: liveData.tagData.tag),
                refresh: () => liveData.getListings(
                    hashtag: liveData.tagData.tag, refresh: true),
                providerType: ListingProviderType.HASHTAG,
              )
            : liveData.hashTagStatus != Status.Completed
                ? Center(
                    child: Loading(
                    message: 'Fetching tag data',
                  ))
                : Center(
                    child: Text('No result for this hashtag'),
                  ),
      ],
    );
  }
}
