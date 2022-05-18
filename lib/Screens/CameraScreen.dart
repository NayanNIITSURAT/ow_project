import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:owlet/Components/CircleButton.dart';
import 'package:owlet/Screens/TextStoryScreen.dart';
import 'package:owlet/Widgets/WithDismissible.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:owlet/Components/IconBtn.dart';
import 'package:owlet/Screens/PicturePreviewScreen.dart';
import 'package:owlet/Screens/VideoPreviewScreen.dart';
import 'package:owlet/Widgets/CloseBtn.dart';
import 'package:owlet/Widgets/CountDown.dart';
// import 'package:path_provider/path_provider.dart';

List<CameraDescription> cameras = [];

class CameraScreen extends StatefulWidget {
  static const routeName = 'camera-screen';
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late Future<void> cameraValue;
  bool isRecording = false;
  bool isFrontCamera = false;

  @override
  void initState() {
    super.initState();
    initCamera(isFrontCamera ? 1 : 0);
  }

  @override
  void dispose() {
    super.dispose();
    _cameraController.dispose();
  }

  void initCamera(int camera) async {
    _cameraController = new CameraController(
      cameras[camera],
      ResolutionPreset.medium,
    );
    cameraValue = _cameraController.initialize();
  }

  void takePicture(BuildContext ctx) async {
    print('Pics');
    final XFile picture = await _cameraController.takePicture();
    Navigator.push(
        ctx,
        MaterialPageRoute(
            builder: (builder) => PicturePreviewScreen(
                  pictureFile: picture,
                )));
  }

  void startRecording() async {
    isRecording = true;
    setState(() {});
    await _cameraController.startVideoRecording();
    // Future.delayed(
    //   5.seconds,
    //   () => isRecording ? stopRecording(context) : null,
    // );
  }

  void stopRecording(BuildContext ctx) async {
    final XFile video = await _cameraController.stopVideoRecording();
    isRecording = false;
    setState(() {});
    Navigator.push(
        ctx,
        MaterialPageRoute(
            builder: (builder) => VideoPreviewScreen(
                  videoFile: File(video.path),
                )));
  }

  @override
  Widget build(BuildContext context) {
    final _fm = _cameraController.value.flashMode;
    final size = MediaQuery.of(context).size;
    return WithDismissible(
      child: Scaffold(
          backgroundColor: Colors.black,
          body: FutureBuilder(
            future: cameraValue,
            builder: (_, __) {
              return ZStack(
                [
                  if (__.connectionState == ConnectionState.done)
                    CameraPreview(_cameraController)
                        .scale(
                            scaleValue: 1 /
                                (_cameraController.value.aspectRatio *
                                    size.aspectRatio))
                        .centered()
                  else
                    Center(),
                  SafeArea(
                    child: VStack(
                      [
                        HStack(
                          [
                            CloseBtn(),
                            if (isRecording)
                              CountDown(
                                from: 1,
                                to: 30,
                                onFinish: () => stopRecording(context),
                                builder: (_, __, ___) {
                                  return AvatarGlow(
                                    glowColor: Palette.primaryColor,
                                    startDelay: 24.seconds,
                                    endRadius: 30,
                                    duration: Duration(milliseconds: 1500),
                                    repeat: true,
                                    showTwoGlows: true,
                                    repeatPauseDuration:
                                        Duration(milliseconds: 100),
                                    child: ZStack([
                                      CircularProgressIndicator.adaptive(
                                        value: __ / 30,
                                        strokeWidth: 3,
                                        semanticsValue: __.toString(),
                                      ),
                                      Center(
                                          child: __
                                              .toInt()
                                              .toString()
                                              .text
                                              .bold
                                              .color(Vx.white)
                                              .make()),
                                    ])
                                        .h(30)
                                        .w(30)
                                        .box
                                        .roundedFull
                                        .color(Colors.black12)
                                        .make(),
                                  );
                                },
                              ),
                          ],
                          alignment: MainAxisAlignment.spaceBetween,
                          axisSize: MainAxisSize.max,
                          crossAlignment: CrossAxisAlignment.start,
                        ).expand(),
                        CircleButton(
                          iconSize: 22,
                          onPressed: () => Navigator.pushReplacementNamed(
                              context, TextStoryScreen.routeName),
                          icon: Icons.edit,
                        ).centered(),
                        HStack(
                          [
                            IconBtn(
                              color: Vx.white,
                              icon: _fm == FlashMode.auto
                                  ? Icons.flash_auto_rounded
                                  : _fm == FlashMode.always
                                      ? Icons.flash_on_rounded
                                      : Icons.flash_off,
                              onPressed: () => setState(() {
                                final _ = _fm == FlashMode.auto
                                    ? FlashMode.always
                                    : _fm == FlashMode.always
                                        ? FlashMode.off
                                        : FlashMode.auto;
                                _cameraController.setFlashMode(_);
                              }),
                            ),
                            Column(
                              children: [
                                GestureDetector(
                                  child: VxCircle(
                                    backgroundColor: isRecording
                                        ? Colors.red
                                        : Colors.transparent,
                                    radius: isRecording ? 110 : 80,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3.5,
                                    ),
                                  ),
                                  onLongPress: startRecording,
                                  onLongPressUp: () => stopRecording(context),
                                  onTapUp: (_) =>
                                      isRecording ? null : takePicture(context),
                                ),
                              ],
                            ),
                            IconBtn(
                              color: Vx.white,
                              icon: Icons.cameraswitch_outlined,
                              onPressed: () => setState(() {
                                isFrontCamera = !isFrontCamera;
                                initCamera(isFrontCamera ? 1 : 0);
                              }),
                            ),
                          ],
                          alignment: MainAxisAlignment.spaceBetween,
                          axisSize: MainAxisSize.max,
                          crossAlignment: CrossAxisAlignment.end,
                        ),
                        30.heightBox,
                      ],
                      axisSize: MainAxisSize.max,
                      alignment: MainAxisAlignment.spaceBetween,
                    ).p16(),
                  ),
                ],
              );
            },
          )),
    );
  }
}

// class RecordingIndicator extends StatefulWidget {
//   const RecordingIndicator({
//     Key? key,
//     this.onFinish,
//   }) : super(key: key);
//   final Function()? onFinish;

//   @override
//   _RecordingIndicatorState createState() => _RecordingIndicatorState();
// }

// class _RecordingIndicatorState extends State<RecordingIndicator> {
//   double counterValue = 0;
//   @override
//   Widget build(BuildContext context) {
//     return ;
//   }
// }
