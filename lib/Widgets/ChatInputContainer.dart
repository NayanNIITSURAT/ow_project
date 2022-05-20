import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:owlet/Components/IconBtn.dart';
import 'package:owlet/Screens/ChatScreen.dart';
import 'package:owlet/Widgets/Chatable.dart';
import 'package:owlet/enum.dart';
import 'package:owlet/modals/AttachmentModal.dart';
import 'package:velocity_x/velocity_x.dart';

import '../constants/images.dart';

class ChatInputContainer extends StatefulWidget {
  final FocusNode? focusNode;
  final Chatable? chatable;
  final Function()? onChatableClose;
  final Function(String msg) onSend;
  final Function(Chatable chatable)? onSelectChatable;
  const ChatInputContainer({
    Key? key,
    this.focusNode,
    this.chatable,
    this.onChatableClose,
    required this.onSend,
    this.onSelectChatable,
  }) : super(key: key);

  @override
  State<ChatInputContainer> createState() => _ChatInputContainerState();
}

class _ChatInputContainerState extends State<ChatInputContainer> {
  TextEditingController _controller = TextEditingController();
  bool _emojiShowing = false;

  @override
  void initState() {
    widget.focusNode?.addListener(() {
      if (widget.focusNode!.hasFocus && _emojiShowing) _emojiShowing = false;
      setState(() {});
    });
    super.initState();
  }

  _toggleEmoji() {
    if (!_emojiShowing) {
      widget.focusNode?.unfocus();
      Future.delayed(
          0.seconds,
          () => setState(() {
                _emojiShowing = !_emojiShowing;
              }));
    } else {
      setState(() {
        _emojiShowing = !_emojiShowing;
      });
      Future.delayed(0.microseconds, widget.focusNode?.requestFocus);
    }
  }

  _onEmojiSelected(Emoji emoji) {
    _controller
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length));
    setState(() {});
  }

  _onBackspacePressed() {
    _controller
      ..text = _controller.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            children: [
              if (widget.chatable != null &&
                  widget.chatable?.type == ChatableType.LISTING)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: widget.chatable?.build(context,
                        onChatableClose: widget.onChatableClose),
                  ),
                ),
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 52,
                    margin: EdgeInsets.only(
                      right: 15,
                    ),
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.3, color: Colors.grey),
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 5, 5, 5),
                      child: IconBtn(
                        isImage: true,
                        imagePath: attachment,
                        size: 25,
                        icon: Icons.attach_file,
                        onPressed: () => AttachmentModal.show(
                          context,
                          handleChatable: (Chatable chatable) {
                            print(chatable.user);
                            Navigator.popUntil(context,
                                ModalRoute.withName(ChatScreen.routeName));
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(width: 0.3, color: Colors.grey),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 15),
                                  hintText: "Your message",
                                  border: InputBorder.none,
                                ),
                                focusNode: widget.focusNode,
                                controller: _controller,
                              ),
                            ),
                          ),
                          InkWell(
                              onTap: () {
                                setState(() {
                                  widget.onSend(_controller.text);
                                  _controller..text = '';
                                });
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Image.asset(
                                  send,
                                  height: 25,
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
