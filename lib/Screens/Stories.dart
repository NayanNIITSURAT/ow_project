import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:owlet/Providers/User.dart';
import 'package:owlet/Screens/CameraScreen.dart';
import 'package:owlet/Widgets/StorySwipe.dart';
import 'package:owlet/Widgets/StoryView.dart';
import 'package:owlet/constants/palettes.dart';

class Stories extends StatelessWidget {
  static const routeName = 'stories';
  Stories({
    this.initialPage: 0,
    this.isUserStory: false,
  });
  final int initialPage;
  final bool isUserStory;

  @override
  Widget build(BuildContext context) {
    FocusNode _focusController = FocusNode();
    final userData = Provider.of<UserProvider>(context, listen: false);
    return Dismissible(
      direction: DismissDirection.down,
      key: const Key('key'),
      onDismissed: (_) => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: StorySwipe(
          initialPage: initialPage,
          itemBuilder: (_) {
            return (isUserStory ? [userData.profile] : userData.usersWithStory)
                .map((e) {
              return StoryView(
                user: e,
                onStoryItemView: (s) {
                  if (!isUserStory) userData.storyViewed = s.id;
                },
                onStoryComplete: _?.nextPage,
                prevPage: _?.prevPage,
                parentPageCtrl: _?.pageController,
                focusController: _focusController,
              );
            }).toList();
          },
        ),
        floatingActionButton: FloatingBtn(
          focusNode: _focusController,
        ),
      ),
    );
  }
}

class FloatingBtn extends StatefulWidget {
  const FloatingBtn({
    Key? key,
    required this.focusNode,
  }) : super(key: key);
  final FocusNode focusNode;

  @override
  State<FloatingBtn> createState() => _FloatingBtnState();
}

class _FloatingBtnState extends State<FloatingBtn> {
  FocusNode _focusController = FocusNode();
  @override
  void initState() {
    _focusController = (widget.focusNode);
    _focusController.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _focusController.hasFocus
        ? SizedBox()
        : FloatingActionButton(
            child: Icon(Icons.add),
            backgroundColor: Palette.primaryColor,
            onPressed: () =>
                Navigator.pushReplacementNamed(context, CameraScreen.routeName),
          );
  }
}
