import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:insta_like_button/insta_like_button.dart';
import 'package:owlet/Providers/GlobalProvider.dart';
import 'package:owlet/Providers/UtilsProvider.dart';
import 'package:owlet/Screens/Login.dart';
import 'package:owlet/Widgets/CachedImage.dart';
import 'package:owlet/Widgets/ListingItemFooter.dart';
import 'package:owlet/Widgets/ListingItemHeader.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:owlet/modals/ProfileViewModal.dart';
import 'package:owlet/models/Listing.dart';
import 'package:owlet/models/User.dart';
import 'package:provider/provider.dart';

class ListingItem extends StatefulWidget {
  const ListingItem({
    required this.product,
    this.activeImage: 0,
    this.captionMaxLength,
    this.doubleTapToLike: true,
  });

  final int? captionMaxLength;
  final bool doubleTapToLike;
  final Listing product;
  final int activeImage;

  @override
  _ListingItemState createState() => _ListingItemState();
}

class _ListingItemState extends State<ListingItem> {
  int activeImg = 0;
  @override
  Widget build(BuildContext context) {
    final globalProvider = GlobalProvider(context);
    final userData = globalProvider.userProvider;

    final product = widget.product;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0,top: 8.0),
      child: SizedBox(
        width: screenSize(context).width * 0.95,
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              GestureDetector(
                child: ListingItemHeader(
                  product: widget.product,
                ),
                onTap: () {
                  User owner = product.owner;
                  Provider.of<UtilsProvider>(context, listen: false)
                      .currentSellerProfile = owner;
                  ProfileViewModal.show(context);
                },
              ),
              SizedBox(
                height: 10,
              ),
              StatefulBuilder(builder: (context, sliderState) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: screenSize(context).height * 0.4,
                    width: screenSize(context).width * 0.8,
                    child: Stack(
                      children: [
                        CarouselSlider(
                          items:
                              List.generate(widget.product.images.length, (i) {
                            return SizedBox(
                              height: screenSize(context).height * 0.4,
                              width: screenSize(context).width * 0.8,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CachedImage(imageUrl: product.images[i]),
                                  if (widget.doubleTapToLike)
                                    InstaLikeButton(
                                      image: NetworkImage(product.images[0]),
                                      imageColorFilter: ColorFilter.mode(
                                        Colors.black.withOpacity(0),
                                        BlendMode.dstATop,
                                      ),
                                      iconColor:
                                          userData.isLoggedIn && product.iLike
                                              ? Colors.white
                                              : Colors.red,
                                      icon: userData.isLoggedIn
                                          ? product.iLike
                                              ? Icons.favorite
                                              : Icons.favorite_border_outlined
                                          : Icons.not_interested_outlined,
                                      onChanged: userData.isLoggedIn
                                          ? () async {
                                              globalProvider.toggleLikeListing =
                                                  product.id;

                                              final liked =
                                                  await (!product.iLike
                                                      ? product.unLike()
                                                      : product.like());

                                              if (liked && !product.iLike)
                                                globalProvider
                                                        .toggleLikeListing =
                                                    product.id;
                                            }
                                          : () => Navigator.pushNamed(
                                              context, LoginScreen.routeName),
                                    ),
                                ],
                              ),
                            );
                          }),
                          options: CarouselOptions(
                              enableInfiniteScroll: false,
                              height: screenSize(context).height * 0.4,
                              viewportFraction: 1,
                              onPageChanged: (index, _) {
                                activeImg = index;
                                sliderState(() {});
                              }),
                        ),
                        if (product.images.length > 1)
                          Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: _indicatiors(widget.product, activeImg),
                              )),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(
                height: 10,
              ),
              ListingItemFooter(
                product: widget.product,
                activeImage: activeImg,
                captionMaxLength: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _indicator(bool isFirst, {double? size}) {
    final _size = size ?? (isFirst ? 7 : 6);
    return Container(
      height: _size,
      width: _size,
      margin: EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: isFirst ? Palette.primaryColor : Colors.grey.shade400,
        // border: Border.all(
        //   width: 1.5,
        //   color: Palette.primaryColor,
        // ),
      ),
    );
  }

  Widget _indicatiors(Listing product, int activeImage) => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: product.images.asMap().entries.map(
            (e) {
              return _indicator(e.key == activeImage,
                  size: product.images.length > 3 &&
                          e.key != activeImage &&
                          (e.key < 2 || e.key >= product.images.length - 2)
                      ? (e.key < 1 || e.key >= product.images.length - 1)
                          ? e.key == activeImage - 1
                              ? null
                              : 3
                          : e.key == activeImage - 1 || e.key == activeImage + 1
                              ? null
                              : 4.5
                      : null);
            },
          ).toList(),
        ),
      );
}
