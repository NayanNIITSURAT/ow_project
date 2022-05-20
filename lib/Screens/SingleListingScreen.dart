import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:owlet/Components/Loading.dart';
import 'package:owlet/Components/Toast.dart';
import 'package:owlet/Widgets/ListingItem.dart';
import 'package:owlet/models/Listing.dart';
import 'package:owlet/services/listing.dart';

class SingleListingArgs {
  final int id;

  const SingleListingArgs({
    required this.id,
  });
}

class SingleListingScreen extends StatefulWidget {
  static const routeName = 'single-listings-screen';

  @override
  _ListingsScreenState createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<SingleListingScreen> {
  late Listing listing;
  bool loading = true;

  @override
  void initState() {
    Future.delayed(Duration.zero, () => getListing());

    super.initState();
  }

  void getListing() {
    final id =
        (ModalRoute.of(context)!.settings.arguments as SingleListingArgs).id;
    fetchListing(id)
        .then(
      (_listing) => setState(() {
        listing = _listing;
        loading = false;
      }),
    )
        .catchError((onError) {
      Toast(
        context,
        message: 'Unable to fetch listing: ${onError.message}',
        type: ToastType.ERROR,
      ).showTop();
      Navigator.pop(context);
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Post',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        body: loading || listing == null
            ? Center(
                child: Loading(
                  message: 'Fetching listing',
                ),
              )
            : ListingItem(
                captionMaxLength: 10000,
                doubleTapToLike: false,
                product: listing,
                ismessage: true,
              ));
  }
}
