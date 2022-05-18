import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:owlet/Components/Button.dart';
import 'package:owlet/Components/IconTextBtn.dart';
import 'package:owlet/Components/Pipe.dart';
import 'package:owlet/Components/Toast.dart';
import 'package:owlet/Providers/Auth.dart';
import 'package:owlet/Providers/Listing.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Providers/UtilsProvider.dart';
import 'package:owlet/Widgets/BottomModalLayout.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:provider/provider.dart';

class ProfileMenuModal extends StatelessWidget {
  // final Listing listing;

  // const ProfileMenuModal({required this.listing});
  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserProvider>(context);
    final utilData = Provider.of<UtilsProvider>(context);
    final listingData = Provider.of<ListingProvider>(context);
    final seller = utilData.currentSellerProfile!;

    final onBlock = () async {
      if (Navigator.canPop(context)) Navigator.pop(context);
      final res = await userData.blockSeller(seller);
      if (res['status']) {
        listingData.unfollowUser = seller;
      }
      if (Navigator.canPop(context)) Navigator.pop(context);

      Toast(
        context,
        message: res['message'],
        bgColor: res['status'] ? null : Colors.red,
      ).show();
    };
    final loading = userData.blockingStatus == Status.Blocking;

    void _blockUser() {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
                content: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Column(
                        children: [
                          Text(
                            'Block ${seller.username}',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          SizedBox(height: 5),
                          Divider(height: 0.3),
                          SizedBox(height: 10),
                          Text(
                            'This user won\'t be able to find your profile, post or contact your on The Owlet.',
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: loading
                                ? CupertinoActivityIndicator()
                                : Button(
                                    press: () => loading ? null : onBlock(),
                                    text: 'BLOCK',
                                    paddingHori: 5,
                                    paddingVert: 15,
                                    color: Colors.grey.shade100,
                                    textColor: Palette.primaryColor,
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Pipe(height: 35),
                          ),
                          Expanded(
                            child: Button(
                              press: () => Navigator.pop(context),
                              text: 'CANCEL',
                              paddingHori: 5,
                              paddingVert: 15,
                              color: Colors.grey.shade100,
                              textColor: Colors.grey,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ));
    }
    // final bool userIsOwner = userData.isLoggedIn &&
    //     (userData.profile.id == listing.owner.id || userData.profile.isAdmin);
    // final User owner = userIsOwner ? userData.profile : listing.owner;

    final ownerMenu = [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconTextBtn(
            iconColor: Colors.red,
            text: 'Block ${seller.username}',
            onPressed: () => loading ? null : _blockUser(),
            icon: Icons.block,
          ),
          loading ? CupertinoActivityIndicator() : Column()
        ],
      ),
    ];
    return BottomModalLayout(
      children: ownerMenu,
    );
  }
}
