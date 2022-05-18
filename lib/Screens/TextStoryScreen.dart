import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:flutter/material.dart';
import 'package:owlet/Components/IconBtn.dart';
import 'package:owlet/Components/Toast.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Widgets/StoryBgColor.dart';
import 'package:owlet/Widgets/WithDismissible.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:owlet/enum.dart';
import 'package:owlet/services/stories.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

class TextStoryScreen extends StatefulWidget {
  static const routeName = 'text-story-screen';
  const TextStoryScreen({Key? key}) : super(key: key);

  @override
  _TextStoryScreenState createState() => _TextStoryScreenState();
}

class _TextStoryScreenState extends State<TextStoryScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  Color selectedColor = Palette.primaryColor;
  String _story = '';
  double _uploadProgress = 0;

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
  }

  _addStory() async {
    final userData = Provider.of<UserProvider>(context, listen: false);

    await userData.addSory(
      newStory: NewStory(
        content: _story,
        type: StoryType.TEXT,
        caption: selectedColor.value.toRadixString(16),
      ),
      onSuccess: () => Navigator.pop(context),
      onError: (e) =>
          Toast(context, message: 'Error occured while uploading your story')
              .show(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> bgColors = [
      Palette.primaryColor,
      Colors.green,
      Colors.black,
      Colors.blue,
      Colors.purple,
      Colors.pink,
      Colors.grey,
      Colors.red,
      Colors.indigo,
      Colors.teal,
      Colors.deepOrange,
      Colors.cyan.shade600,
      Colors.brown,
    ];
    return WithDismissible(
      child: Scaffold(
        backgroundColor: selectedColor,
        body: SafeArea(
          child: VStack(
            [
              10.heightBox,
              _uploadProgress > 0
                  ? CircularProgressIndicator(
                      value: _uploadProgress,
                      strokeWidth: 3,
                    )
                  : IconBtn(
                      icon: Icons.check,
                      color: Colors.white,
                      onPressed: _addStory,
                    ).objectTopRight().px16(),
              VxBox(
                child: AutoSizeTextField(
                  controller: _textEditingController,
                  style: TextStyle(fontSize: 60, color: Vx.white),
                  // presetFontSizes: [60, 50, 35, 20],
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 0)),
                  minFontSize: 20,
                  maxLines: null,
                  minLines: null,
                  // maxLengthEnforced: true,
                  // maxLength: 600,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  cursorColor: Vx.white,
                  onChanged: (e) => setState(() {
                    _story = e;
                  }),
                  // maxLength: 700,
                  // expands: true,
                  textAlignVertical: TextAlignVertical.center,
                ),
              ).make().centered().expand(),
              ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: bgColors
                    .map(
                      (color) => StoryBgColor(
                        color: color,
                        glow: color == selectedColor,
                        onPress: () => setState(() => selectedColor = color),
                      ),
                    )
                    .toList(),
              ).h(40).p4().backgroundColor(Colors.white60).centered(),
            ],
          ),
        ),
      ),
    );
  }
}
