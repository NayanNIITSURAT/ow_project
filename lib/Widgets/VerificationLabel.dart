import 'package:flutter/material.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:owlet/models/User.dart';
import 'package:velocity_x/velocity_x.dart';

class BadgeDecor {
  Color color;
  String text;
  IconData icon;

  BadgeDecor({
    this.color = Colors.grey,
    this.text: 'not verified',
    this.icon: Icons.not_interested,
  });
}

class VerificationLabel extends StatelessWidget {
  final User user;
  VerificationLabel({required this.user});

  @override
  Widget build(BuildContext context) {
    final badgeDecor =
        user.company != null && user.company!.verifyStatus == 'VERIFIED'
            ? BadgeDecor(
                color: Colors.green.shade100,
                icon: Icons.security,
                text: 'verified & secured')
            : user.confirmed
                ? BadgeDecor(color: Colors.orange, text: 'verified')
                : BadgeDecor();

    return HStack([
      VxAnimatedBox(
        child: HStack([
          Icon(
            user.confirmed ? Icons.security : Icons.not_interested,
            color: user.confirmed ? Vx.green400 : Vx.orange400,
            size: 18,
          ),
          10.widthBox,
          (user.confirmed ? 'Confirmed' : 'Not confirmed')
              .text
              .semiBold
              .color(Colors.black54)
              .make()
        ]),
      )
          .padding(EdgeInsets.symmetric(horizontal: 14, vertical: 6))
          .rounded
          .color(
              user.confirmed ? Colors.green.shade200 : Colors.orange.shade200)
          .border(color: user.confirmed ? Vx.green400 : Vx.orange400)
          .margin(EdgeInsets.symmetric(vertical: 10))
          .make(),
    ]);

    // Container(
    //   width: screenSize(context).width * 0.4,
    //   decoration: BoxDecoration(
    //     color: badgeDecor.color,
    //     borderRadius: BorderRadius.all(
    //       Radius.circular(50),
    //     ),
    //   ),
    //   padding: EdgeInsets.all(4),
    //   child: Row(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: [
    //       Icon(badgeDecor.icon, color: Colors.black54, size: 25),
    //       SizedBox(width: 4),
    //       Text(
    //         badgeDecor.text,
    //         style: TextStyle(
    //           // fontSize: 10,
    //           fontWeight: FontWeight.bold,
    //           // color: Colors.black54,
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
