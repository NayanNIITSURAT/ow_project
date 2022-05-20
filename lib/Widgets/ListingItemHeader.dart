import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:owlet/Components/IconBtn.dart';
import 'package:owlet/Components/ImageBtn.dart';
import 'package:owlet/Components/ProfileAvatar.dart';
import 'package:owlet/Components/ReadMore.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Providers/UtilsProvider.dart';
import 'package:owlet/Screens/ChatScreen.dart';
import 'package:owlet/Screens/Login.dart';
import 'package:owlet/Screens/ProfileScreen.dart';
import 'package:owlet/Widgets/Chatable.dart';
import 'package:owlet/Widgets/ThreeLevelBadges.dart';
import 'package:owlet/constants/images.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:owlet/enum.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:owlet/modals/ListingMenuModal.dart';
import 'package:owlet/modals/ProfileViewModal.dart';
import 'package:owlet/models/Listing.dart';
import 'package:owlet/models/User.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

class ListingItemHeader extends StatelessWidget {
  ListingItemHeader(
      {required this.product, this.captionMaxLength, this.chatmess});

  final Listing product;
  final int? captionMaxLength;
  bool? chatmess;

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserProvider>(context);
    final bool userIsOwner =
        userData.isLoggedIn && userData.profile.id == product.owner.id;
    final User owner = userIsOwner ? userData.profile : product.owner;
    final whatsAppCaption = Uri.encodeComponent(
        '*New Order From The Owlet* \n\n I\'m interested in the item among your listings with this caption: \n _${product.caption}_');

    return Container(
      // decoration: BoxDecoration(
      //     border: Border(left: BorderSide(width: 4, color: badgeDecor.color))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (userIsOwner)
                        Navigator.pushNamed(context, ProfileScreen.routeName);
                      else {
                        ProfileViewModal.show(context);
                        await Provider.of<UtilsProvider>(context, listen: false)
                            .getCurrentSellerProfile(owner);
                      }
                    },
                    child: Row(
                      children: [
                        ProfileAvatar(
                          avatar: owner.avartar,
                          size: 50,
                          isOnline: owner.isOnline,
                        ),
                        5.widthBox,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            HStack(
                              [
                                ReadMore(
                                  caption: owner.username,
                                  maxLength: 12,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  showReadmore: false,
                                ),
                                ThreeLevelBadges(user: owner)
                              ],
                            ),
                            if (owner.hasVerifiedCompany)
                              ReadMore(
                                caption: owner.company!.name,
                                maxLength: 25,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                    color: Colors.black54),
                                showReadmore: false,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  chatmess == true
                      ? Row(
                          children: [
                            ImageBtn(
                                size: 20,
                                paddingLeft: 10,
                                assetString: chat_icon,
                                isSvg: true,
                                color: Palette.primaryColor,
                                onPressed: userData.isLoggedIn
                                    ? () {
                                        userData.curChatUser = owner.chat;
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatScreen(
                                              onPageEnter: () => Chatable(
                                                //chatableId: product.id,
                                                type: ChatableType.LISTING,
                                                listing: product,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    : () => Navigator.pushNamed(
                                        context, LoginScreen.routeName)),
                            IconBtn(
                              size: 20,
                              paddingLeft: 15,
                              icon: Icons.more_vert,
                              color: Colors.black87,
                              onPressed: () => showCupertinoModalBottomSheet(
                                context: context,
                                builder: (context) => Container(
                                  child: ListingMenuModal(listing: product),
                                ),
                                duration: Duration(milliseconds: 400),
                                expand: false,
                                barrierColor: Colors.black.withOpacity(0.4),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            // ImageBtn(
                            //     size: 20,
                            //     paddingLeft: 10,
                            //     assetString: chat_icon,
                            //     isSvg: true,
                            //     color: Palette.primaryColor,
                            //     onPressed: userData.isLoggedIn
                            //         ? () {
                            //             userData.curChatUser = owner.chat;
                            //             Navigator.push(
                            //               context,
                            //               MaterialPageRoute(
                            //                 builder: (context) => ChatScreen(
                            //                   onPageEnter: () => Chatable(
                            //                     //chatableId: product.id,
                            //                     type: ChatableType.LISTING,
                            //                     listing: product,
                            //                   ),
                            //                 ),
                            //               ),
                            //             );
                            //           }
                            //         : () => Navigator.pushNamed(
                            //             context, LoginScreen.routeName)),
                            IconBtn(
                              size: 20,
                              paddingLeft: 15,
                              icon: Icons.more_vert,
                              color: Colors.black87,
                              onPressed: () => showCupertinoModalBottomSheet(
                                context: context,
                                builder: (context) => Container(
                                  child: ListingMenuModal(listing: product),
                                ),
                                duration: Duration(milliseconds: 400),
                                expand: false,
                                barrierColor: Colors.black.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ReadMore(
                    caption: product.caption,
                    username: product.owner.username,
                    maxLength: captionMaxLength ?? 90,
                  ),
                ),
                // DateFormat("dd, MMM")
                //     .format(
                //         DateTime.tryParse(product.createdAt) ?? DateTime.now())
                //     .text
                //     .sm
                //     .gray400
                //     .make()
              ],
            ),
          ],
        ),
      ),
    );
  }
}
