import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:owlet/Components/IconBtn.dart';
import 'package:owlet/Providers/GlobalProvider.dart';
import 'package:owlet/Providers/Listing.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Screens/ChatScreen.dart';
import 'package:owlet/Screens/Login.dart';
import 'package:owlet/Widgets/Chatable.dart';
import 'package:owlet/Widgets/LikeBtn.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:owlet/enum.dart';
import 'package:owlet/modals/ListingCommentModal.dart';
import 'package:owlet/models/Listing.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../constants/images.dart';

class ListingItemFooter extends StatelessWidget {
  const ListingItemFooter({
    required this.product,
    this.activeImage: 0,
    this.captionMaxLength,
    this.doubleTapToLike: false,
  });

  final int? captionMaxLength;
  final bool? doubleTapToLike;
  final Listing product;
  final int activeImage;

  @override
  Widget build(BuildContext context) {
    final state = GlobalProvider(context);
    Provider.of<ListingProvider>(context);
    final userData = Provider.of<UserProvider>(context);

    onLike(bool isLiked) async {
      if (state.authProListenFalse.isLoggedIn) {
        state.toggleLikeListing = product.id;

        final liked = isLiked ? product.unLike() : product.like();

        if (await liked && isLiked) state.toggleLikeListing = product.id;
        return liked;
      } else {
        Navigator.pushNamed(context, LoginScreen.routeName);
        return false;
      }
    }

    return Container(
      decoration: BoxDecoration(color: Palette.postFooterColor.withOpacity(0.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HStack(
                  [
                    15.widthBox,
                    LikeBtn(
                      isLiked: product.iLike,
                      likeCount: product.totalLikes,
                      onLike: onLike,
                    ),
                    Text(product.totalLikes.toString()),
                    15.widthBox,
                    IconBtn(

                      icon: CupertinoIcons.chat_bubble,
                      isImage: true,
                      imagePath:comments,

                      size: 22,
                      color: product.totalComments < 1
                          ? Colors.black54
                          : Palette.primaryColor,
                      onPressed: () =>
                          ListingCommentModal.show(context, product),
                    ),
                    2.widthBox,
                    Text(product.totalComments.toString()),
                    15.widthBox,
                    IconBtn(
                      size: 22,
                      imagePath: share,
                      isImage: true,
                      icon: CupertinoIcons.paperplane,
                      color: Colors.black54,
                      onPressed: userData.isLoggedIn
                          ? () {
                              userData.curChatUser = product.owner.chat;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    onPageEnter: () => Chatable(
                                      type: ChatableType.LISTING,
                                      listing: product,
                                    ),
                                  ),
                                ),
                              );
                            }
                          : () => Navigator.pushNamed(
                              context, LoginScreen.routeName),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
