import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:owlet/Components/Input.dart';
import 'package:owlet/Providers/Auth.dart';
import 'package:owlet/Providers/UtilsProvider.dart';
import 'package:owlet/Screens/SearchScreen.dart';
import 'package:owlet/Widgets/BottomModalLayout.dart';
import 'package:owlet/models/User.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../constants/palettes.dart';

class UsersModal extends StatelessWidget {
  static var show = (BuildContext ctx, {Function(User)? callBack}) =>
      showCupertinoModalBottomSheet(
        context: ctx,
        builder: (context) => Container(
          child: UsersModal(ctx: context, callBack: callBack),
        ),
        duration: Duration(milliseconds: 400),
        expand: true,
        barrierColor: Colors.black.withOpacity(0.4),
      );
  final BuildContext ctx;
  final Function(User)? callBack;
  const UsersModal({required this.ctx, this.callBack});

  @override
  Widget build(BuildContext context) {
    final utility = Provider.of<UtilsProvider>(ctx);
    onInput(String query) async => await utility.searchAll(query);

    return BottomModalLayout(bgColor: Colors.white, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Input(
          islable: false,
          preWidget: utility.searchStatus == Status.Processing
              ? CupertinoActivityIndicator()
              : null,
          padding: const EdgeInsets.symmetric(vertical: 3),
          icon: Icons.search,
          hintText: "Search",
          rightIcon: Icons.search,
          width: double.infinity,
          containtpadding: EdgeInsets.fromLTRB(10, 11, 0, 11),
          elevate: false,
          onSaved: (val) => onInput(val ?? ''),
          bgColor: fieldcolor,
          radius: 10,
        ),
      ),
      AccountList(
        data: utility,
        isChat: true,
        callBack: callBack,
      ).expand(),
    ]);
  }
}