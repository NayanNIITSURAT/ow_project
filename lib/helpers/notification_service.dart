// import 'dart:convert';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:owlet/constants/constants.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// class NotificationData {
//   final String name;
//   final DateTime date;

//   NotificationData(this.name, this.date);

//   NotificationData.fromJson(Map<String, dynamic> json)
//       : name = json['name'],
//         date = json['date'];

//   String get stringify => jsonEncode({"name": name, "date": date.toString()});
// }

// class NotificationService {
//   static final NotificationService _notificationService =
//       NotificationService._internal();

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   factory NotificationService() {
//     return _notificationService;
//   }

//   NotificationService._internal();

//   static const channel_id = "123";

//   Future<void> init() async {
//     final AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('app_icon');

//     final InitializationSettings initializationSettings =
//         InitializationSettings(
//             android: initializationSettingsAndroid, iOS: null, macOS: null);
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//         onSelectNotification: (_) => print('onSelectNotification $_'));
//     tz.initializeTimeZones();
//   }

//   Future selectNotification(String payload) async {
//     NotificationData data = getDataFromPayload(payload);
//     cancelNotificationForBirthday(data);
//     scheduleNotificationForBirthday(
//         data, "${data.name} has an upcoming birthday!");
//   }

//   // void showNotification(
//   //     NotificationData data, String notificationMessage) async {
//   //   await flutterLocalNotificationsPlugin.show(
//   //     data.hashCode,
//   //     applicationName,
//   //     notificationMessage,
//   //     const NotificationDetails(
//   //         android: AndroidNotificationDetails(channel_id, applicationName,
//   //             channelDescription: 'To remind you about upcoming birthdays')),
//   //     payload: data.stringify,
//   //   );
//   // }

//   // void scheduleNotificationForBirthday(
//   //     NotificationData data, String notificationMessage) async {
//   //   DateTime now = DateTime.now();
//   //   DateTime birthdayDate = data.date;
//   //   Duration difference = now.isAfter(birthdayDate)
//   //       ? now.difference(birthdayDate)
//   //       : birthdayDate.difference(now);

//   //   _wasApplicationLaunchedFromNotification()
//   //       .then((bool didApplicationLaunchFromNotification) => {
//   //             if (didApplicationLaunchFromNotification &&
//   //                 difference.inDays == 0)
//   //               {scheduleNotificationForNextYear(data, notificationMessage)}
//   //             else if (!didApplicationLaunchFromNotification &&
//   //                 difference.inDays == 0)
//   //               {showNotification(data, notificationMessage)}
//   //           });

//     // await flutterLocalNotificationsPlugin.zonedSchedule(
//     //     data.hashCode,
//     //     applicationName,
//     //     notificationMessage,
//     //     tz.TZDateTime.now(tz.local).add(difference),
//     //     const NotificationDetails(
//     //         android: AndroidNotificationDetails(channel_id, applicationName,
//     //             channelDescription: 'To remind you about upcoming birthdays')),
//     //     payload: data.stringify,
//     //     androidAllowWhileIdle: true,
//     //     uiLocalNotificationDateInterpretation:
//     //         UILocalNotificationDateInterpretation.absoluteTime);
//   }

//   void scheduleNotificationForNextYear(
//       NotificationData data, String notificationMessage) async {
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//         data.hashCode,
//         applicationName,
//         notificationMessage,
//         tz.TZDateTime.now(tz.local).add(new Duration(days: 365)),
//         const NotificationDetails(
//             android: AndroidNotificationDetails(channel_id, applicationName,
//                 channelDescription: 'To remind you about upcoming birthdays')),
//         payload: data.stringify,
//         androidAllowWhileIdle: true,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime);
//   }

//   void cancelNotificationForBirthday(NotificationData birthday) async {
//     await flutterLocalNotificationsPlugin.cancel(birthday.hashCode);
//   }

//   void cancelAllNotifications() async {
//     await flutterLocalNotificationsPlugin.cancelAll();
//   }

//   void handleApplicationWasLaunchedFromNotification() async {
//     final NotificationAppLaunchDetails? notificationAppLaunchDetails =
//         await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

//     if (notificationAppLaunchDetails!.didNotificationLaunchApp) {
//       NotificationData data =
//           getDataFromPayload(notificationAppLaunchDetails.payload ?? '');
//       cancelNotificationForBirthday(data);
//       scheduleNotificationForBirthday(
//           data, "${data.name} has an upcoming birthday!");
//     }
//   }

//   NotificationData getDataFromPayload(String payload) {
//     Map<String, dynamic> json = jsonDecode(payload);
//     NotificationData data = NotificationData.fromJson(json);
//     return data;
//   }

//   Future<bool> _wasApplicationLaunchedFromNotification() async {
//     final NotificationAppLaunchDetails? notificationAppLaunchDetails =
//         await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

//     return notificationAppLaunchDetails!.didNotificationLaunchApp;
//   }
// }
