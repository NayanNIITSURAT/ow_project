import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:owlet/Screens/SingleListingScreen.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:owlet/enum.dart';
import 'package:owlet/main.dart';
import 'package:owlet/models/Listing.dart';
import 'package:owlet/models/Story.dart';
import 'package:owlet/models/User.dart';
import 'package:velocity_x/velocity_x.dart';

class Chatable {
  final ChatableType type;
  final Story? story;
  final Listing? listing;
  final User? user;
  final File? file;
  final Position? location;
  Chatable({
    required this.type,
    this.story,
    this.listing,
    this.user,
    this.file,
    this.location,
  });

  Function onTap(BuildContext context) {
    switch (type) {
      case ChatableType.LISTING:
        return () => Navigator.pushNamed(context, SingleListingScreen.routeName,
            arguments: SingleListingArgs(
              id: listing!.id,
            )
        );
      case ChatableType.STORY:
        return () => print(story.toString());
      // case ChatableType.LISTING:
      //   return () => Navigator.pushNamed(context, SingleListingScreen.routeName,
      //       arguments: SingleListingArgs(
      //         id: listing!.id,
      //       ));
      // case ChatableType.LISTING:
      //   return () => Navigator.pushNamed(context, SingleListingScreen.routeName,
      //       arguments: SingleListingArgs(
      //         id: listing!.id,
      //       ));
      // case ChatableType.LISTING:
      //   return () => Navigator.pushNamed(context, SingleListingScreen.routeName,
      //       arguments: SingleListingArgs(
      //         id: listing!.id,
      //       ));
      default:
        return () {};
    }
  }

  Widget build(BuildContext context, {Function()? onChatableClose}) {
    String _username = '';
    String _type = '';
    String _caption = '';
    String? _thumbnail = '';

    switch (type) {
      case ChatableType.LISTING:
        _username = listing!.owner.username;
        _type = 'listing';
        _caption = listing!.caption;
        _thumbnail = listing!.images[0];

        break;
      case ChatableType.STORY:
        _caption =
            (story!.type == StoryType.TEXT ? story!.content : story!.caption) ??
                '--';
        _username = story!.user!.username;
        _thumbnail = story!.type == StoryType.IMAGE
            ? cloudinary.getImage(story!.content).url
            : story!.type == StoryType.VIDEO
                ? 'https://res.cloudinary.com/cybertech-digitals-ltd/video/upload/${story!.content}.jpg'
                : null;
        _type = 'story';

        break;
      default:
        _username = '';
        _type = '';
        _caption = '';
        _thumbnail = '';
    }
    return VxBox(
      child: HStack(
        [
          VStack(
            [
              '@$_username ~ $_type'
                  .text
                  .semiBold
                  .capitalize
                  .color(Palette.primaryColor)
                  .maxFontSize(12)
                  .make()
                  .box
                  .withConstraints(BoxConstraints(
                      maxWidth: (context.screenSize.width * 0.6 - 17)))
                  .make(),
              5.heightBox,
              _caption.richText
                  .maxLines(3)
                  .ellipsis
                  .size(11)
                  .semiBold
                  .color(Colors.black54)
                  .ellipsis
                  .make()
                  .box
                  .withConstraints(BoxConstraints(
                      maxWidth: (context.screenSize.width *
                              (_thumbnail != null ? 0.6 : 0.8) -
                          17)))
                  .make(),
            ],
            axisSize: MainAxisSize.min,
          ).box.p8.make(),
          if (_thumbnail != null)
            VxBox(
              child: onChatableClose == null
                  ? null
                  : VxBadge(
                      optionalWidget: Icon(
                        Icons.close,
                        size: 15,
                        color: Colors.black,
                      ),
                      child: SizedBox(),
                      color: Colors.white.withOpacity(0.8),
                      size: 18,
                    ).onTap(onChatableClose),
            )
                .height(context.screenSize.width * 0.2)
                .p8
                .width(context.screenSize.width * 0.2)
                .bgImage(
                  DecorationImage(
                    image: NetworkImage(_thumbnail),
                    fit: BoxFit.cover,
                  ),
                )
                .make(),
        ],
        alignment: MainAxisAlignment.spaceBetween,
        axisSize: MainAxisSize.min,
      ),
    )
        .withConstraints(
            BoxConstraints(minWidth: context.screenSize.width * 0.4))
        .color(Colors.white)
        .border(width: 0.5, color: Colors.grey)
        .rounded
        // .alignTopLeft
        .clip(Clip.hardEdge)
        .make()
        .onInkTap((() {}));
  }
}
