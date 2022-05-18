import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:owlet/enum.dart';
import 'package:owlet/helpers/helpers.dart';

class Swiper {
  final Function()? nextPage;
  final Function()? prevPage;
  final PageController? pageController;
  Swiper({
    this.nextPage,
    this.prevPage,
    this.pageController,
  });
}

class StorySwipe extends StatefulWidget {
  StorySwipe({
    Key? key,
    this.initialPage = 0,
    required this.itemBuilder,
    this.swipeController,
    this.allowSwipe = true,
    this.is3DTransform = true,
  }) : super(key: key);

  final int initialPage;
  final List<Widget> Function(Swiper? swipeController) itemBuilder;
  final SwipeController? swipeController;
  final bool allowSwipe;
  final bool is3DTransform;

  int get totalPages => itemBuilder(null).length;

  @override
  _StorySwipeState createState() => _StorySwipeState();
}

class _StorySwipeState extends State<StorySwipe> {
  PageController? _pageController;
  StreamSubscription<SwipeAction>? _swipeActionSubscription;
  double currentPageValue = 0.0;

  @override
  void initState() {
    super.initState();
    currentPageValue = widget.initialPage.toDouble();

    _swipeActionSubscription = widget.swipeController?.addListener(
        (action) => (action == SwipeAction.next) ? nextPage() : prevPage());

    _pageController = PageController(initialPage: currentPageValue.toInt());
    _pageController?.addListener(() {
      setState(() {
        currentPageValue = _pageController?.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController?.dispose();
    _swipeActionSubscription?.cancel();
  }

  nextPage() {
    if (currentPageValue < widget.totalPages - 1) {
      _pageController
          ?.nextPage(
              duration: (widget.is3DTransform ? 400 : 300).milliseconds,
              curve: Curves.easeIn)
          .then((value) =>
              setState(() => currentPageValue = _pageController?.page ?? 0));
    } else if (Navigator.canPop(context)) Navigator.pop(context);
  }

  prevPage() {
    if (currentPageValue > 0)
      _pageController
          ?.previousPage(
              duration: (widget.is3DTransform ? 400 : 300).milliseconds,
              curve: Curves.easeIn)
          .then((value) =>
              setState(() => currentPageValue = _pageController?.page ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      physics: widget.allowSwipe ? null : NeverScrollableScrollPhysics(),
      controller: _pageController,
      itemCount: widget.totalPages,
      itemBuilder: (context, index) {
        double value;
        if (_pageController?.position.haveDimensions == false) {
          value = index.toDouble();
        } else {
          value = _pageController?.page ?? index.toDouble();
        }
        return _SwipeWidget(
          index: index,
          pageNotifier: value,
          allow3d: widget.is3DTransform,
          child: widget.itemBuilder(
            Swiper(
              prevPage: prevPage,
              nextPage: nextPage,
              pageController: _pageController,
            ),
          )[index],
        );
      },
    );
  }
}

num degToRad(num deg) => deg * (pi / 180.0);

class _SwipeWidget extends StatelessWidget {
  final int index;

  final double pageNotifier;

  final Widget child;

  final bool allow3d;

  const _SwipeWidget({
    required this.index,
    required this.pageNotifier,
    required this.child,
    this.allow3d = true,
  });

  @override
  Widget build(BuildContext context) {
    final isLeaving = (index - pageNotifier) <= 0;
    final t = (index - pageNotifier);
    final rotationY = lerpDouble(0, 90, t);
    final opacity = lerpDouble(0, 1, t.abs())?.clamp(0.0, 1.0);
    final transform = Matrix4.identity();
    if (allow3d) transform.setEntry(3, 2, 0.001);
    transform.rotateY(-degToRad(rotationY ?? 0).toDouble());
    return Transform(
      alignment: isLeaving ? Alignment.centerRight : Alignment.centerLeft,
      transform: transform,
      child: Stack(
        children: [
          child,
          Positioned.fill(
            child: Opacity(
              opacity: opacity ?? 0,
              child: SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
