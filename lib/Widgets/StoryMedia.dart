import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:owlet/enum.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:video_player/video_player.dart';

/// Utitlity to load image (gif, png, jpg, etc) media just once. Resource is
/// cached to disk with default configurations of [DefaultCacheManager].
class ImageLoader {
  ui.Codec? frames;

  String url;

  Map<String, dynamic>? requestHeaders;

  LoadState state = LoadState.loading; // by default

  ImageLoader(this.url, {this.requestHeaders});

  /// Load image from disk cache first, if not found then load from network.
  /// `onComplete` is called when [imageBytes] become available.
  void loadImage(VoidCallback onComplete) {
    if (this.frames != null) {
      this.state = LoadState.success;
      onComplete();
    }

    final fileStream = DefaultCacheManager().getFileStream(this.url,
        headers: this.requestHeaders as Map<String, String>?);

    fileStream.listen(
      (fileResponse) {
        if (!(fileResponse is FileInfo)) return;
        // the reason for this is that, when the cache manager fetches
        // the image again from network, the provided `onComplete` should
        // not be called again
        if (this.frames != null) {
          return;
        }

        final imageBytes = fileResponse.file.readAsBytesSync();

        this.state = LoadState.success;

        PaintingBinding.instance!.instantiateImageCodec(imageBytes).then(
            (codec) {
          this.frames = codec;
          onComplete();
        }, onError: (error) {
          this.state = LoadState.failure;
          onComplete();
        });
      },
      onError: (error) {
        this.state = LoadState.failure;
        onComplete();
      },
    );
  }
}

/// Widget to display animated gifs or still images. Shows a loader while image
/// is being loaded. Listens to playback states from [controller] to pause and
/// forward animated media.
class StoryImage extends StatefulWidget {
  final ImageLoader imageLoader;

  final BoxFit? fit;

  final StoryController? controller;

  StoryImage(
    this.imageLoader, {
    Key? key,
    this.controller,
    this.fit,
  }) : super(key: key ?? UniqueKey());

  /// Use this shorthand to fetch images/gifs from the provided [url]
  factory StoryImage.url(
    String url, {
    StoryController? controller,
    Map<String, dynamic>? requestHeaders,
    BoxFit fit = BoxFit.contain,
    Key? key,
  }) {
    return StoryImage(
        ImageLoader(
          url,
          requestHeaders: requestHeaders,
        ),
        controller: controller,
        fit: fit,
        key: key);
  }

  @override
  State<StatefulWidget> createState() => StoryImageState();
}

class StoryImageState extends State<StoryImage> {
  ui.Image? currentFrame;

  Timer? _timer;

  StreamSubscription<PlaybackState>? _streamSubscription;

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      this._streamSubscription =
          widget.controller!.playbackNotifier.listen((playbackState) {
        // for the case of gifs we need to pause/play
        if (widget.imageLoader.frames == null) {
          return;
        }

        if (playbackState == PlaybackState.pause) {
          this._timer?.cancel();
        } else {
          forward();
        }
      });
    }

    widget.imageLoader.loadImage(() async {
      if (mounted) {
        if (widget.imageLoader.state == LoadState.success) {
          widget.controller?.play();
          forward();
        } else {
          // refresh to show error
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();

    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void forward() async {
    this._timer?.cancel();

    if (widget.controller != null &&
        widget.controller!.playbackNotifier.stream.value ==
            PlaybackState.pause) {
      return;
    }

    final nextFrame = await widget.imageLoader.frames!.getNextFrame();

    this.currentFrame = nextFrame.image;

    if (nextFrame.duration > Duration(milliseconds: 0)) {
      this._timer = Timer(nextFrame.duration, forward);
    }

    setState(() {});
  }

  Widget getContentView() {
    switch (widget.imageLoader.state) {
      case LoadState.success:
        return RawImage(
          image: this.currentFrame,
          fit: widget.fit,
        );
      case LoadState.failure:
        return Center(
            child: Text(
          "Image failed to load.",
          style: TextStyle(
            color: Colors.white,
          ),
        ));
      default:
        return Center(
          child: Container(
            width: 70,
            height: 70,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: getContentView(),
    );
  }
}

/// This is a representation of a story item (or page).
class StoryItem {
  /// Specifies how long the page should be displayed. It should be a reasonable
  /// amount of time greater than 0 milliseconds.
  final Duration duration;

  /// Has this page been shown already? This is used to indicate that the page
  /// has been displayed. If some pages are supposed to be skipped in a story,
  /// mark them as shown `shown = true`.
  ///
  /// However, during initialization of the story view, all pages after the
  /// last unshown page will have their `shown` attribute altered to false. This
  /// is because the next item to be displayed is taken by the last unshown
  /// story item.
  bool shown;

  /// The page content
  final Widget view;
  StoryItem(
    this.view, {
    required this.duration,
    this.shown = false,
  });

  /// Short hand to create text-only page.
  ///
  /// [title] is the text to be displayed on [backgroundColor]. The text color
  /// alternates between [Colors.black] and [Colors.white] depending on the
  /// calculated contrast. This is to ensure readability of text.
  ///
  /// Works for inline and full-page stories. See [StoryView.inline] for more on
  /// what inline/full-page means.
  static StoryItem text({
    required String title,
    required Color backgroundColor,
    Key? key,
    TextStyle? textStyle,
    bool shown = false,
    bool roundedTop = false,
    bool roundedBottom = false,
    Duration? duration,
  }) {
    double contrast = ContrastHelper.contrast([
      backgroundColor.red,
      backgroundColor.green,
      backgroundColor.blue,
    ], [
      255,
      255,
      255
    ] /** white text */);

    return StoryItem(
      Container(
        key: key,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(roundedTop ? 8 : 0),
            bottom: Radius.circular(roundedBottom ? 8 : 0),
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        child: Center(
          child: Text(
            title,
            style: textStyle?.copyWith(
                  color: contrast > 1.8 ? Colors.white : Colors.black,
                ) ??
                TextStyle(
                  color: contrast > 1.8 ? Colors.white : Colors.black,
                  fontSize: 18,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        //color: backgroundColor,
      ),
      shown: shown,
      duration: duration ?? Duration(seconds: 3),
    );
  }

  /// Factory constructor for page images. [controller] should be same instance as
  /// one passed to the `StoryView`
  static pageImage({
    required String url,
    required StoryController controller,
    Key? key,
    BoxFit imageFit = BoxFit.fitWidth,
    String? caption,
    Map<String, dynamic>? requestHeaders,
  }) {
    return Container(
      key: key,
      color: Colors.black,
      child: Stack(
        children: <Widget>[
          StoryImage.url(
            url,
            controller: controller,
            fit: imageFit,
            requestHeaders: requestHeaders,
          ),
          StoryCaption(caption ?? '')
        ],
      ),
    );
  }

  /// Shorthand for creating page video. [controller] should be same instance as
  /// one passed to the `StoryView`
  static Widget pageVideo(
    String url, {
    required StoryController controller,
    Key? key,
    Duration? duration,
    BoxFit imageFit = BoxFit.fitWidth,
    String? caption,
    bool shown = false,
    Map<String, dynamic>? requestHeaders,
  }) {
    return Container(
      key: key,
      color: Colors.black,
      child: Stack(
        children: <Widget>[
          StoryVideo.url(
            url,
            controller: controller,
            requestHeaders: requestHeaders,
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 24),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                color: caption != null ? Colors.black54 : Colors.transparent,
                child: caption != null
                    ? Text(
                        caption,
                        style: TextStyle(fontSize: 15, color: Colors.white),
                        textAlign: TextAlign.center,
                      )
                    : SizedBox(),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class StoryCaption extends StatelessWidget {
  const StoryCaption(this.caption);

  final String caption;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(
            bottom: 24,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 8,
          ),
          child: Text(
            caption,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class VideoLoader {
  String url;

  File? videoFile;

  Map<String, dynamic>? requestHeaders;

  LoadState state = LoadState.loading;

  VideoLoader(this.url, {this.requestHeaders});

  void loadVideo(VoidCallback onComplete) {
    if (this.videoFile != null) {
      this.state = LoadState.success;
      onComplete();
    }

    final fileStream = DefaultCacheManager().getFileStream(this.url,
        headers: this.requestHeaders as Map<String, String>?);

    fileStream.listen((fileResponse) {
      if (fileResponse is FileInfo) {
        if (this.videoFile == null) {
          this.state = LoadState.success;
          this.videoFile = fileResponse.file;
          onComplete();
        }
      }
    });
  }
}

class StoryVideo extends StatefulWidget {
  final StoryController? storyController;
  final VideoLoader videoLoader;

  StoryVideo(this.videoLoader, {this.storyController, Key? key})
      : super(key: key ?? UniqueKey());

  static StoryVideo url(String url,
      {StoryController? controller,
      Map<String, dynamic>? requestHeaders,
      Key? key}) {
    return StoryVideo(
      VideoLoader(url, requestHeaders: requestHeaders),
      storyController: controller,
      key: key,
    );
  }

  @override
  State<StatefulWidget> createState() {
    return StoryVideoState();
  }
}

class StoryVideoState extends State<StoryVideo> {
  Future<void>? playerLoader;

  StreamSubscription? _streamSubscription;

  VideoPlayerController? playerController;

  @override
  void initState() {
    super.initState();

    widget.storyController!.pause();

    widget.videoLoader.loadVideo(() {
      if (widget.videoLoader.state == LoadState.success) {
        this.playerController =
            VideoPlayerController.file(widget.videoLoader.videoFile!);

        if (mounted)
          playerController!.initialize().then((v) {
            setState(() {});
            widget.storyController!.play();
          });

        if (widget.storyController != null) {
          _streamSubscription =
              widget.storyController!.playbackNotifier.listen((playbackState) {
            if (playbackState == PlaybackState.pause) {
              playerController!.pause();
            } else {
              playerController!.play();
            }
          });
        }
      } else {
        setState(() {});
      }
    });
  }

  Widget getContentView() {
    if (widget.videoLoader.state == LoadState.success &&
        playerController!.value.isInitialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: playerController!.value.aspectRatio,
          child: VideoPlayer(playerController!),
        ),
      );
    }

    return widget.videoLoader.state == LoadState.loading
        ? Center(
            child: Container(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          )
        : Center(
            child: Text(
            "Media failed to load.",
            style: TextStyle(
              color: Colors.white,
            ),
          ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: double.infinity,
      width: double.infinity,
      child: getContentView(),
    );
  }

  @override
  void dispose() {
    playerController?.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }
}
