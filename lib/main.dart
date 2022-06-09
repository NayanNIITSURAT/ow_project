// @dart=2.9

import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:owlet/Components/Toast.dart' as Ts;
import 'package:owlet/Preferences/UserPreferences.dart';
import 'package:owlet/Providers/Auth.dart';
import 'package:owlet/Providers/Flag.dart';
import 'package:owlet/Providers/GlobalProvider.dart';
import 'package:owlet/Providers/HashTagProvider.dart';
import 'package:owlet/Providers/Listing.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Providers/UtilsProvider.dart';
import 'package:owlet/Screens/AddListingScreen.dart';
import 'package:owlet/Screens/AddMarketSquare.dart';
import 'package:owlet/Screens/ChatListScreen.dart';
import 'package:owlet/Screens/ChatScreen.dart';
import 'package:owlet/Screens/Confirmation.dart';
import 'package:owlet/Screens/Followers.dart';
import 'package:owlet/Screens/FollowingScreen.dart';
import 'package:owlet/Screens/ForgotPassword.dart';
import 'package:owlet/Screens/HashTagScreen.dart';
import 'package:owlet/Screens/Home.dart';
import 'package:owlet/Screens/ListingsScreen.dart';
import 'package:owlet/Screens/LoanApplicationScreen.dart';
import 'package:owlet/Screens/Login.dart';
import 'package:owlet/Screens/NavScreen.dart';
import 'package:owlet/Screens/NotificationScreen.dart';
import 'package:owlet/Screens/Otp/OtpScreen.dart';
import 'package:owlet/Screens/ProfileEdit.dart';
import 'package:owlet/Screens/ProfileScreen.dart';
import 'package:owlet/Screens/Register.dart';
import 'package:owlet/Screens/ResetPasswordScreen.dart';
import 'package:owlet/Screens/SearchScreen.dart';
import 'package:owlet/Screens/Settings_screen/SettingsScreen.dart';
import 'package:owlet/Screens/SingleListingScreen.dart';
import 'package:owlet/Screens/Stories.dart';
import 'package:owlet/Screens/TextStoryScreen.dart';
import 'package:owlet/Screens/Verification.dart';
import 'package:owlet/Screens/WelcomeScreen.dart';
import 'package:owlet/Screens/CameraScreen.dart';
import 'package:owlet/Widgets/DismissKeyboard.dart';
import 'package:owlet/helpers/firebase.dart';
import 'package:owlet/theme.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';
import 'package:wakelock/wakelock.dart';

import 'models/Requestuser.dart';
import 'models/passbooknotifier.dart';
import 'models/walletRefresh.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  if (kDebugMode || kProfileMode) {
    HttpOverrides.global = MyHttpOverrides();
  }
  if(Platform.isIOS) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'AIzaSyDrzQdClVnMZWkEVHiCH7Pr_QlEt1Q8EVQ',
        appId: '1:248113028784:ios:1575c9a0d8328e7fc22575',
        messagingSenderId: '248113028784',
        projectId: 'the-owlet-mobile-app',
      ), //This line is necessary
    );
  }else{
    await Firebase.initializeApp();
  }
  await initFirebase();
  await UserPreferences().init();

  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

final cloudinary =
    CloudinaryPublic('cybertech-digitals-ltd', 'theowlet', cache: false);
final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      Wakelock.enable();
      // Upgrader().clearSavedSettings();
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
            create: (ctx) => UserProvider(),
            update: (context, auth, prev) =>
                prev?.update(auth: auth) ?? UserProvider().update(auth: auth)),
        ChangeNotifierProvider(create: (ctx) => ListingProvider()),
        // ChangeNotifierProvider(create: (ctx) => PackageProvider()),
        ChangeNotifierProvider(create: (ctx) => HashTagProvider()),
        ChangeNotifierProvider(create: (ctx) => UtilsProvider()),
        ChangeNotifierProvider(create: (ctx) => UserPreferences()),
        ChangeNotifierProvider(create: (ctx) => FlagProvider()),
        ChangeNotifierProvider(create: (ctx) => GlobalProvider(ctx)),
        ChangeNotifierProvider<passbooknotifier>(
            create: (_) => passbooknotifier()),
        ChangeNotifierProvider<WalletRefresh>(create: (_) => WalletRefresh()),
        ChangeNotifierProvider(create: (ctx) => Product()),
      ],
      child: DismissKeyboard(
        child: OverlaySupport.global(
          child: MaterialApp(
            title: 'The Owlet',
            debugShowCheckedModeBanner: false,
            theme: lightThemeData(context),
            navigatorObservers: [routeObserver],
            // darkTheme: darkThemeData(context),
            home: UpgradeAlert(
              dialogStyle: UpgradeDialogStyle.cupertino,
              canDismissDialog: false,
              // debugLogging: true,
              showIgnore: false,
              showLater: false,
              onIgnore: () {
                SystemNavigator.pop();
                return false;
              },
              child: MainApp(),
            ),

            routes: {
              RegisterScreen.routeName: (ctx) => RegisterScreen(),
              LoginScreen.routeName: (ctx) => LoginScreen(),
              ForgotPasswordScreen.routeName: (ctx) => ForgotPasswordScreen(),
              HomeScreen.routeName: (ctx) => HomeScreen(),
              ProfileScreen.routeName: (ctx) => ProfileScreen(),
              // PackagesScreen.routeName: (ctx) => PackagesScreen(),
              AddListingScreen.routeName: (ctx) => AddListingScreen(),
              HashTagScreen.routeName: (ctx) => HashTagScreen(),
              NavScreen.routeName: (ctx) => NavScreen(),
              ChatListScreen.routeName: (ctx) => ChatListScreen(),
              ChatScreen.routeName: (ctx) => ChatScreen(),
              SearchScreen.routeName: (ctx) => SearchScreen(),
              // ListingsScreen.routeName: (ctx) => ListingsScreen(),
              ProfileEdit.routeName: (ctx) => ProfileEdit(),
              OtpScreen.routeName: (ctx) => OtpScreen(),
              ResetPasswordScreen.routeName: (ctx) => ResetPasswordScreen(),
              Followers.routeName: (ctx) => Followers(),
              FollowingScreen.routeName: (ctx) => FollowingScreen(
                    istopbar: true,
                  ),
              NotificationScreen.routeName: (ctx) => NotificationScreen(),
              SingleListingScreen.routeName: (ctx) => SingleListingScreen(),
              ConfirmationScreen.routeName: (ctx) => ConfirmationScreen(),
              VerificationScreen.routeName: (ctx) => VerificationScreen(),
              LoanApplicationScreen.routeName: (ctx) => LoanApplicationScreen(),
              Stories.routeName: (ctx) => Stories(),
              // PicturePreviewScreen.routeName: (ctx) => PicturePreviewScreen(),
              TextStoryScreen.routeName: (ctx) => TextStoryScreen(),
              CameraScreen.routeName: (ctx) => CameraScreen(),
              SettingsScreen.routeName: (ctx) => SettingsScreen(),
              AddListingScreen.routeName: (ctx) => AddListingScreen(),
              AddMarketSquareScreen.routeName: (ctx) => AddMarketSquareScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == ListingsScreen.routeName) {
                final args = settings.arguments as ListingsArgs;

                return MaterialPageRoute(
                  builder: (context) {
                    return ListingsScreen(
                      initialIndex: args.initialIndex,
                      providerType: args.providerType,
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({
    Key key,
  }) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  @override
  void initState() {
    Future.delayed(Duration.zero, initConnectivity);
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    super.initState();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result = ConnectivityResult.none;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
      Ts.Toast(context, message: 'Failed to check conectivity').show();
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  @override
  Widget build(BuildContext context) {
    // NotificationService().showNotification(
    //     NotificationData('Ebuka', DateTime.now()), 'Test notifi');
    return WelcomeScreen();
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        {
          Ts.Toast(context,
                  message: 'Wifi connection established', bgColor: Colors.green)
              .show();
        }
        break;
      case ConnectivityResult.mobile:
        {
          Ts.Toast(context,
                  message: 'Mobile connection established',
                  bgColor: Colors.green)
              .show();
        }
        break;
      case ConnectivityResult.none:
        Ts.Toast(context,
                message: 'No internet connection', bgColor: Colors.red)
            .show();
        break;
      default:
        Ts.Toast(context, message: 'Failed to get internet status.').show();
        break;
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
