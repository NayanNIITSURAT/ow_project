import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:owlet/Providers/GlobalProvider.dart';
import 'package:owlet/Widgets/ListingItem.dart';
import 'package:owlet/Widgets/ListingsListView.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ListingsArgs {
  final int initialIndex;
  final ListingProviderType providerType;

  const ListingsArgs({
    required this.initialIndex,
    required this.providerType,
  });
}

class ListingsScreen extends StatefulWidget {
  static const routeName = 'listings-screen';
  final int initialIndex;
  final ListingProviderType providerType;

  const ListingsScreen({
    required this.initialIndex,
    required this.providerType,
  });

  @override
  _ListingsScreenState createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  final ItemScrollController itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      itemScrollController.jumpTo(index: widget.initialIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = getProvider(context, widget.providerType);

    final listingData = getListingData(provider, widget.providerType);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text('My Posts',
            style: TextStyle(
                fontWeight: FontWeight.w500, fontSize: 20, color: Colors.black)
            // Theme.of(context).textTheme.headline6,
            ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ListingListView(
            data: listingData,
            scrollController: itemScrollController,
            child: (i) => ListingItem(
              product: listingData.listings[i],
            ),
          )
        ],
      ),
    );
  }
}
