import 'package:flutter/cupertino.dart';
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
import 'package:owlet/models/Notification.dart' as N;
import 'package:owlet/models/User.dart';
import 'package:owlet/services/utils.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../helpers/helpers.dart';
import '../models/Notification.dart';
import '../models/Notification.dart';
import '../models/Notification.dart';
import 'FollowRequests.dart';

class NotificationScreen extends StatelessWidget {
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
          'Notifications',
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
          Expanded(child: NotificationList()),
        ],
      ),
    );
  }
}

class NotificationList extends StatefulWidget {
  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  NotificationResponse nd = NotificationResponse(
    totalItems: 0,
    totalPages: 0,
    currentPage: -1,
  );

  bool loading = true;
  late UserProvider user;
  @override
  void initState() {
    Future.delayed(Duration.zero, () => getNotifications(true));

    super.initState();
  }

  Future<dynamic> getNotifications(bool refresh) async {
    setState(() {
      user = Provider.of<UserProvider>(context, listen: false);
    });
    if (!user.isLoggedIn)
      Navigator.pop(context);
    else
      // final id = (ModalRoute.of(context)!.settings.arguments as SingleListingArgs).id;

      await fetchNotifications(refresh ? 0 : nd.currentPage + 1).then(
        (res) {
          setState(() {
            refresh ? nd = res : nd.setData = res;
            loading = false;
          });
          user.totalNotifications = 0;
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
    final ttLen = nd.notifications.length;
    final newLen = nd.newNotifications.length;
    final oldLen = nd.oldNotifications.length;
    return loading
        ? Loading(
            message: 'Fetching notifications',
          )
        : Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FollowNotificationScreen()),
                  );
                },
                child: Container(
                  height: 70,
                  width: 400,
                  color: fieldcolor,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Follow requests',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Icon(Icons.double_arrow_rounded)
                      ],
                    ),
                  ),
                ),
              ),
              nd.totalItems < 1
                  ? Center(
                      child: Text('You don\'t have any notification yet'),
                    )
                  : Expanded(
                      child: Container(
                          child: PullToLoad(
                        refresh: () => getNotifications(true),
                        load: () => getNotifications(false),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: ttLen,
                          //+ (newLen > 0 ? 1 : 0) + (oldLen > 0 ? 1 : 0),
                          itemBuilder: (_, i) => newLen > 0
                              ? i <= newLen
                                  ?
                                  //i == 0
                                  //     ? title(
                                  //         text: 'New notifications',
                                  //         iconColor: Colors.green,
                                  //       )
                                  //     :
                                  NotificationItem(
                                      notification: nd.notifications[i])
                                  // : oldLen > 0 && i == newLen + 1
                                  //     ? title(
                                  //         text: 'Past notifications',
                                  //         iconColor: Colors.grey,
                                  //       )
                                  : NotificationItem(
                                      notification: nd.notifications[i])
                              // : i == 0
                              //     ? title(
                              //         text: 'Past notifications',
                              //         iconColor: Colors.grey,
                              //       )
                              : NotificationItem(
                                  notification: nd.notifications[i]),
                        ),
                      )),
                    ),
            ],
          );
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
  const NotificationItem({required this.notification});

  final N.Notification notification;

  @override
  State<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  late bool iFollow = widget.notification.sender.iFollow;
  String formatISOTime(DateTime date) {
    date = date.toUtc();
    final convertedDate = date.toLocal();
    String formated_date = "";

    formated_date = (DateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(convertedDate));
    return formated_date;
    // var duration = date.timeZoneOffset;
    // if (duration.isNegative) {
    //   fstring = (DateFormat("dd MMM , HH:mm a").format(date) +
    //       "-${duration.inHours.toString().padLeft(2, '0')}${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}");
    //   String result = fstring.replaceAll("+0000", " ");
    //
    //   return result;
    // } else {
    //   fstring = (DateFormat("dd MMM , HH:mm a").format(date) +
    //       "+${duration.inHours.toString().padLeft(2, '0')}${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}");
    //   String result = fstring.replaceAll("+0000", " ");
    //   return result;
    // }
  }

  @override
  Widget build(BuildContext context) {
    var NotificationTime = DateTime.parse(widget.notification.Updatedat);
    final user = Provider.of<UserProvider>(context, listen: false);
    final utility = Provider.of<UtilsProvider>(context, listen: false);
    final sender = widget.notification.sender;
    final type = widget.notification.notifyableType;
    final isAccount = type == N.NotificationType.FOLLOW;
    final listing = widget.notification.listing;

    showSeller() async {
      ProfileViewModal.show(context);
      await utility.getCurrentProfileFromUsername(sender.username);
    }

    showListing() => Navigator.pushNamed(context, SingleListingScreen.routeName,
        arguments: SingleListingArgs(
          id: listing!.id,
        ));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            crossAxisAlignment: isAccount
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              InkWell(
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white30,
                  backgroundImage: AssetImage(loadingGif),
                  foregroundImage: NetworkImage(sender.avartar),
                ),
                onTap: showSeller,
              ),
              Expanded(
                child: InkWell(
                  onTap:
                      isAccount && listing == null ? showSeller : showListing,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              sender.username,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Container(
                              width: 40,
                              child: Center(
                                child: timeAgo(formatISOTime(NotificationTime) ??
                                        DateTime.now().toString())
                                    .text
                                    .size(12)
                                    .semiBold
                                    .color(icolor)
                                    .make(),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        ReadMore(
                          maxLength: 2000,
                          style: TextStyle(
                              fontSize: 12,
                              color: description.withOpacity(0.6)),
                          caption: isAccount
                              ? 'Started following you'
                              : type == N.NotificationType.MENTION &&
                                      listing != null
                                  ? 'Mentioned you in a post: ${listing.caption} '
                                  : type == N.NotificationType.LIKE &&
                                          listing != null
                                      ? 'Liked one of your post: ${listing.caption} '
                                      : '',
                        ),

                        // Text(
                        //   '${isAccount ? "@" : "#"}$title',
                        //   style: TextStyle(fontWeight: FontWeight.bold),
                        // ),
                        // Text(subtitle)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.90, child: Divider()),
      ],
    );
  }
}
