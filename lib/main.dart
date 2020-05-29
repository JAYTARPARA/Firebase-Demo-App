import 'package:country_code_picker/country_localizations.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebasedemo/common/common.dart';
import 'package:firebasedemo/screens/all_users.dart';
import 'package:firebasedemo/screens/home.dart';
import 'package:firebasedemo/screens/main_profile.dart';
import 'package:firebasedemo/screens/mobile_otp.dart';
import 'package:firebasedemo/screens/splash_screen.dart';
import 'package:firebasedemo/theme/theming.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color themeColor = Colors.blue;

  @override
  void initState() {
    getTheme();
    super.initState();
  }

  Future getTheme() async {
    var setColor = await Common().readData("theme");
    if (setColor == null) {
      await Common().writeData(
        "theme",
        "blue",
      );
      setState(() {
        themeColor = Colors.blue;
      });
    } else if (setColor == "brown") {
      setState(() {
        themeColor = Colors.brown;
      });
    } else if (setColor == "orange") {
      setState(() {
        themeColor = Colors.orange;
      });
    } else if (setColor == "yellow") {
      setState(() {
        themeColor = Colors.yellow;
      });
    } else if (setColor == "green") {
      setState(() {
        themeColor = Colors.green;
      });
    } else if (setColor == "purple") {
      setState(() {
        themeColor = Colors.purple;
      });
    } else if (setColor == "pink") {
      setState(() {
        themeColor = Colors.pink;
      });
    } else if (setColor == "red") {
      setState(() {
        themeColor = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.dark,
      data: (brightness) => ThemeData(
        scaffoldBackgroundColor: Theming().scaffoldColor,
        primarySwatch: themeColor,
        brightness: brightness,
        primaryColor: themeColor,
        accentColor: themeColor,
        appBarTheme: AppBarTheme(
          elevation: 10.0,
        ),
        fontFamily: 'Overpass',
      ),
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          supportedLocales: [
            Locale('en'),
          ],
          localizationsDelegates: [
            CountryLocalizations.delegate,
          ],
          title: 'Firebase Demo',
          debugShowCheckedModeBanner: false,
          theme: theme,
          // ThemeData(
          //   scaffoldBackgroundColor: Theming().scaffoldColor,
          //   primarySwatch: Theming().prColor,
          //   brightness: Brightness.dark,
          //   appBarTheme: AppBarTheme(
          //     elevation: 10.0,
          //   ),
          //   fontFamily: 'Overpass',
          //   primaryColor: Colors.blue,
          //   accentColor: Colors.blue,
          // ),
          home: SplashScreen(),
          routes: <String, WidgetBuilder>{
            '/splash': (BuildContext context) => new SplashScreen(),
            '/home': (BuildContext context) => new Home(),
            '/profile': (BuildContext context) => new MainProfile(),
            '/mobile-otp': (BuildContext context) => new MobileOtp(),
            '/all-users': (BuildContext context) => new AllUsers(),
          },
        );
      },
    );
  }
}
