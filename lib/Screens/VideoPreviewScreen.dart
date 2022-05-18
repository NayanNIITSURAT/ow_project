import 'dart:io';

import 'package:flutter/material.dart';
import 'package:owlet/Components/CircleButton.dart';
import 'package:owlet/Components/Toast.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Screens/CameraScreen.dart';
import 'package:owlet/Screens/NavScreen.dart';
import 'package:owlet/enum.dart';
import 'package:owlet/services/stories.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:owlet/Components/IconBtn.dart';
import 'package:owlet/Widgets/ChatInputBar.dart';
import 'package:owlet/Widgets/CloseBtn.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewScreen extends StatefulWidget {
  static const routeName = 'video-preview';

  final File videoFile;

  const VideoPreviewScreen({
    Key? key,
    required this.videoFile,
  }) : super(key: key);

  @override
  _VideoPreviewScreenState createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  // late File _video;
  late VideoPlayerController _controller;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();

    initVideoPlayer();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  initVideoPlayer() {
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {});
      });
    _controller.addListener(checkVideo);
  }

  void checkVideo() {
    // Implement your calls inside these conditions' bodies :
    if (_controller.value.position ==
        Duration(seconds: 0, minutes: 0, hours: 0)) {
      print('video Started');
    }

    if (_controller.value.position == _controller.value.duration) {
      setState(() {});
      print('video Ended');
    }
  }

  _addStory(String? caption) async {
    final userData = Provider.of<UserProvider>(context, listen: false);

    await userData.addSory(
      newStory: NewStory(
        mediaFile: widget.videoFile,
        content: '',
        type: StoryType.VIDEO,
        caption: caption,
        duration: _controller.value.duration.inMilliseconds,
      ),
      onProgress: (_) => setState(() => _uploadProgress = (_)),
      onSuccess: () => Navigator.of(context).popUntil((route) => route.isFirst),
      onError: (e) =>
          Toast(context, message: 'Error occured while uploading your story')
              .show(),
      onComplete: () => setState(() => _uploadProgress = 0.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Vx.black,
      body: ZStack([
        VxAnimatedBox(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Center(
                  child: IconBtn(
                    icon: Icons.close,
                  ),
                ),
        ).alignCenter.animDuration(500.milliseconds).make(),
        SafeArea(
          child: VStack(
            [
              HStack(
                [
                  CloseBtn(),
                  // IconBtn(
                  //   icon: Icons.crop_rotate,
                  //   color: Vx.white,
                  //   onPressed: _cropvideo,
                  // ),
                ],
                alignment: MainAxisAlignment.spaceBetween,
                axisSize: MainAxisSize.max,
              ),
              _controller.value.isBuffering
                  ? CircularProgressIndicator.adaptive()
                  : _uploadProgress > 0
                      ? CircularProgressIndicator(
                          value: _uploadProgress,
                          strokeWidth: 3,
                        )
                      : CircleButton(
                          icon: _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow_rounded,
                          color: Vx.gray200,
                          onPressed: () => setState(() {
                            _controller.value.isPlaying
                                ? _controller.pause()
                                : _controller.play();
                          }),
                          iconSize: 50,
                          bgColor: Colors.black38,
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
