import 'package:flutter/material.dart';
import 'package:owlet/models/User.dart';

class ThreeLevelBadges extends StatelessWidget {
  final User user;
  ThreeLevelBadges({required this.user});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        children: !user.confirmed
            ? [Icon(Icons.unpublished, color: Colors.grey, size: 16)]
            : [
                Icon(Icons.security, color: Colors.green, size: 16),
                SizedBox(width: 3),
                if (user.hasVerifiedCompany)
                  Icon(Icons.verified, color: Colors.blue, size: 16),
                // else if (user.company != null)
                //   Icon(Icons.verified, color: Colors.grey.shade300, size: 16),
              ],
      ),
    );
  }
}
