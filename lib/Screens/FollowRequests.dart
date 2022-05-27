import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:owlet/Components/Button.dart';
import 'package:owlet/Components/Loading.dart';
import 'package:owlet/Components/ReadMore.dart';
import 'package:owlet/Components/Toast.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Providers/UtilsProvider.dart';
import 'package:owlet/Screens/Login.dart';
import 'package:owlet/Screens/SingleListingScreen.dart';
import 'package:owlet/Widgets/PullToRefresh.dart';
import 'package:owlet/constants/images.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:owlet/modals/ProfileViewModal.dart';
import 'package:owlet/models/HttpResponse.dart';
import 'package:owlet/models/User.dart';
import 'package:owlet/services/utils.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../Components/bottomsheetbutton.dart';
import '../models/Requestuser.dart';

class FollowNotificationScreen extends StatelessWidget {
  static const routeName = 'notifications-screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Palette.primaryColorLight,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        title: Text(
          'Follow Requests',
          style: Theme.of(context)
              .textTheme
              .headline6!
              .copyWith(fontWeight: FontWeight.w600, fontSize: 17),
        ),
      ),
      body: Column(
        children: [
          // Divider(
          //   height: 2,
          // ),
          Expanded(child: FollowNotificationList()),
        ],
      ),
    );
  }
}

class FollowNotificationList extends StatefulWidget {
  @override
  State<FollowNotificationList> createState() => _FollowNotificationListState();
}

class _FollowNotificationListState extends State<FollowNotificationList> {
  Product? nd;
  // NotificationResponse nd = NotificationResponse(
  //   totalItems: 0,
  //   totalPages: 0,
  //   currentPage: -1,
  // );

  bool loading = true;
  late UserProvider user;
  @override
  void initState() {
    Future.delayed(Duration.zero, () => requestNotification(true));

    super.initState();
  }

  Future<dynamic> requestNotification(bool refresh) async {
    setState(() {
      user = Provider.of<UserProvider>(context, listen: false);
    });
    if (!user.isLoggedIn)
      Navigator.pop(context);
    else
      await senderRequest(await getuserid).then(
        (res) {
          setState(() {
            nd = res;
            loading = false;
          });
          // user.totalNotifications = 0;
        },
      ).catchError((onError) {
        print(onError.toString());
        Toast(
          context,
          message: 'Unable to fetch notifications',
          type: ToastType.ERROR,
        ).showTop();
        Navigator.pop(context);
        setState(() {
          loading = false;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    // final ttLen = nd.notifications.length;
    // final newLen = nd.newNotifications.length;
    // final oldLen = nd.oldNotifications.length;
    return loading
        ? Loading(
            message: 'Fetching notifications',
          )
        : nd!.data.length < 1
            ? Center(
                child: Text('You don\'t have any notification yet'),
              )
            : Container(
                child: PullToLoad(
                refresh: () => requestNotification(true),
                load: () => requestNotification(false),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: nd!.data.length,
                  //+ (newLen > 0 ? 1 : 0) + (oldLen > 0 ? 1 : 0),
                  itemBuilder: (_, i) =>
                      NotificationItem(notification: nd!.data![i]),
                ),
              ));
  }
}

Widget title({required String text, required Color iconColor}) => Container(
      color: Colors.grey.shade100,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(top: 5, bottom: 5),
      width: double.infinity,
      child: Row(
        children: [
          Icon(
            Icons.circle,
            color: iconColor,
            size: 16,
          ),
          Text(
            '  $text',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              // fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

class NotificationItem extends StatefulWidget {
  const NotificationItem({
    required this.notification,
  });

  final Datum notification;

  @override
  State<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false);
    final utility = Provider.of<UtilsProvider>(context, listen: false);
    final Size size = MediaQuery.of(context).size;
    final Color color, textColor;

    showSeller() async {
      ProfileViewModal.show(context);
      await utility.getCurrentProfileFromUsername(
        widget.notification.requesterUser.username,
      );
    }

    showListing() => Navigator.pushNamed(context, SingleListingScreen.routeName,
        arguments: SingleListingArgs(
          id: widget.notification.requesterUser.id,
        ));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            // spreadRadius: 3,
            color: Colors.grey.shade100,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white30,
                  backgroundImage: AssetImage(loadingGif),
                  foregroundImage:
                      NetworkImage(widget.notification.requesterUser.avartar),
                ),
                onTap: showSeller,
              ),
              Expanded(
                child: InkWell(
                  onTap: showSeller,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Text(
                              widget.notification.requesterUser.username,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              widget.notification.requesterUser.fullName,
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                child: Container(
                  height: size.height * 0.050,
                  width: size.width * 0.2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment(0.04, 5.5),
                      colors: <Color>[
                        Color(0xffee0000),
                        Color(0xffF33909),
                        Color(0xffFE6D0A).withOpacity(0.8)
                      ], // red to yellow
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                    child: Center(
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                            color: Palette.primaryColorLight,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              InkWell(
                child: Container(
                  height: size.height * 0.050,
                  width: size.width * 0.2,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                    child: Center(
                      child: Text('Delete',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(),
        ],
      ),
    );
  }
}
