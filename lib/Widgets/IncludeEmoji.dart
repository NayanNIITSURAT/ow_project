import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:owlet/constants/palettes.dart';

class IncludeEmoji extends StatelessWidget {
  const IncludeEmoji({
    Key? key,
    this.showEmoji: false,
    required this.onEmojiSelected,
    this.onBackspacePressed,
  }) : super(key: key);

  final bool showEmoji;
  final Function(Emoji) onEmojiSelected;
  final Function()? onBackspacePressed;

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: !showEmoji,
      child: SizedBox(
        height: 250,
        child: EmojiPicker(
          onEmojiSelected: (Category category, Emoji emoji) {
            onEmojiSelected(emoji);
          },
          onBackspacePressed: onBackspacePressed,
          config: Config(
            columns: 8,
            // Issue: https://github.com/flutter/flutter/issues/28894

            emojiSizeMax: 28 * (Platform.isIOS ? 1.30 : 1.0),
            verticalSpacing: 0,
            horizontalSpacing: 0,
            initCategory: Category.RECENT,
            bgColor: const Color(0xFFF2F2F2),
            indicatorColor: Palette.primaryColor,
            iconColor: Colors.grey,
            iconColorSelected: Palette.primaryColor,
            progressIndicatorColor: Palette.primaryColor,
            backspaceColor: Palette.primaryColor,
            skinToneDialogBgColor: Colors.white,
            skinToneIndicatorColor: Colors.grey,
            enableSkinTones: true,
            showRecentsTab: true,
            recentsLimit: 28,
            noRecentsText: 'No Recents',
            noRecentsStyle:
                const TextStyle(fontSize: 20, color: Colors.black26),
            tabIndicatorAnimDuration: kTabScrollDuration,
            categoryIcons: const CategoryIcons(),
            buttonMode: ButtonMode.MATERIAL,
          ),
        ),
      ),
    );
  }
}
