import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:owlet/Providers/Auth.dart';
import 'package:owlet/Providers/Listing.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Screens/SearchScreen.dart';
import 'package:owlet/Widgets/CustomAppBar.dart';
import 'package:owlet/Widgets/ListingsListView.dart';
import 'package:owlet/Widgets/StatusScrollView.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:provider/provider.dart';
import '../Widgets/customindicator.dart';
import 'FollowingScreen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    final listing = Provider.of<ListingProvider>(context, listen: false);
    final user = Provider.of<UserProvider>(context, listen: false);

    // if (user.isLoggedIn)
    //   Future.delayed(
    //       Duration(seconds: 1),
    //       () => {
    //             if (listing.items.length < 1 &&
    //                 listing.listingStatus != Status.Processing)
    //               Navigator.pushNamed(context, SearchScreen.routeName)
    //           });

    return Body();
  }
}

class Body extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BodyState();
  }
}

class _BodyState extends State<Body> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final listing = Provider.of<ListingProvider>(context);
    final user = Provider.of<UserProvider>(context);
    return user.initStatus == Status.Processing ||
            user.initStatus == Status.Idle
        ? Center(child: CupertinoActivityIndicator())
        : DefaultTabController(
      length: 2,
          initialIndex: 1,

          child: Container(
              color: Palette.primaryBlueLightShade,
              child: Column(
                children: [
                  CustomAppBar(),

                  Container(
                    decoration: BoxDecoration(

                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30))),
                    child: Column(
                      children: [
                        SizedBox(

                            child: Divider(
                                thickness: 1,
                                color:divider.withOpacity(0.1)
                            )),
                        StatusScrollView(),
                        SizedBox(
                            width: screenSize(context).width * 0.9,
                            child: Divider(
                              thickness: 1,
                                color:divider.withOpacity(0.1)
                            )),
                        Container(
                          height: screenSize(context).height * 0.06,
                          width: screenSize(context).width,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20))),
                          child: Padding(
                            padding:  EdgeInsets.symmetric(horizontal:50 ),
                            child: TabBar(
                              controller: _tabController,
                              labelColor: Colors.black,
                              unselectedLabelColor: Colors.grey,
                              indicatorColor:indicatorColor,
                              indicator: CustomTabIndicator(color:indicatorColor,indicatorHeight: 3 ),
                              labelStyle: TextStyle(fontSize: 18),
                              tabs: [
                                Tab(text: 'Market',),
                                Tab(text: 'Following',),
                              ],
                            ),
                          ),


                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height*0.002,
                        )

                      ],
                    ),
                  ),

                  Flexible(
                    child: TabBarView(
                        controller:_tabController ,
                        children: [
                      ListingListView(
                        data: ListingViewData(
                          listings: listing.items,
                          load: () => listing.getListings(),
                          refresh: () => user.getUsersWithStory().then((value) {
                            listing.getListings(refresh: true);
                          }),
                        ),
                        isLoading: listing.listingStatus == Status.Processing,
                        showSellersScroll: user.isLoggedIn,
                      ),
                      FollowingScreen(istopbar:false)
                    ]),
                  ),


                ],
              ),
            ),
        );
  }
}
