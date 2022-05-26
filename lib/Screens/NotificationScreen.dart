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
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  FollowNotificationScreen()),
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
                      Text('Follow request'),
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
                                NotificationItem(notification: nd.notifications[i])
                                // : oldLen > 0 && i == newLen + 1
                                //     ? title(
                                //         text: 'Past notifications',
                                //         iconColor: Colors.grey,
                                //       )
                                : NotificationItem(notification: nd.notifications[i])
                            // : i == 0
                            //     ? title(
                            //         text: 'Past notifications',
                            //         iconColor: Colors.grey,
                            //       )
                            : NotificationItem(notification: nd.notifications[i]),
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
  @override
  Widget build(BuildContext context) {
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

    return Container(
      // margin: EdgeInsets.symmetric(vertical: 4, horizontal: 15),
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
                        Text(
                          sender.username,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        ReadMore(
                          maxLength: 2000,
                          style: TextStyle(fontSize: 12),
                          caption: isAccount
                              ? 'Started following you'
                              : type == N.NotificationType.MENTION &&
                                      listing != null
                                  ? 'Mentioned you in a post: ${listing.caption} '
                                  : type == N.NotificationType.LIKE &&
                                          listing != null
                                      ? 'Liked one of your post: ${listing.caption} '
                                      : '',
                        )
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
              // timeAgo(sender.notification.last.time ??
              //         DateTime.now().toString())
              //     .text
              //     .size(12)
              //     .color(Palette.primaryColor)
              //     .textStyle(TextStyle(fontWeight: FontWeight.w600))
              //     .make(),
              // isAccount
              //     ? iFollow || user.profile.id == sender.id
              //         ? Text(
              //             'Following',
              //             style: TextStyle(fontStyle: FontStyle.italic),
              //           )
              //         : Button(
              //             text: 'Follow back',
              //             press: user.isLoggedIn
              //                 ? () {
              //                     setState(() => iFollow = !iFollow);
              //                     user
              //                         .followUser(User(
              //                           id: sender.id,
              //                           fullName: 'fullName',f
              //                           username: sender.username,
              //                           email: 'email',
              //                           phone: 'phone',
              //                         ))
              //                         .catchError((onError) =>
              //                             setState(() => iFollow = !iFollow));
              //                   }
              //                 : () => Navigator.of(context)
              //                     .pushNamed(LoginScreen.routeName),
              //             paddingVert: 4,
              //             paddingHori: 8,
              //           )
              //     : InkWell(
              //         child: ClipRRect(
              //           borderRadius: BorderRadius.circular(3),
              //           child: Image.network(
              //             listing!.images[0],
              //             height: 40,
              //             filterQuality: FilterQuality.medium,
              //           ),
              //         ),
              //         onTap: showListing,
              //       )
              // ProfileAvatar(
              //     avatar: listing!.images[0],
              //   ),

              // DateFormat("dd, MMM")
              //     .format(
              //         DateTime.tryParse(product.createdAt) ?? DateTime.now())
              //     .text
              //     .sm
              //     .gray400
              //     .make()
            ],
          ),
          Divider(),
        ],
      ),
    );
  }
}
