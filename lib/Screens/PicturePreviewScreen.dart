import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:owlet/Components/IconBtn.dart';
import 'package:owlet/Components/Toast.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Widgets/ChatInputBar.dart';
import 'package:owlet/Widgets/CloseBtn.dart';
import 'package:owlet/enum.dart';
import 'package:owlet/services/stories.dart';

class PicturePreviewScreen extends StatefulWidget {
  static const routeName = 'picture-preview';

  final XFile pictureFile;

  const PicturePreviewScreen({
    Key? key,
    required this.pictureFile,
  }) : super(key: key);

  @override
  _PicturePreviewScreenState createState() => _PicturePreviewScreenState();
}

class _PicturePreviewScreenState extends State<PicturePreviewScreen> {
  late File _picture;
  // String _caption = '';
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _picture = File(widget.pictureFile.path);
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }

  // _cropPicture() async {
  //   _picture = await ImageCropper.cropImage(
  //         compressFormat: ImageCompressFormat.jpg,
  //         sourcePath: _picture.path,
  //       ) ??
  //       _picture;
  //   setState(() {});
  // }

  _addStory(String? caption) async {
    final userData = Provider.of<UserProvider>(context, listen: false);

    await userData.addSory(
      newStory: NewStory(
        content: '',
        type: StoryType.IMAGE,
        caption: caption,
        mediaFile: _picture,
      ),
      onProgress: (_) => setState(() => _uploadProgress = (_)),
      onSuccess: () => Navigator.of(context).popUntil((route) => route.isFirst),
      onError: (e) {
        print(e);
        Toast(context, message: 'Error occured while uploading your story');
      },
      onComplete: () => setState(() => _uploadProgress = 0.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Vx.black,
      body: ZStack([
        VxAnimatedBox(
          // width: context.screenWidth,
          // height: context.screenHeight,
          child: Image.file(File(_picture.path)),
        ).alignCenter.animDuration(1.seconds).make(),
        SafeArea(
          child: VStack(
            [
              HStack(
                [
                  CloseBtn(),
                  IconBtn(
                    icon: Icons.crop_rotate,
                    color: Vx.white,
                    onPressed: (){}
                    // _cropPicture,
                  ),
                ],
                alignment: MainAxisAlignment.spaceBetween,
                axisSize: MainAxisSize.max,
              ),
              CircularProgressIndicator(
                value: _uploadProgress,
                strokeWidth: 3,
              ),
              ChatInputBar(
                onSend: _addStory,
                hint: 'Add caption...',
                setFocus: false,
              ),
            ],
            alignment: MainAxisAlignment.spaceBetween,
            axisSize: MainAxisSize.max,
            crossAlignment: CrossAxisAlignment.center,
          ).p16(),
        )
      ]),
    );
  }
}

class WithLoader extends StatelessWidget {
  final Widget child;
  final bool loading;
  final Color? overlayColor;
  const WithLoader({
    Key? key,
    required this.child,
    required this.loading,
    this.overlayColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZStack([
      child,
      VxBox().make(),
    ]);
  }
}
