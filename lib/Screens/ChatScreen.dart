import 'dart:convert';

import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:owlet/Components/ProfileAvatar.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Providers/UtilsProvider.dart';
import 'package:owlet/Screens/Login.dart';
import 'package:owlet/Screens/NavScreen.dart';
import 'package:owlet/Widgets/ChatInputContainer.dart';
import 'package:owlet/Widgets/Chatable.dart';
import 'package:owlet/enum.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:owlet/main.dart';
import 'package:owlet/modals/ProfileViewModal.dart';
import 'package:owlet/models/Message.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../constants/images.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = 'chat-messages';

  final Chatable? Function()? onPageEnter;
  final Function()? onPageLeave;
  const ChatScreen({
    Key? key,
    this.onPageEnter,
    this.onPageLeave,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with RouteAware {
  final ScrollController _scrollController = ScrollController();
  FocusNode _focusController = FocusNode();

  Chatable? _chatable;

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(
      0.seconds,
    );

    Future.delayed(0.seconds, _init);
  }

  @override
  void dispose() {
    super.dispose();
    routeObserver.unsubscribe(this);
  }

  // Called when the current route has been popped off.
  // @override
  // void didPop() {
  //   debugPrint("didPop $runtimeType");
  //   (widget.onPageLeave ?? () {})();
  //   super.didPop();
  // }

  @override
  void didPush() {
    _chatable = (widget.onPageEnter ?? () => null)();
    setState(() {});
    // debugPrint(_chatable?.listing?.caption);
    super.didPush();
  }

  void _init() {
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    if (mounted) {
      final userData = Provider.of<UserProvider>(context, listen: false);
      if (!userData.isLoggedIn) {
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
        return;
      }
      final chat = userData.curChatUser;
      receiveMsg();
      socket.on('sendMsg', (_) => receiveMsg());
      socket.emitWithAck('chat-open', chat!.id, ack: chatEstablished);
      _focusController.addListener(() {
        Future.delayed(100.milliseconds, _scrollToButtom);
      });
      _focusController.requestFocus();

      if (_scrollController.hasClients)
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void chatEstablished(Map<String, dynamic> user) {
    final userData = Provider.of<UserProvider>(context, listen: false);
    userData.curChatLastSeen = user['lastSeen'];
    // print('ress  $user');
  }

  void _scrollToButtom() {
    Future.delayed(500.milliseconds, () {
      if (_scrollController.hasClients)
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
    });
  }

  receiveMsg() async {
    if (mounted) {
      final userData = Provider.of<UserProvider>(context, listen: false);
      final chat = userData.curChatUser;
      _scrollToButtom();
      socket.emit('seen', chat!.id);
      userData.updateChatState(chat.id, ChatState.SEEN);
    }
  }

  void sendMsg(String msg) async {
    if (msg.length < 1) return;
    print('--------------df-----------------');
    final userData = Provider.of<UserProvider>(context, listen: false);
    final chat = userData.curChatUser;
    Message newMsg = Message(
      content: msg,
      id: -1,
    );

    if (_chatable != null)
      newMsg = newMsg.copyWith(
        story: _chatable?.story,
        listing: _chatable?.listing,
      );

    final _newMsg = await userData.sendMsg(newMsg);
    if (_newMsg != null) {
      final msgData = {
        'message': msg,
        "receiverId": chat!.id,
        "senderId": userData.profile.id,
        'username': userData.profile.username,
        'avartar': userData.profile.avartar,
        'time': DateTime.now().toIso8601String(),
        "id": _newMsg.id,
      };

      if (_chatable != null) if (_chatable?.type == ChatableType.LISTING) {
        msgData['chatable'] = jsonEncode(_chatable?.listing?.toMap());
        msgData['refType'] = 'listing';
      } else {
        msgData['chatable'] = jsonEncode(_chatable?.story?.toMap());
        msgData['refType'] = 'story';
      }

      socket.emitWithAck(
        'sendMsg',
        msgData,
        ack: (status) => status == 'delivered'
            ? userData.msgDelivered = _newMsg
            : userData.msgSent = _newMsg,
      );

      _scrollToButtom();

      _chatable = null;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserProvider>(context);
    final chat = userData.curChatUser;

    return RawKeyboardListener(
      focusNode: FocusNode(),
      // onKey: (val) => print(val),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.only(left: 0),
                          alignment: Alignment.centerLeft,
                          icon: SvgPicture.asset(
                            back,
                            height: 25,
                          ),
                          onPressed: context.pop,
                        ),
                        ProfileAvatar(
                          avatar: chat?.avartar,
                          size: 50,
                          isOnline: chat!.isOnline,
                          onPressed: () async {
                            ProfileViewModal.show(context);
                            await Provider.of<UtilsProvider>(context,
                                    listen: false)
                                .getCurrentSellerProfile(chat.getUser);
                          },
                        ),
                        10.widthBox,
                        VStack(
                          [
                            chat.username.text.semiBold.size(18).make(),
                            chat.isOnline
                            ? 'online'.text.make()
                                :Text(
                              'Active ${timeAgo(chat.lastSeen.toLocal().toString())}',
                            )
                          ],
                          crossAlignment: CrossAxisAlignment.center,
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: SizedBox(
                        width: screenSize(context).width, child: Divider()),
                  ),
                ],
              ),
            ),
            10.heightBox,
            VxBox(
              child: Column(
                children: [
                  20.heightBox,
                  ListView.builder(
                    controller: _scrollController,
                    itemCount: chat.messages.length + 1,
                    itemBuilder: (_, i) {
                      final msgs = chat.messages;
                      int msgsLen = msgs.length;
                      final iSent = i != msgsLen &&
                          userData.profile.id == msgs[i].senderId;

                      bool showNip = false;

                      if (i == msgsLen - 1) {
                        showNip = true;
                      } else if (i <= msgsLen - 2 &&
                          msgs[i + 1].senderId != msgs[i].senderId)
                        showNip = true;

                      return i == msgsLen
                          ? 10.heightBox
                          : ChatItem(
                              message: msgs[i],
                              userData: userData,
                              iSent: iSent,
                              showNip: showNip,
                            );
                    },
                  ).expand(),
                  Align(
                    child: ChatInputContainer(
                      onChatableClose: () => setState(() => _chatable = null),
                      onSend: sendMsg,
                      focusNode: _focusController,
                      chatable: _chatable,
                    ),
                    alignment: Alignment.bottomCenter,
                  )
                ],
              ),
            ).topRounded(value: 30).color(Vx.white).make().expand(),
          ],
        ),
      ),
    );
  }
}

class ChatItem extends StatelessWidget {
  const ChatItem({
    Key? key,
    required this.message,
    required this.userData,
    required this.iSent,
    this.showNip: false,
  }) : super(key: key);

  final Message message;
  final UserProvider userData;
  final bool iSent;
  final bool showNip;

  @override
  Widget build(BuildContext context) {
    return VStack([
      Container(
        padding: EdgeInsets.symmetric(horizontal: 7),
        alignment: iSent ? Alignment.bottomRight : Alignment.bottomLeft,
        child: (message.hasListing)
            ? Chatable(type: ChatableType.LISTING, listing: message.listing)
                .build(context)
            : (message.hasStory)
                ? Chatable(type: ChatableType.STORY, story: message.story)
                    .build(context)
                : null,
      ),
      Bubble(
        child: Text(
          message.content,
          softWrap: true,
        ).box.p4.make(),
        color: iSent ? Colors.blue.shade50 : Colors.grey.shade200,

        alignment: iSent ? Alignment.bottomRight : Alignment.bottomLeft,
        margin: BubbleEdges.only(
            bottom: showNip ? 10 : 4,
            // left: !showNip && !iSent ? 7 : null,
            // right: !showNip && iSent ? 7 : null,
            left: 7,
            right: 7),

        padding: BubbleEdges.symmetric(
          vertical: 4,
          horizontal: 4,
        ),
        // nip: showNip
        //     ? iSent
        //         ? BubbleNip.rightBottom
        //         : BubbleNip.leftBottom
        //     : null,

        shadowColor: Colors.black26,
        elevation: 5,
        radius: Radius.circular(10),
        stick: true,
      )
    ])
        .box
        .withConstraints(BoxConstraints(
            maxWidth: context.screenWidth * 0.8,
            minWidth: context.screenSize.width * 0.2))
        .make();
  }
}
