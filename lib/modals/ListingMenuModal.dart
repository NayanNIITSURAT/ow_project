import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:owlet/Components/IconTextBtn.dart';
import 'package:owlet/Components/Toast.dart';
import 'package:owlet/Providers/Auth.dart';
import 'package:owlet/Providers/Listing.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Providers/UtilsProvider.dart';
import 'package:owlet/Screens/Login.dart';
import 'package:owlet/Widgets/BottomModalLayout.dart';
import 'package:owlet/modals/EditListingModal.dart';
import 'package:owlet/modals/FlagModal.dart';
import 'package:owlet/models/Listing.dart';
import 'package:owlet/models/User.dart';
import 'package:provider/provider.dart';

class ListingMenuModal extends StatelessWidget {
  final Listing listing;

  const ListingMenuModal({required this.listing});
  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserProvider>(context);
    final utilData = Provider.of<UtilsProvider>(context);
    final listingData = Provider.of<ListingProvider>(context);

    final onDelete = () async {
      final res = await userData.deleteUserListing(listing.id);
      if (res['status']) listingData.removeListing = res['listingId'] as int;

      Toast(
        context,
        message: res['message'],
        bgColor: res['status'] ? null : Colors.red,
      ).show();
      if (Navigator.canPop(context)) Navigator.pop(context);
      if (Navigator.canPop(context)) Navigator.pop(context);
    };
    final bool userIsOwner = userData.isLoggedIn &&
        (userData.profile.id == listing.owner.id || userData.profile.isAdmin);
    final User owner = userIsOwner ? userData.profile : listing.owner;

    final guestMenu = [
      IconTextBtn(
        text: 'Flag post',
        onPressed: () {
          Navigator.pop(context);
          userData.isLoggedIn
              ? FlagModal.show(context, listing)
              : Navigator.pushNamed(context, LoginScreen.routeName);
        },
      ),
      IconTextBtn(
        text: 'Hide post',
        onPressed: () {
          Navigator.pop(context);
          listingData.hideListing = listing.id;
          utilData.hideListing = listing.id;
          Toast(context, message: 'Post hidden').show();
        },
      ),
      IconTextBtn(
        text: userData.isLoggedIn && owner.iFollow
            ? 'Unfollow owner'
            : 'Follow owner',
        onPressed: userData.isLoggedIn
            ? (owner.iFollow)
                ? () {
                    Navigator.pop(context);
                    userData.unFollow(owner);
                    listingData.unfollowUser = owner;
                  }
                : () => userData.followUser(owner).then(
                    (res) => Toast(context, message: res['message']).show())
            : () => Navigator.of(context).pushNamed(LoginScreen.routeName),
      ),
    ];
    final ownerMenu = [
      IconTextBtn(
        iconColor: Colors.green,
        text: 'Edit',
        onPressed: () {
          Navigator.pop(context);
          userData.isLoggedIn
              ? EditListingModal.show(context, listing)
              : Navigator.pushNamed(context, LoginScreen.routeName);
        },
        icon: Icons.edit,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconTextBtn(
            iconColor: Colors.red,
            text: 'Delete',
            onPressed: () => onDelete(),
            icon: Icons.delete,
          ),
          userData.listingStatus == Status.Deleting
              ? CupertinoActivityIndicator()
              : Column()
        ],
      ),
    ];
    return BottomModalLayout(
      children: userIsOwner ? ownerMenu : guestMenu,
    );
  }
}
