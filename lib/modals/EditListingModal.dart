import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:owlet/Components/Button.dart';
import 'package:owlet/Components/Toast.dart';
import 'package:owlet/Providers/GlobalProvider.dart';
import 'package:owlet/Screens/AddListingScreen.dart';
import 'package:owlet/Widgets/BottomModalLayout.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:owlet/models/Listing.dart';

class EditListingModal extends StatefulWidget {
  static var show =
      (BuildContext ctx, Listing post) => showCupertinoModalBottomSheet(
            context: ctx,
            builder: (context) => Container(
              child: EditListingModal(listing: post),
            ),
            duration: Duration(milliseconds: 400),
            expand: false,
            barrierColor: Colors.black.withOpacity(0.4),
          );
  final Listing listing;

  const EditListingModal({required this.listing});

  @override
  State<EditListingModal> createState() => _EditListingModalState();
}

class _EditListingModalState extends State<EditListingModal> {
  String caption = '';
  bool updating = false;

  @override
  void initState() {
    caption = widget.listing.caption;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userData = GlobalProvider(context).userProvider;
    final listingData = GlobalProvider(context).listingProvider;

    void updateListing() async {
      setState(() {
        updating = true;
      });
      var msg = '';
      try {
        if (caption.length > 0) {
          if (!hasHashtag(caption)) {
            Toast(
              context,
              message: 'Your caption must contain at least one hashtag',
              duration: Duration(seconds: 5),
              type: ToastType.ERROR,
            ).showTop();
            throw 'Your caption must contain at least one hashtag';
          }
          var res = await listingData.updateListing(caption, widget.listing.id);
          if (res['status']) {
            userData.updateListing = res['data'];
            msg = res['message'];
            Navigator.pop(context);
          } else
            throw res['message'];
        } else
          throw 'Caption required';
      } catch (e) {
        msg = e.toString();
      }
      Toast(context, message: msg, type: ToastType.SUCCESS).show();
      setState(() {
        updating = false;
      });
    }

    // final updating = listingData.listingStatus == Status.Updating;

    return BottomModalLayout(
      children: [
        EditListing(
          caption: caption,
          onChange: (input) => setState(() => caption = input),
        ),
        SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: Button(
            text: updating ? 'Saving...' : 'Save',
            press: widget.listing.caption == caption
                ? () => Navigator.pop(context)
                : updating
                    ? () => null
                    : updateListing,
            paddingHori: 5,
            paddingVert: 10,
            color: updating ? Colors.grey : Palette.primaryColor,
          ),
        ),
      ],
    );
  }
}
