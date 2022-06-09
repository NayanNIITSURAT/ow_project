import 'dart:async';
import 'dart:convert';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:owlet/Screens/ChatScreen.dart';
import 'package:owlet/Screens/Login.dart';
import 'package:owlet/Widgets/ChatInputContainer.dart';
import 'package:owlet/main.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:owlet/Components/IconBtn.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Providers/UtilsProvider.dart';
import 'package:owlet/Screens/NavScreen.dart';
import 'package:owlet/Widgets/ChatInputBar.dart';
import 'package:owlet/Widgets/StoryMedia.dart';
import 'package:owlet/constants/images.dart';
import 'package:owlet/enum.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:owlet/modals/ProfileViewModal.dart';
import 'package:owlet/models/Message.dart';
import 'package:owlet/models/Story.dart';
import 'package:owlet/models/User.dart';

import '../constants/constants.dart';

class StoryView extends StatefulWidget {
  final User user;
  final Function(Story)? onStoryItemView;
  final Function()? onStoryComplete;
  final Function()? prevPage;
  final PageController? parentPageCtrl;
  final FocusNode? focusController;
  const StoryView({
    Key? key,
    required this.user,
    this.onStoryItemView,
    this.onStoryComplete,
    this.prevPage,
    this.parentPageCtrl,
    this.focusController,
  }) : super(key: key);

  @override
  _StoryViewState createState() => _StoryViewState();
}

class _StoryViewState extends State<StoryView>
    with SingleTickerProviderStateMixin {
  PageController _pageController = PageController();
  StoryController controller = StoryController();
  AnimationController? _animController;
  FocusNode _focusController = FocusNode();
  PanelController _panelController = PanelController();
  int _currentIndex = 0;

  StreamSubscription<PlaybackState>? _playbackSubscription;

  @override
  void initState() {
    Global.currentstoryindex=_currentIndex;
    _focusController = widget.focusController ?? FocusNode();
    _focusController.addListener(() {
      if (!_focusController.hasFocus) {
        _panelController.close();
        controller.play();
      } else {
        controller.pause();
      }
    });
    widget.parentPageCtrl?.addListener(() {
      mountedComplete ? controller.play() : controller.pause();
    });
    _start();
    super.initState();
  }

  bool get mountedComplete =>
      ((widget.parentPageCtrl?.page ?? 0) -
          (widget.parentPageCtrl?.page ?? 0).floor()) ==
      0;

  void _start() {
    _animController = AnimationController(vsync: this);

    final Story firstStory = widget.user.stories
        .firstWhere((_) => !_.iViewed, orElse: () => widget.user.stories.first);
    if (mounted) _loadStory(story: firstStory, animateToPage: false);

    _currentIndex = widget.user.stories.indexOf(firstStory);

    _animController?.addStatusListener((status) {
      if (status == AnimationStatus.completed) _nextPage();
    });

    this._playbackSubscription =
        controller.playbackNotifier.listen((playbackStatus) {
      switch (playbackStatus) {
        case PlaybackState.play:
          _play();
          break;
        case PlaybackState.pause:
          _pause();
          break;
        case PlaybackState.next:
          _nextPage();
          break;
        case PlaybackState.previous:
          _prevPage();
          break;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController?.dispose();
    _playbackSubscription?.cancel();
    super.dispose();
  }

  void _nextPage() {
    (widget.onStoryItemView ?? () {})(widget.user.stories[_currentIndex]);
    _animController?.stop();
    if (_currentIndex + 1 < widget.user.stories.length) {
      _currentIndex += 1;
      Global.currentstoryindex=_currentIndex;
      _loadStory(story: widget.user.stories[_currentIndex]);
    } else
      (widget.onStoryComplete ?? () => Navigator.pop(context))();
    setState(() {});
  }

  void _prevPage() {
    if (_currentIndex - 1 > -1) {
      _currentIndex -= 1;
      _loadStory(story: widget.user.stories[_currentIndex]);
    } else {
      controller.play();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Story story = widget.user.stories[_currentIndex];
    final userData = Provider.of<UserProvider>(context, listen: false);

    void sendMsg(msg) async {
      if (msg.length < 1) return;
      userData.curChatUser = widget.user.chat;
      Message newMsg = Message(
        content: msg,
        id: -1,
        story: story.copyWith(user: widget.user),
      );
      final _msg = await userData.sendMsg(newMsg);
      final msgData = {
        'message': msg,
        "receiverId": widget.user.id,
        "senderId": userData.profile.id,
        'username': userData.profile.username,
        'avartar': userData.profile.avartar,
        'time': DateTime.now().toIso8601String(),
        "id": _msg?.id,
        "refType": 'story',
        "chatable": jsonEncode(newMsg.story?.toMap()),
      };
      socket.emitWithAck('sendMsg', msgData, ack: (status) {
        print(status);
      });
      _panelController.close();
      _focusController.unfocus();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SlidingUpPanel(
        boxShadow: null,
        controller: _panelController,
        backdropTapClosesPanel: true,
        onPanelClosed: () => _focusController.unfocus(),
        onPanelOpened: () {
          userData.isLoggedIn
              ? _focusController.requestFocus()
              : Navigator.pushNamed(context, LoginScreen.routeName);
        },
        backdropEnabled: true,
        // color: Palette.primaryColorLight,
        color: Colors.transparent,
        maxHeight: 300,
        minHeight: 80,
        margin: EdgeInsets.only(top: 80),
        collapsed: userData.profile.id == widget.user.id
            ? Offstage()
            : Column(children: [
                10.heightBox,
                AnimatedButton(),
              ]),
        panel: userData.profile.id == widget.user.id
            ? Offstage()
            : Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  VxBox(
                    child: Column(
                      children: [
                        // ChatInputContainer(
                        //   onSend: sendMsg,
                        //   focusNode: _focusController,
                        //   chatable: Chatable(
                        //       chatableId: story.id, type: ChatableType.STORY),
                        // )
                        ChatInputBar(
                          onSend: sendMsg,
                          hint: 'Type message',
                          setFocus: false,
                          focusController: _focusController,
                        ),
                      ],
                    ),
                  ).p8.alignCenter.color(Vx.white).make(),
                ],
                mainAxisSize: MainAxisSize.min,
              ),
        body: GestureDetector(
          onTapUp: (details) => _onTapUp(details, story),
          onLongPressDown: (details) => controller.pause(),
          onLongPressUp: controller.play,
          child: Stack(
            children: <Widget>[
              PageView.builder(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.user.stories.length,
                itemBuilder: (context, i) {
                  final Story story = widget.user.stories[i];
                  switch (story.type) {
                    case StoryType.IMAGE:
                      return StoryItem.pageImage(
                          url: cloudinary.getImage(story.content).url,
                          controller: controller,
                          caption: story.caption);
                    case StoryType.VIDEO:
                      return StoryItem.pageVideo(
                          'https://res.cloudinary.com/cybertech-digitals-ltd/video/upload/q_auto/v1641722959/${story.content}.mp4',
                          controller: controller,
                          caption: story.caption);
                    default:
                      {
                        final bgColor = fromHex(story.caption ?? 'FF000000');
                        double contrast = ContrastHelper.contrast([
                          bgColor.red,
                          bgColor.green,
                          bgColor.blue,
                        ], [
                          255,
                          255,
                          255
                        ]);
                        return Container(
                          decoration: BoxDecoration(
                            color: bgColor,
                            // borderRadius: BorderRadius.vertical(
                            //   top: Radius.circular(roundedTop ? 8 : 0),
                            //   bottom: Radius.circular(roundedBottom ? 8 : 0),
                            // ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: Center(
                            child: Text(
                              story.content,
                              style: TextStyle(
                                color: contrast > 1.8
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          //color: backgroundColor,
                        );
                      }
                  }
                },
              ),
              VxBox(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: widget.user.stories
                          .asMap()
                          .map((i, e) {
                            return MapEntry(
                              i,
                              AnimatedBar(
                                animController: _animController!,
                                position: i,
                                currentIndex: _currentIndex,
                              ),
                            );
                          })
                          .values
                          .toList(),
                    ),
                    StoryUser(
                      user: widget.user,
                      story: story,
                      controller: controller,
                    ),
                  ],
                ),
              )
                  .padding(EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 10,
                  ))
                  .make(),
            ],
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }

  void _onTapUp(TapUpDetails details, Story story) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;
    if (dx < screenWidth / 3)
      _prevPage();
    else
      _nextPage();
  }

  void _pause() {
    if (_animController!.isAnimating) {
      _animController?.stop();
    }
  }

  void _play() {
    if (!_animController!.isAnimating && !_focusController.hasFocus) {
      _animController?.forward();
    }
  }

  void _loadStory({required Story story, bool animateToPage = true}) {
    _animController?.stop();
    _animController?.reset();
    switch (story.type) {
      case StoryType.IMAGE:
        _animController?.duration = story.duration;
        controller.play();
        break;
      case StoryType.VIDEO:
        _animController?.duration = story.duration;
        break;
      default:
        _animController?.duration = story.duration;
        controller.play();
    }
    if (animateToPage) {
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }
}

class AnimatedBar extends StatelessWidget {
  final AnimationController animController;
  final int position;
  final int currentIndex;

  const AnimatedBar({
    required this.animController,
    required this.position,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: <Widget>[
                _buildContainer(
                  double.infinity,
                  position < currentIndex
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                ),
                position == currentIndex
                    ? AnimatedBuilder(
                        animation: animController,
                        builder: (context, child) {
                          return _buildContainer(
                            constraints.maxWidth * animController.value,
                            Colors.white,
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              ],
            );
          },
        ),
      ),
    );
  }

  Container _buildContainer(double width, Color color) {
    return Container(
      height: 3.5,
      width: width,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: Colors.black26,
          width: 0.8,
        ),
        borderRadius: BorderRadius.circular(3.0),
      ),
    );
  }
}

class AnimatedButton extends StatefulWidget {
  const AnimatedButton({Key? key}) : super(key: key);

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: 500.milliseconds,
    vsync: this,
  );

  late Animation<Offset> _offsetAnimation = setOffset(-0.4);
  @override
  void initState() {
    super.initState();
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<Offset> setOffset(double end, {double? begin}) => Tween<Offset>(
        begin: Offset(0.0, begin ?? 0),
        end: Offset(0.0, end),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ));
  // void repeatOnce() async {
  //   await _controller.forward();
  //   await _controller.reverse();
  // }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: ZStack(
        [
          Icon(
            CupertinoIcons.chevron_up,
            color: Vx.white,
          ),
          Positioned(
            top: 10,
            child: Icon(
              CupertinoIcons.chevron_up,
              color: Vx.white,
            ),
          ),
          Positioned(
            top: 30,
            child: 'Reply'.text.color(Vx.white).semiBold.make(),
          ),
        ],
        alignment: Alignment.center,
      ).box.alignBottomCenter.make(),
    );
  }
}

class StoryUser extends StatelessWidget {
  const StoryUser({
    Key? key,
    required this.user,
    required this.story,
    required this.controller,
  }) : super(key: key);

  final User user;
  final Story? story;
  final StoryController controller;

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserProvider>(context, listen: false);
    final utilProvider = Provider.of<UtilsProvider>(context, listen: false);
    return ListTile(
      onTap: () async {
        await utilProvider.getCurrentSellerProfile(user);
        ProfileViewModal().showWithCallback(
          context,
          onPageEnter: () => controller.pause(),
          onPageLeave: () => controller.play(),
        );
      },
      leading: CircleAvatar(
        backgroundColor: Colors.white30,
        backgroundImage: AssetImage(loadingGif),
        foregroundImage: NetworkImage(user.avartar),
        radius: 25,
      ),
      title: user.username.text.semiBold.size(13).color(Vx.white).make(),
      subtitle: timeAgo(story?.createdAt ?? DateTime.now().toString())
          .text
          .color(Vx.white)
          .size(10)
          .make(),
      trailing: userData.profile.id == user.id
          ? null
          : IconBtn(
              paddingLeft: 15,
              icon: Icons.more_vert,
              color: Vx.white,
              // onPressed: () => showCupertinoModalBottomSheet(
              //   context: context,
              //   builder: (context) => Container(
              //     child: ListingMenuModal(listing: product),
              //   ),
              //   duration: Duration(milliseconds: 400),
              //   expand: false,
              //   barrierColor: Colors.black.withOpacity(0.4),
              // ),
            ),
      contentPadding: EdgeInsets.symmetric(horizontal: 0),
    );
  }
}
