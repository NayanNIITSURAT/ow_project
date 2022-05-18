// import 'package:chat/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:google_fonts/google_fonts.dart';
import 'package:owlet/constants/constants.dart';
import 'package:owlet/constants/palettes.dart';

ThemeData lightThemeData(BuildContext context) {
  Map<int, Color> color = {
    50: Color.fromRGBO(223, 65, 11, .1),
    100: Color.fromRGBO(223, 65, 11, .2),
    200: Color.fromRGBO(223, 65, 11, .3),
    300: Color.fromRGBO(223, 65, 11, .4),
    400: Color.fromRGBO(223, 65, 11, .5),
    500: Color.fromRGBO(223, 65, 11, .6),
    600: Color.fromRGBO(223, 65, 11, .7),
    700: Color.fromRGBO(223, 65, 11, .8),
    800: Color.fromRGBO(223, 65, 11, .9),
    900: Color.fromRGBO(223, 65, 11, 1),
  };
  return ThemeData(
      primarySwatch: MaterialColor(0xFFDF410B, color),
      scaffoldBackgroundColor: Palette.primaryColorLight,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Palette.primaryColor,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black54),
      ),
      iconTheme: IconThemeData(color: Colors.grey),
      fontFamily: GoogleFonts.poppins().fontFamily,

      // primaryColor: MaterialColor(0xFFDF410B, color),
      textTheme: TextTheme(
        headline2: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Palette.primaryColor,
        ),
        bodyText1: TextStyle(fontSize: Global.fontSize, letterSpacing: 0.1),
      ),
      listTileTheme: ListTileThemeData()

      // GoogleFonts.interTextTheme(Theme.of(context).textTheme)
      //     .apply(
      //       bodyColor: kContentColorLightTheme,
      //       fontFamily: GoogleFonts.poppins().fontFamily,
      //     )
      //     .copyWith(
      // floatingActionButtonTheme: FloatingActionButtonThemeData(
      //   backgroundColor: Palette.primaryColor,
      // ),
      // colorScheme: ColorScheme.light(
      //   primary: MaterialColor(0xFFDF410B, color),
      //   secondary: kSecondaryColor,
      //   error: kErrorColor,
      // ),

      // primarySwatch: MaterialColor(0xFFDF410B, color),
      // scaffoldBackgroundColor: Palette.primaryColorLight,
      // fontFamily: 'Lato',
      // appBarTheme: AppBarTheme(
      //   backgroundColor: Colors.white,
      //   titleTextStyle: TextStyle(
      //     color: Palette.primaryColor,
      //   ),
      //   elevation: 1,
      //   iconTheme: IconThemeData(color: Colors.black54),
      // ),
      // textTheme: TextTheme(
      //   headline2: TextStyle(
      //     fontSize: 36,
      //     fontWeight: FontWeight.bold,
      //     color: Palette.primaryColor,
      //   ),
      // ),
      );
}

ThemeData darkThemeData(BuildContext context) {
  return ThemeData.dark().copyWith(
    primaryColor: kPrimaryColor,
    scaffoldBackgroundColor: kContentColorLightTheme,
    appBarTheme: appBarTheme,
    iconTheme: IconThemeData(color: kContentColorDarkTheme),
    textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme)
        .apply(bodyColor: kContentColorDarkTheme),
    colorScheme: ColorScheme.dark().copyWith(
      primary: kPrimaryColor,
      secondary: kSecondaryColor,
      error: kErrorColor,
    ),
  );
}

final appBarTheme = AppBarTheme(
  backgroundColor: Colors.white,
  titleTextStyle: TextStyle(
    color: Palette.primaryColor,
  ),
  elevation: 1,
  iconTheme: IconThemeData(color: Colors.black54),
  centerTitle: false,
);
