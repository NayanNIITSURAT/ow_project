import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:owlet/Components/Loading.dart';
import 'package:owlet/Providers/GlobalProvider.dart';
import 'package:owlet/Screens/ListingsScreen.dart';
import 'package:owlet/Widgets/GridItem.dart';
import 'package:owlet/models/Listing.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ListingGridView extends StatefulWidget {
  final ListingProviderType providerType;
  final List<Listing> listings;
  final Function() load;
  final Function refresh;
  final int column;

  final bool isLoading;
  ListingGridView({
    this.column: 3,
    this.isLoading: false,
    required this.listings,
    required this.load,
    required this.refresh,
    required this.providerType,
  });

  @override
  _ListingGridViewState createState() => _ListingGridViewState();
}

class _ListingGridViewState extends State<ListingGridView> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: WaterDropHeader(),
          footer: CustomFooter(
            builder: (BuildContext context, LoadStatus? mode) {
              Widget body;
              // if (mode == LoadStatus.idle) {
              //   body = Text("Pull up to load more");
              // } else
              if (mode == LoadStatus.loading) {
                body = CupertinoActivityIndicator();
                // } else if (mode == LoadStatus.failed) {
                //   body = Text("Load Failed!Click retry!");
                // } else if (mode == LoadStatus.canLoading) {
                //   body = Text("release to load more");
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
            await widget.refresh();
            _refreshController.refreshCompleted();
          },
          onLoading: () async {
            await widget.load();
            _refreshController.loadComplete();
          },
          child: widget.isLoading
              ? Center(
                  child: Loading(
                    message: 'Fetching data',
                  ),
                )
              : widget.listings.length < 1
                  ? Center(
                      child: Text('No listing yet'),
                    )
                  : GridView.builder(
                      itemBuilder: (_, i) => ChangeNotifierProvider.value(
                        value: widget.listings[i],
                        child: GestureDetector(
                          child: ListingGridItem(),
                          onTap: () => Navigator.of(context)
                              .pushNamed(ListingsScreen.routeName,
                                  arguments: ListingsArgs(
                                    initialIndex: i,
                                    providerType: widget.providerType,
                                  )),
                        ),
                      ),
                      itemCount: widget.listings.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.all(0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: widget.column,
                        childAspectRatio: 1.1,
                        crossAxisSpacing: 3,
                        mainAxisSpacing: 3,
                      ),
                    )
          // ),
          ),
    );
  }
}
