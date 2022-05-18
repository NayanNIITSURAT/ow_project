import 'package:flutter/material.dart';
import 'package:owlet/Providers/HashTagProvider.dart';
import 'package:owlet/Providers/UtilsProvider.dart';
import 'package:owlet/Screens/HashTagScreen.dart';
import 'package:owlet/constants/constants.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:owlet/modals/ProfileViewModal.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

class ReadMore extends StatefulWidget {
  const ReadMore({
    required this.caption,
    this.username,
    this.showReadmore: true,
    this.maxLength: 90,
    this.style,
  });

  final int? maxLength;
  final String caption;
  final String? username;
  final bool showReadmore;
  final TextStyle? style;

  @override
  _ReadMoreState createState() => _ReadMoreState();
}

class _ReadMoreState extends State<ReadMore> {
  late bool isLongDesc;
  late int maxLength;

  @override
  void initState() {
    maxLength = widget.maxLength ?? 90;
    isLongDesc = widget.caption.characters.length > maxLength;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final hashTagData = Provider.of<HashTagProvider>(context);
    final caption = widget.caption;
    final username = widget.username;
    var handleHashTag = (text) => formatHashTags(
          text,
          (hashTag) async {
            Navigator.pushNamed(context, HashTagScreen.routeName);
            await hashTagData.setTagData(hashTag);
          },
          (atMention) async {
            ProfileViewModal.show(context);
            await Provider.of<UtilsProvider>(context, listen: false)
                .getCurrentProfileFromUsername(atMention);
          },
        );
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyText1,
        children: [
          if (username != null)
            TextSpan(
              text: "$username",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          TextSpan(
            children: [
              handleHashTag(caption.substring(
                      0,
                      isLongDesc && caption.characters.length > maxLength
                          ? maxLength
                          : caption.characters.length) +
                  (isLongDesc ? '...' : '')),
              isLongDesc && widget.showReadmore
                  ? WidgetSpan(
                      child: GestureDetector(
                        child: (isLongDesc ? 'more' : ' show less')
                            .text
                            .color(Colors.grey)
                            .italic
                            .bold
                            .size(Global.fontSize)
                            .lineHeight(1)
                            .make(),
                        onTap: () => setState(() {
                          maxLength = 5000;
                          isLongDesc = isLongDesc ? false : true;
                        }),
                      ),
                    )
                  : WidgetSpan(child: ''.text.lineHeight(1).make())
            ],
            style: widget.style,
          )
          // TextSpan(text: caption),
        ],
      ),
    );
  }
}
