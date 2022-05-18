import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PullToLoad extends StatefulWidget {
  final Widget child;
  final Future Function() refresh;
  final Future Function() load;
  final int column;
  PullToLoad({
    required this.child,
    required this.refresh,
    required this.load,
    this.column: 3,
  });
  @override
  _PullToLoadState createState() => _PullToLoadState();
}

class _PullToLoadState extends State<PullToLoad> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: WaterDropHeader(),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus? mode) {
            Widget body;
            // if (mode == LoadStatus.idle) {
            //   body = Text("Pull up to load more");
            // } else
            if (mode == LoadStatus.loading) {
              body = CupertinoActivityIndicator();
              // } else if (mode == LoadStatus.failed) {
              //   body = Text("Load Failed!Click retry!");
              // } else if (mode == LoadStatus.canLoading) {
              //   body = Text("release to load more");
            } else {
              body = Text("No more Data");
            }
            return Container(
              height: 70.0,
              child: Center(child: body),
            );
          },
        ),
        controller: _refreshController,
        onRefresh: () async {
          await widget.refresh();
          _refreshController.refreshCompleted();
        },
        onLoading: () async {
          await widget.load();
          _refreshController.loadComplete();
        },
        child: widget.child
        // ),
        );
  }
}
