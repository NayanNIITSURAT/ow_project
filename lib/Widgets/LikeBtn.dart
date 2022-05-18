import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:owlet/constants/palettes.dart';

class LikeBtn extends StatelessWidget {
  const LikeBtn({
    Key? key,
    this.onLike,
    this.size,
    this.isLiked,
    this.likeCount,
    this.icon,
  });

  final double? size;
  final IconData? icon;
  final bool? isLiked;
  final int? likeCount;
  final Future<bool?> Function(bool)? onLike;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: LikeButton(
        likeCountPadding: EdgeInsets.all(0),
        isLiked: isLiked,
        // likeCount: likeCount,
        likeBuilder: (isLiked) => Icon(
          isLiked ? CupertinoIcons.heart_fill : icon ?? CupertinoIcons.heart,
          color: isLiked ? Palette.primaryColor : Colors.black54,
          size: size,
        ),
        onTap: onLike,
      ),
    );
  }
}
