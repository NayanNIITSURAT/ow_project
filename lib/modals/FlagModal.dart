import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:owlet/Components/IconTextBtn.dart';
import 'package:owlet/Components/Toast.dart';
import 'package:owlet/Providers/Auth.dart';
import 'package:owlet/Providers/Flag.dart';
import 'package:owlet/Widgets/BottomModalLayout.dart';
import 'package:owlet/models/Listing.dart';
import 'package:provider/provider.dart';

class FlagModal extends StatelessWidget {
  static var show =
      (BuildContext ctx, Listing post) => showCupertinoModalBottomSheet(
    context: ctx,
    builder: (context) => Container(
      child: FlagModal(post: post),
    ),
    duration: Duration(milliseconds: 400),
    expand: false,
    barrierColor: Colors.black.withOpacity(0.4),
  );
  final Listing post;
  const FlagModal({required this.post});

  @override
  Widget build(BuildContext context) {
    final flagProvider = Provider.of<FlagProvider>(context);
    final onFlag = (int flagId) async {
      final res = await flagProvider.flagPost(NewFlag(
        flagId: flagId,
        listingId: post.id,
      ));
      // Navigator.pop(context);
      Toast(
        context,
        message: res['message'],
        bgColor: res['status'] ? null : Colors.red,
      ).show();
    };
    return BottomModalLayout(children: [
      Padding(
        padding: const EdgeInsets.all(7.0),
        child: Column(
          children: [
            Text(
              'Reason for flagging this post?',
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 10),
            Text(
              'Don\'t worry, your request would be anonymous. Kindly make sure your reason violates our terms and condition to avoid account suspension or deactivation',
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ],
        ),
      ),
      flagProvider.flagingStatus == Status.Processing
          ? Center(
        child: CupertinoActivityIndicator(),
      )
          : Column(),
      ...(flagProvider.flagStatus == Status.Processing
          ? [
        Center(
          child: CupertinoActivityIndicator(),
        )
      ]
          : flagProvider.items.map((flag) => FlagBtn(
        text: flag.name,
        onPressed: () async => await onFlag(flag.id),
      ))),
    ]);
  }
}

class FlagBtn extends StatelessWidget {
  const FlagBtn({
    required this.onPressed,
    required this.text,
  });
  final Function onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return IconTextBtn(
      text: text,
      onPressed: () async {
        await onPressed();
        if (Navigator.canPop(context)) Navigator.pop(context);
      },
    );
  }
}
