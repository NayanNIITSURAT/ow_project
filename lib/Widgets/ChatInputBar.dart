import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:owlet/constants/constants.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:velocity_x/velocity_x.dart';

class ChatInputBar extends StatefulWidget {
  final Function(String) onSend;
  final String? hint;
  final bool setFocus;
  final TextEditingController? textController;
  final FocusNode? focusController;
  const ChatInputBar({
    Key? key,
    required this.onSend,
    this.hint: 'Enter comment...',
    this.setFocus: true,
    this.textController,
    this.focusController,
  }) : super(key: key);

  @override
  _ChatInputBarState createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  String message = '';
  TextEditingController _textController = TextEditingController();
  FocusNode _focusController = FocusNode();

  @override
  void initState() {
    // Future.delayed(Duration.zero, () => widget.hint != null? _textController.)
    super.initState();
    _textController = widget.textController ?? TextEditingController();
    _focusController = widget.focusController ?? FocusNode();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _textController.dispose();
    _focusController.dispose();
  }

  void submit() {
    widget.onSend(message);
    _textController..text = '';
    message = '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Vx.gray200,
      ),
      child: Row(
        children: [
          TextField(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: widget.hint,
              hintStyle: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
            controller: _textController,
            focusNode: _focusController,
            onChanged: (val) => message = val,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.send,
            enableSuggestions: true,
            onEditingComplete: submit,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 4,
            minLines: 1,
            autocorrect: true,
            autofocus: widget.setFocus,
            style: TextStyle(fontSize: Global.fontSize + 2),
          ).px8().expand(),
          HStack([
            SizedBox(
              child: Icon(
                CupertinoIcons.paperplane,
                color: Palette.primaryColor,
              ).rotate45(),
            ),
            15.widthBox
          ]).onInkTap(submit),
        ],
      ),
    ).p0();
  }
}
