import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:owlet/Components/CircleButton.dart';
import 'package:owlet/Components/Loading.dart';
import 'package:owlet/Providers/Auth.dart';
import 'package:owlet/Providers/GlobalProvider.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Screens/AddListingScreen.dart';
import 'package:owlet/Screens/ChatListScreen.dart';
import 'package:owlet/Screens/FollowingScreen.dart';
import 'package:owlet/Screens/Home.dart';
import 'package:owlet/Screens/Login.dart';
import 'package:owlet/Screens/ProfileScreen.dart';
import 'package:owlet/Screens/Settings_screen/SettingsScreen.dart';
import 'package:owlet/Widgets/BounceBtn.dart';
import 'package:owlet/Widgets/StorySwipe.dart';
import 'package:owlet/constants/constants.dart';
import 'package:owlet/constants/images.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:owlet/enum.dart';
import 'package:owlet/helpers/firebase.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:owlet/models/Message.dart';
import 'package:owlet/models/User.dart';
import 'package:owlet/services/apiUrl.dart';
import 'package:owlet/services/utils.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_svg/flutter_svg.dart';

Socket socket = io(
  AppUrl.baseURL,
  OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      // .setQuery({'token': await getToken})
      .build(),
);

class NavScreen extends StatefulWidget {
  static const routeName = '/nav';
  @override
  _NavScreenState createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> with WidgetsBindingObserver {
  List<Widget> _pages = [
    HomeScreen(),
    FollowingScreen(istopbar: true,),
    AddListingScreen(),
    ProfileScreen(),
    SettingsScreen()
  ];
  int _selectedPageIndex = 0;
  bool loading = true;
  AppLifecycleState appState = AppLifecycleState.resumed;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    Future.delayed(Duration.zero, () {
      onOpenFCMHandler(context);
      loadData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    socket.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print(state);
    if ((state == AppLifecycleState.resumed ||
        state == AppLifecycleState.paused)) {
      await flutterLocalNotificationsPlugin.cancelAll();
      if (!socket.connected) socket.connect();
    } else
      socket.close();

    appState = state;

    setState(() {});
  }

  void connect() async {
    try {
      socket.io.options['query'] = {'token': await getToken};
      socket.connect();
      socket.onConnect((data) async {
        print('Connected to server');
        await GlobalProvider(context).userProvider.loadChats();
      });
      final userData = Provider.of<UserProvider>(context, listen: false);

      socket.on('sendMsg', receiveMsg);

      socket.on(
          'delivered',
          (res) =>
              userData.updateChatState(res['receiverId'], ChatState.DELIVERED));

      socket.on('seen', myMsgsSeen);

      socket.on('user-offline', _handleUserOffline);

      socket.on('user-online', _handleUserOnline);
      socket.onDisconnect((_) {
        debugPrint('disconnect');
        // retryConnectOnFailure(50000);
      });
    } catch (e) {
      // socket.query = 'token=${await getToken}';
      print(e);
    }
  }

  void retryConnectOnFailure(int retryInMilliseconds) {
    Future.delayed(retryInMilliseconds.milliseconds, () async {
      if (!socket.connected) {
        await pingServer();
        retryConnectOnFailure(retryInMilliseconds);
      }
    });
  }

  void _handleUserOffline(dynamic id) {
    print('User $id disconnected');
    Provider.of<UserProvider>(context, listen: false).userOffline = id;
  }

  void _handleUserOnline(dynamic id) {
    Provider.of<UserProvider>(context, listen: false).userOnline = id;
  }

  void myMsgsSeen(_) {
    print('seen $_');
    // final userData = Provider.of<UserProvider>(context, listen: false);
    // userData.updateChatState(userData.profile.id, ChatState.SEEN);
  }

  void receiveMsg(msg) async {
    final userData = Provider.of<UserProvider>(context, listen: false);

    await userData.receiveMsg(
      Message.fromMap(msg).copyWith(
          sender: User(
        id: msg['senderId'],
        username: msg['username'],
        avtar: msg['avartar'],
        lastSeen: DateTime.now().toIso8601String(),
      )),
    );
    if (appState == AppLifecycleState.paused ||
        appState == AppLifecycleState.inactive)
      foregroundFCMHandler(
        context,
        RemoteMessage(
          notification: RemoteNotification(
              title: 'New message 💬',
              body: 'You have a new message 📩 from @${msg['username']}',
              android: AndroidNotification()),
          data: {
            'notifyableType': 'new-message',
            'senderId': '${msg['senderId']}',
            'username': msg['username'],
            'avartar': msg['avartar'],
          },
        ),
      );
    socket.emit('received', msg['senderId']);
  }

  set selectPage(int index) => setState(() => _selectedPageIndex = index);

  loadData() async {
    await GlobalProvider(context).authProListenFalse.validate();
    await GlobalProvider(context).loadData();
    loading = false;
    connect();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !loading
          ? _pages[_selectedPageIndex]

          // VxAnimatedBox(child: _pages[_selectedPageIndex])
          //     .animDuration(2.seconds)
          //     .width(context.screenWidth)
          //     .linear
          //     .make()
          : Center(
              child: Loading(
              message: "Setting up your market",
            )),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: Global.bottomNavHeight,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  offset: const Offset(0, -5),
                  blurRadius: 5,
                  color: const Color(0xFF4B1A39).withOpacity(0.05)),
            ],
          ),
          child: Consumer<UserProvider>(
            builder: (_, user, child) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                navItem(
                  title: 'Home',
                  asset: home_icon,
                  onPress: () {
                    selectPage = 0;
                  },
                  selected: _selectedPageIndex == 0,
                ).onDoubleTap(GlobalProvider(context).loadData),
                navItem(
                  title: 'Trending',
                  asset: trending_icon,
                  onPress: () => () {
                    selectPage = 1;
                  }(),
                  selected: _selectedPageIndex == 1,
                ),
                navItem(
                  title: 'Add Listing',
                  onPress: () => () {
                    selectPage = 2;
                  }(),
                  asset: _selectedPageIndex == 2
                      ? add_listing_icon_selected
                      : add_listing_icon,
                  naturalColor: _selectedPageIndex == 2,
                  selected: false,
                ),
                navItem(
                  title: 'Profile',
                  onPress: () => () {
                    selectPage = 3;
                  }(),
                  asset: profile_icon,
                  selected: _selectedPageIndex == 3,
                ),
                navItem(
                  title: 'Settings',
                  onPress: () => () {
                    selectPage = 4;
                  }(),
                  asset: settings_icon,
                  selected: _selectedPageIndex == 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column navItem({
    required String title,
    required Function() onPress,
    required String asset,
    bool selected = false,
    bool naturalColor = false,
    double? size = 14 * 1.8,
    Widget? child,
  }) {
    final navTitleStyle = TextStyle(
      color: selected ? Palette.primaryColor : Colors.grey.shade400,
      fontWeight: FontWeight.bold,
      fontSize: 9,
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        child != null
            ? child
            : BounceBtn(
                press: onPress,
                child: naturalColor
                    ? SvgPicture.asset(asset)
                    : SvgPicture.asset(
                        asset,
                        color: selected
                            ? Palette.primaryColor
                            : Colors.grey.shade400,
                      ),
              ),
        Text(
          title,
          style: navTitleStyle,
        )
      ],
    );
  }
}
