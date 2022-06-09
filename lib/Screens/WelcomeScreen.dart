import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:owlet/Preferences/UserPreferences.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Screens/Login.dart';
import 'package:owlet/Screens/NavScreen.dart';
import 'package:owlet/constants/images.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:owlet/modals/TermsAndCondition.dart';
import 'package:provider/provider.dart';
import '../Providers/GlobalProvider.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool? deviceIsReg;
  @override
  void initState() {
    Future.delayed(Duration.zero, initApp);
    super.initState();
  }

  initApp() async {
    await GlobalProvider(context).authProListenFalse.validate();
    await GlobalProvider(context).loadData();
    deviceIsReg = await UserPreferences().isDeviceRegistered;

    setState(() {});
  }

  final wrapper =
      ({required Widget child}) => Scaffold(body: SafeArea(child: child));

  @override
  Widget build(BuildContext context) {
    return deviceIsReg != null
        ? deviceIsReg!
            ? Consumer<UserProvider>(
                builder: (_, user, child) =>
                    user.isLoggedIn ? NavScreen() : LoginScreen())
            : wrapper(child: Welcome())
        : wrapper(child: Center(child: CupertinoActivityIndicator()));
  }
}

class Welcome extends StatelessWidget {
  const Welcome({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 2),
        Image.asset(welcomeImg),
        const Spacer(flex: 2),
        Text(
          'Welcome to Owlet \nMarket for Everyone',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const Spacer(flex: 2),
        Text(
          'Freedom to Transact with Anyone \nAnywhere',
          textAlign: TextAlign.center,
          style: TextStyle(
            color:
                Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.64),
          ),
        ),
        const Spacer(flex: 2),
        FittedBox(
          child: TextButton(
            onPressed: () => showCupertinoModalBottomSheet(
              context: context,
              builder: (context) => TermsAndConditions(),
              backgroundColor: Colors.black.withOpacity(0.2),
              duration: Duration(milliseconds: 400),
              expand: true,
              enableDrag: false,
            ),
            child: Row(
              children: [
                Text(
                  'Continue',
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .color!
                          .withOpacity(0.8)),
                ),
                SizedBox(
                  height: kDefaultPadding / 4,
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .color!
                      .withOpacity(0.8),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}