import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Widgets/ListingItem.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:owlet/models/Listing.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../constants/palettes.dart';

class ListingViewData {
  final List<Listing> listings;
  final Function() load;
  final Function refresh;

  ListingViewData({
    required this.listings,
    required this.load,
    required this.refresh,
  });
}

class ListingListView extends StatefulWidget {
  ListingListView({
    this.child,
    this.isLoading: false,
    this.showSellersScroll: true,
    this.scrollController,
    required this.data,
  });

  final ListingViewData data;
  final bool isLoading;
  final bool showSellersScroll;
  final Widget? Function(int index)? child;
  final ItemScrollController? scrollController;

  @override
  _ListingListViewState createState() => _ListingListViewState();
}

class _ListingListViewState extends State<ListingListView> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return Flexible(
      child: widget.scrollController != null
          ? ScrollablePositionedList.builder(
              itemScrollController: widget.scrollController,
              itemBuilder: (_, i) => (widget.child!(i) ?? SizedBox()),
              itemCount: data.listings.length + (widget.child != null ? 0 : 1),
            )
          : SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              header: WaterDropHeader(),
              footer: CustomFooter(
                builder: (BuildContext context, LoadStatus? mode) {
                  Widget body;

                  if (mode == LoadStatus.loading) {
                    body = CupertinoActivityIndicator();
                  } else {
                    body = Text("No more Data");
                  }
                  return Container(
                    height: 70.0,
                    child: Center(child: body),
                  );
                },
              ),
              controller: _refreshController,
              onRefresh: () async {
                await data.refresh();
                _refreshController.refreshCompleted();
                setState(() {});
              },
              onLoading: () async {
                await data.load();
                _refreshController.loadComplete();
                setState(() {});
              },
              child: data.listings.length < 1
                  ? Center(
                      child: !widget.isLoading
                          ? Text('You have no listing yet')
                          : CupertinoActivityIndicator(),
                    )
                  // : screenSize(context).width > 500
                  //     ? Container(
                  //         child: Column(
                  //           children: [
                  //             widget.showSellersScroll
                  //                 ? SellersListView()
                  //                 : SizedBox(),
                  //             Flexible(
                  //               child: ListView.builder(
                  //                 itemBuilder: (_, i){
                  //                   var index = (i * 2) + 1;
                  //                   return Row(
                  //                     mainAxisAlignment:
                  //                         MainAxisAlignment.spaceBetween,
                  //                     crossAxisAlignment:
                  //                         CrossAxisAlignment.start,
                  //                     children: [
                  //                       Flexible(
                  //                         child: Padding(
                  //                           padding:
                  //                               const EdgeInsets.only(right: 1),
                  //                           child: ListingItem(
                  //                             product: data.listings[index - 1],
                  //                           ),
                  //                         ),
                  //                       ),
                  //                       if (index < data.listings.length)
                  //                         Flexible(
                  //                           child: Padding(
                  //                             padding: const EdgeInsets.only(
                  //                                 left: 1),
                  //                             child: ListingItem(
                  //                               product: data.listings[index],
                  //                             ),
                  //                           ),
                  //                         ),
                  //                     ],
                  //                   );
                  //                 },
                  //                 itemCount: data.listings.length % 2 == 0
                  //                     ? data.listings.length ~/ 2
                  //                     : data.listings.length ~/ 2 + 1,
                  //               ),
                  //             )
                  //           ],
                  //         ),
                  //       )

                  : Consumer<UserProvider>(builder: (_, userData, __) {
                      return Container(
                        width: screenSize(context).width,
                        color: Palette.primaryBlueLightShade,
                        child: ScrollConfiguration(
                          behavior:
                              ScrollBehavior().copyWith(overscroll: false),
                          child: SingleChildScrollView(
                            child: Column(
                              children: List.generate(
                                data.listings.length + 1,
                                (i) => i == 0
                                    ?
                                    // (userData.isLoggedIn &&
                                    //             !userData.profile.confirmed)
                                    //         ? HStack(
                                    //             [
                                    //               'Account pending confirmation...'
                                    //                   .text.size(13)
                                    //                   .overflow(TextOverflow.fade)
                                    //                   .color(Colors.black54)
                                    //
                                    //                   .make(),
                                    //               VxBox(
                                    //                 child: HStack([
                                    //                  Image.asset(security_shield,height: 20,),
                                    //                   10.widthBox,
                                    //                   'Confirm!'
                                    //                       .text
                                    //                       .semiBold
                                    //                       .color(Colors.white)
                                    //                       .make()
                                    //
                                    //                 ]),
                                    //               )
                                    //                   .padding(EdgeInsets.symmetric(
                                    //                       horizontal: 16,
                                    //                       vertical: 8)).margin(EdgeInsets.symmetric(
                                    //                       vertical: 10)).hexColor("#1FD6AA").roundedSM
                                    //                   .make()
                                    //                   .onInkTap(() {
                                    //                 Navigator.pushNamed(context,
                                    //                     ConfirmationScreen.routeName);
                                    //                 // Alert(
                                    //                 //     context: context,
                                    //                 //     title: "Email Verification",
                                    //                 //     content: Column(
                                    //                 //       children: <Widget>[
                                    //                 //         OtpForm(
                                    //                 //           onSubmit: (val) {},
                                    //                 //           otpLength: 6,
                                    //                 //         )
                                    //                 //       ],
                                    //                 //     ),
                                    //                 //     buttons: []).show();
                                    //               }),
                                    //             ],
                                    //             alignment:
                                    //                 MainAxisAlignment.spaceBetween,
                                    //           )
                                    //             .box
                                    //             .padding(EdgeInsets.symmetric(horizontal: 15,))
                                    //             .make()
                                    //             .wFull(context)
                                    //         :

                                    SizedBox.shrink()
                                    : Column(
                                        children: [
                                          ListingItem(
                                            product: data.listings[i - 1],
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      );
                    })),
    );
  }
}
