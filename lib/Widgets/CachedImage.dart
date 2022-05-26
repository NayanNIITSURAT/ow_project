import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {
  const CachedImage({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

  final String imageUrl;

  @override
  Widget build(BuildContext context) {

    String ext = imageUrl.toString().split(".").last;



    return ext != "mp4"
        ? CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            progressIndicatorBuilder: (_, st, status) =>
                CupertinoActivityIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
            // useOldImageOnUrlChange: true,
          )
        : Image.asset(
            "assets/images/vthumb.png",
            fit: BoxFit.fitWidth,
          );
  }
}
