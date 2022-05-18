import 'package:flutter/material.dart';
import 'package:owlet/Widgets/CachedImage.dart';
import 'package:owlet/models/Listing.dart';
import 'package:provider/provider.dart';

class ListingGridItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Listing listing = Provider.of<Listing>(context, listen: false);

    return Container(
      padding: EdgeInsets.only(left: 0.4, right: 0.4, bottom: 0.8),
      child: ClipRRect(
        // borderRadius: BorderRadius.circular(6),
        child: GridTile(
          child: GestureDetector(
            // onTap: () => Navigator.pushNamed(
            //     context, ProductDetailScreen.routeName,
            //     arguments: product.id),
            // onDoubleTap: () => product.toggleIsFav(),
            child: CachedImage(imageUrl: listing.images[0]),
          ),
        ),
      ),
    );
  }
}
