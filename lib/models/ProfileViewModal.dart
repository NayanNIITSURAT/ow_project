import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:owlet/Components/Button.dart';
import 'package:owlet/Components/CircleButton.dart';
import 'package:owlet/Components/IconBtn.dart';
import 'package:owlet/Components/Loading.dart';
import 'package:owlet/Components/Pipe.dart';
import 'package:owlet/Components/ProfileAvatar.dart';
import 'package:owlet/Components/ReadMore.dart';
import 'package:owlet/Components/Toast.dart';
import 'package:owlet/Providers/Auth.dart';
import 'package:owlet/Providers/GlobalProvider.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Providers/UtilsProvider.dart';
import 'package:owlet/Screens/ChatScreen.dart';
import 'package:owlet/Screens/Followers.dart';
import 'package:owlet/Screens/Login.dart';
import 'package:owlet/Widgets/ListingGridView.dart';
import 'package:owlet/Widgets/ThreeLevelBadges.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:owlet/main.dart';
import 'package:owlet/modals/ProfileMenuModal.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

class ProfileViewModal extends StatefulWidget {
  final Function()? onPageEnter;
  final Function()? onPageLeave;

  const ProfileViewModal({
    Key? key,
    this.onPageEnter,
    this.onPageLeave,
  }) : super(key: key);
  static final show = (BuildContext ctx) => showCupertinoModalBottomSheet(
        context: ctx,
        builder: (context) => ProfileViewModal(),
        duration: Duration(milliseconds: 400),
        expand: false,
        barrierColor: Colors.black.withOpacity(0.4),
        backgroundColor: Colors.transparent,
        topRadius: Radius.zero,
        closeProgressThreshold: 0,
      );

  showWithCallback(BuildContext ctx,
          {Function()? onPageEnter, Function()? onPageLeave}) =>
      showCupertinoModalBottomSheet(
        context: ctx,
        builder: (context) => ProfileViewModal(
          onPageEnter: onPageEnter,
          onPageLeave: onPageLeave,
        ),
        duration: Duration(milliseconds: 400),
        expand: false,
        barrierColor: Colors.black.withOpacity(0.4),
        backgroundColor: Colors.transparent,
        topRadius: Radius.zero,
        closeProgressThreshold: 0,
      );

  @override
  State<ProfileViewModal> createState() => _ProfileViewModalState();
}

class _ProfileViewModalState extends State<ProfileViewModal> with RouteAware {
  @override
  void initState() {
    super.initState();
    Future.delayed(0.seconds,
        () => routeObserver.subscribe(this, ModalRoute.of(context)!));
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Called when the current route has been popped off.
  @override
  void didPop() {
    debugPrint("didPop $runtimeType");
    (widget.onPageLeave ?? () {})();
    super.didPop();
  }

  @override
  void didPush() {
    debugPrint("didPush $runtimeType");
    (widget.onPageEnter ?? () {})();
    super.didPush();
  }

  @override
  Widget build(BuildContext context) {
    // Providers
    final user = Provider.of<UserProvider>(context);
    final utility = Provider.of<UtilsProvider>(context);

    var seller = utility.currentSellerProfile;

    const counterTitleStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.grey,
    );
    const counterStyle = const TextStyle(
      fontSize: 24,
      color: Colors.black,
    );
    const space = SizedBox(height: 10);

    final whatsAppCaption = Uri.encodeComponent(
        '*New Chat From The Owlet* \n\n Hello ${seller != null ? seller.fullName : 'Seller'}, are you available for a chat?');
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            margin: EdgeInsets.only(top: 65),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: utility.sellerStatus == Status.Processing
                ? Center(
                    child: Loading(
                      message: 'Fetching user ',
                    ),
                  )
                : seller == null
                    ? Center(child: Text('User not found'))
                    : Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 40),
                            padding: EdgeInsets.all(15),
                            child: Column(
                              children: [
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                //   children: [
                                //     CircleButton(
                                //       icon: Icons.thumb_up_off_alt_outlined,
                                //       onPressed: () {},
                                //     ),
                                //     CircleButton(
                                //       icon: Icons.thumb_down_off_alt_outlined,
                                //       onPressed: () {},
                                //     )
                                //   ],
                                // ),
                                HStack([
                                  seller.username.text.bold.make(),
                                  5.widthBox,
                                  ThreeLevelBadges(user: seller),
                                ]),
                                space,
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    GestureDetector(
                                      child: Column(
                                        children: [
                                          Text(
                                              numFormatter(
                                                  seller.totalFollowers != null
                                                      ? seller.totalFollowers
                                                      : 0),
                                              style: counterStyle),
                                          Text(
                                            'Followers',
                                            style: counterTitleStyle,
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        user.getUserFollowers(seller.id,
                                            refresh: true);
                                        Navigator.pushNamed(
                                          context,
                                          Followers.routeName,
                                          arguments:
                                              FollowerScreenArguments(seller),
                                        );
                                      },
                                    ),
                                    Pipe(height: 30),
                                    Column(
                                      children: [
                                        Text(
                                          numFormatter(
                                              seller.totalListing != null
                                                  ? seller.totalListing
                                                  : 0),
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          'Products',
                                          style: counterTitleStyle,
                                        ),
                                      ],
                                    ),
                                    Pipe(height: 30),
                                    GestureDetector(
                                      child: Column(
                                        children: [
                                          Text(
                                              numFormatter(
                                                  seller.totalFollowing != null
                                                      ? seller.totalFollowing
                                                      : 0),
                                              style: counterStyle),
                                          Text(
                                            'Following',
                                            style: counterTitleStyle,
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        user.getUserFollowing(seller.id,
                                            refresh: true);
                                        Navigator.pushNamed(
                                          context,
                                          Followers.routeName,
                                          arguments: FollowerScreenArguments(
                                            seller,
                                            type: FollowType.FOLLOWING,
                                          ),
                                        );
                                      },
                                    ),
                                    // Pipe(height: 70),
                                    // Column(
                                    //   children: [
                                    //     Text(
                                    //       '700',
                                    //       style: counterStyle,
                                    //     ),
                                    //     Text(
                                    //       'REVIEWS',
                                    //       style: counterTitleStyle,
                                    //     ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                                space,
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Button(
                                        text: user.isLoggedIn && seller.iFollow
                                            ? 'Following'
                                            : 'Follow',
                                        press: user.isLoggedIn
                                            ? seller.iFollow
                                                ? () => user.unFollow(seller)
                                                : () => user
                                                    .followUser(seller)
                                                    .then((res) => Toast(
                                                            context,
                                                            message:
                                                                res['message'])
                                                        .show())
                                            : () => Navigator.of(context)
                                                .pushNamed(
                                                    LoginScreen.routeName),
                                        paddingHori: 5,
                                        paddingVert: 10,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    VxBox(
                                      child: Icon(
                                        CupertinoIcons.paperplane,
                                        color: Colors.black,
                                      ),
                                    )
                                        .withRounded(value: 5)
                                        .border(width: 0.3)
                                        .p8
                                        .make()
                                        .onInkTap(user.isLoggedIn
                                            ? () {
                                                user.curChatUser = seller.chat;
                                                Navigator.pushNamed(
                                                  context,
                                                  ChatScreen.routeName,
                                                );
                                              }
                                            : () => Navigator.pushNamed(context,
                                                LoginScreen.routeName)),

                                    // Button(
                                    //   text: 'Message',
                                    //   press: user.isLoggedIn
                                    //       ? () {
                                    //           user.curChatUser = seller.chat;
                                    //           Navigator.pushNamed(
                                    //             context,
                                    //             ChatScreen.routeName,
                                    //           );
                                    //         }
                                    //       : () => Navigator.pushNamed(
                                    //           context, LoginScreen.routeName),
                                    //   color: Colors.blue,
                                    //   paddingHori: 5,
                                    //   paddingVert: 10,
                                    // ),
                                    IconBtn(
                                      size: 30,
                                      paddingLeft: 5,
                                      icon: Icons.more_vert,
                                      color: Colors.black87,
                                      onPressed: () =>
                                          showCupertinoModalBottomSheet(
                                        context: context,
                                        builder: (context) => Container(
                                          child: ProfileMenuModal(),
                                        ),
                                        duration: Duration(milliseconds: 400),
                                        expand: false,
                                        barrierColor:
                                            Colors.black.withOpacity(0.4),
                                      ),
                                    ),
                                  ],
                                ),
                                space,
                                if (seller.bio != null &&
                                    seller.bio!.length > 0)
                                  seller.bio!.richText.justify
                                      .size(12)
                                      .maxLines(5)
                                      .make()
                                      .w(double.infinity),
                                // space,
                                // Container(
                                //   child: Column(
                                //     crossAxisAlignment: CrossAxisAlignment.start,
                                //     children: [
                                //       Text(
                                //         "Products",
                                //         style: TextStyle(
                                //           fontWeight: FontWeight.bold,
                                //           color: Palette.primaryColor,
                                //           fontSize: 20,
                                //         ),
                                //       ),
                                //       SizedBox(height: 5),
                                //     ],
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          ListingGridView(
                            listings: utility.sellerListing,
                            load: () => utility.getUserListings(),
                            refresh: () =>
                                utility.getUserListings(refresh: true),
                            providerType: ListingProviderType.SELLER,
                            isLoading: utility.sellerListingStatus ==
                                    Status.Processing &&
                                utility.sellerListing.length < 1,
                          ),
                        ],
                      ),
          ),
          if (seller != null && utility.sellerStatus != Status.Processing)
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10),
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleButton(
                        icon: Icons.phone,
                        color: Colors.white,
                        bgColor: Palette.primaryColor,
                        onPressed: () => customLaunch('tel:${seller.phone}'),
                      ),
                      ProfileAvatar(
                        size: 90,
                        avatar: seller.avartar,
                        storyNum: seller.stories.length,
                      ),
                      CircleButton(
                        icon: MdiIcons.whatsapp,
                        color: Colors.white,
                        bgColor: Color(0xFF4BC85B),
                        onPressed: () => customLaunch(
                            'https://wa.me/${seller.phone}?text=${whatsAppCaption}'),
                      ),
                      // CircleButton(
                      //   icon: MdiIcons.chatPlusOutline,
                      //   color: Colors.white,
                      //   bgColor: Colors.blue[300],
                      //   onPressed: () {},
                      // ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
