import 'package:flutter/material.dart';
import 'package:owlet/Screens/AddMarketSquare.dart';
import 'package:provider/provider.dart';

import 'package:owlet/Providers/User.dart';
import 'package:owlet/Screens/CameraScreen.dart';
import 'package:owlet/Widgets/StorySwipe.dart';
import 'package:owlet/Widgets/StoryView.dart';
import 'package:owlet/constants/palettes.dart';

import '../Components/Toast.dart';
import '../constants/constants.dart';

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
        floatingActionButton:
        FloatingBtn(focusNode: _focusController, isUserStory: isUserStory),
      ),
    );
  }
}

class FloatingBtn extends StatefulWidget {
  const FloatingBtn({
    Key? key,
    required this.focusNode,
    required this.isUserStory,
  }) : super(key: key);
  final FocusNode focusNode;
  final bool isUserStory;

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
    final userData = Provider.of<UserProvider>(context, listen: false);
    return _focusController.hasFocus
        ? SizedBox()
        : Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        widget.isUserStory
            ? FloatingActionButton(
            child: Icon(Icons.delete),
            backgroundColor: Colors.red,
            onPressed: () {
              userData.deletestory(userData.profile.stories[Global.currentstoryindex].id);
              Navigator.pop(context);
              Toast(
                context,
                message: 'Story Deleted Successfully',
                type: ToastType.SUCCESS,
              ).showTop();
              setState(() {
              });
              
            }
          //Navigator.pushReplacementNamed(context, CameraScreen.routeName),
        )
            : SizedBox.shrink(),
        SizedBox(
          width: 10,
        ),
        FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Colors.red,
          onPressed: () => Navigator.pushReplacementNamed(
              context, AddMarketSquareScreen.routeName),
          //Navigator.pushReplacementNamed(context, CameraScreen.routeName),
        ),
      ],
    );
  }
}