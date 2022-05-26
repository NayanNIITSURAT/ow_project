import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:owlet/Components/CircleButton.dart';
import 'package:path/path.dart';

import '../constants/palettes.dart';

class GalleryThumbnail extends StatelessWidget {
  final File? file;
  final Function()? onPressed;
  final Function()? onDelete;

  GalleryThumbnail({
    required this.file,
    this.onPressed,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    String filename = basename(file!.path);
    String ext = filename.split(".").last;
    return GestureDetector(
      child: Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          child: ext != "mp4"
              ? Image.file(
                  file!,
                  height: 700,
                  width: 700,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  "assets/images/vthumb.png",
                  fit: BoxFit.fitWidth,
                ),
        ),
        Positioned(
          child: InkWell(
            onTap: onDelete,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kErrorColor,
              ),
              child: Icon(
                Icons.remove,
                size: 18,
                color: kContentColorDarkTheme,
              ),
            ),
          ),
          top: 5,
          right: 5,
        ),
      ]),
      onTap: onPressed,
    );
  }
}
