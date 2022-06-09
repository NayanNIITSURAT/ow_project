import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Providers/UtilsProvider.dart';
import 'package:owlet/Screens/ChatScreen.dart';
import 'package:owlet/Screens/SingleListingScreen.dart';
import 'package:owlet/modals/ProfileViewModal.dart';
import 'package:owlet/models/ChatUser.dart';
import 'package:provider/provider.dart';

class PushNotification {
  PushNotification({
    this.title,
    this.body,
  });
  String? title;
  String? body;
}

class NotificationBadge extends StatelessWidget {
  final int totalNotifications;

  const NotificationBadge({this.totalNotifications = 2});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: new BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '$totalNotifications',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}

late final FirebaseMessaging _messaging = FirebaseMessaging.instance;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description:
      'This channel is used for important notifications.', // description
  importance: Importance.max,
);
const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('notification_icon');
final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
  onDidReceiveLocalNotification: (_, __, ___, ____) => print('IOS WORKS'),
);

final InitializationSettings initializationSettings = InitializationSettings(
  android: initializationSettingsAndroid,
  iOS: initializationSettingsIOS,
);

Future<void> initFirebase() async {
  print('Init firebase');
  //await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundFCMHandler);

// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project

  // 2. Instantiate Firebase Messaging
  _messaging.getToken().then((value) {});
}

checkPermission(Function() callback) async {
  // 3. On iOS, this helps to take the user permissions
  NotificationSettings settings = await _messaging.requestPermission(
    alert: true,
    badge: true,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized)
    await callback();
  else {
    print(
        'You just missed a notification, kindly go to app and activate push notification');
    toast(
        'You just missed a notification, kindly go to app and activate push notification');
  }
}

Future<void> backgroundFCMHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  await checkPermission(() async {
    RemoteNotification? notification = message.notification;
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification!.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: 'notification_icon',

          // other properties...
        ),
      ),
      payload: message.data.toString(),
    );
  });
}

void foregroundFCMHandler(BuildContext context, RemoteMessage message) async {
  final userData = Provider.of<UserProvider>(context, listen: false);
  userData.totalNotifications = userData.totalNotifications + 1;
  RemoteNotification? notification = message.notification;

  await flutterLocalNotificationsPlugin.show(
    notification.hashCode,
    notification!.title,
    notification.body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id, channel.name,
        channelDescription: channel.description,
        icon: 'notification_icon',
        // fullScreenIntent: true,
        // autoCancel: true, // other properties...
      ),
      iOS: IOSNotificationDetails(
        threadIdentifier: channel.id,
        subtitle: 'The Owlet marketplace',
        presentAlert: true,
        presentSound: true,

        // fullScreenIntent: true,
        // autoCancel: true, // other properties...
      ),
    ),
    payload: jsonEncode(message.data),
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (res) =>
        _handleMessage(context, jsonDecode(res ?? '')),
  );
}

void _handleMessage(BuildContext context, Map<String, dynamic> data) async {
  if (data['notifyableType'] == 'MENTION' || data['notifyableType'] == 'LIKE')
    Navigator.pushNamed(
      context,
      SingleListingScreen.routeName,
      arguments: SingleListingArgs(id: int.parse(data['notifyableId'])),
    );
  else if (data['notifyableType'] == 'new-message') {
    print(data);
    Provider.of<UserProvider>(context, listen: false).curChatUser = ChatUser(
      id: int.parse(data['senderId']),
      username: data['username'],
      avartar: data['avartar'],
      lastSeen: DateTime.now(),
    );
    Navigator.pushNamed(
      context,
      ChatScreen.routeName,
      arguments: SingleListingArgs(id: int.parse(data['notifyableId'])),
    );
  } else {
    ProfileViewModal.show(context);
    await Provider.of<UtilsProvider>(context, listen: false)
        .getCurrentProfileFromUsername(data['senderId']);
  }
}

// For handling notification when the app is in terminated state
void onOpenFCMHandler(BuildContext context) async {
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (res) =>
        _handleMessage(context, jsonDecode(res ?? '')),
  );

  FirebaseMessaging.onMessage
      .listen((event) => foregroundFCMHandler(context, event));

  FirebaseMessaging.onMessageOpenedApp
      .listen((message) => _handleMessage(context, message.data));
}

void resetFCMInstance() {
  _messaging.deleteToken();
  initFirebase();
}
