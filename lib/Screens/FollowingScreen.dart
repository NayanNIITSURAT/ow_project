import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:owlet/Providers/Auth.dart';
import 'package:owlet/Providers/Listing.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Widgets/ListingsListView.dart';
import 'package:owlet/Screens/SearchScreen.dart';
import 'package:provider/provider.dart';

import '../Widgets/CustomAppBar.dart';

class FollowingScreen extends StatelessWidget {
  final bool istopbar;

  const FollowingScreen({Key? key, required this.istopbar}) : super(key: key);
  static const routeName = '/following';

  @override
  Widget build(BuildContext context) {
    final listing = Provider.of<ListingProvider>(context, listen: false);
    final user = Provider.of<UserProvider>(context, listen: false);

    if (user.isLoggedIn)
      Future.delayed(
          Duration(seconds: 1),
          () => {
                if (listing.itemsForMe.length < 1 &&
                    listing.listingForMeStatus != Status.Processing)
                  Navigator.pushNamed(context, SearchScreen.routeName)
              });

    return  istopbar==false?Body2():Body();
  }
}

class Body extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final listing = Provider.of<ListingProvider>(context);
    final user = Provider.of<UserProvider>(context);
    return user.initStatus == Status.Processing ||
            user.initStatus == Status.Idle
        ? Center(child: CupertinoActivityIndicator())
        : Column(
            children: [

              CustomAppBar(),
              ListingListView(
                showSellersScroll: false,
                data: ListingViewData(
                  listings: listing.itemsForMe,
                  load: () => listing.getListingsForMe(),
                  refresh: () => listing.getListingsForMe(refresh: true),
                ),
                isLoading: listing.listingForMeStatus == Status.Processing,
              ),
            ],
          );
  }
}
class Body2 extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final listing = Provider.of<ListingProvider>(context);
    final user = Provider.of<UserProvider>(context);
    return user.initStatus == Status.Processing ||
        user.initStatus == Status.Idle
        ? Center(child: CupertinoActivityIndicator())
        : Column(
      children: [


        ListingListView(
          showSellersScroll: false,
          data: ListingViewData(
            listings: listing.itemsForMe,
            load: () => listing.getListingsForMe(),
            refresh: () => listing.getListingsForMe(refresh: true),
          ),
          isLoading: listing.listingForMeStatus == Status.Processing,
        ),
      ],
    );
  }
}
