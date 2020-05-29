import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasedemo/common/common.dart';
import 'package:firebasedemo/screens/splash_screen.dart';
import 'package:firebasedemo/theme/theming.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:foldable_sidebar/foldable_sidebar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ThemeSetting extends StatefulWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey;
  ThemeSetting(this._scaffoldKey);

  @override
  _ThemeSettingState createState() => _ThemeSettingState();
}

class _ThemeSettingState extends State<ThemeSetting> {
  // final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseAuth auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  var userid = "";
  var currentThemeColor = "blue";
  FSBStatus drawerStatus = FSBStatus.FSB_CLOSE;
  bool userPrivacy = false;
  bool loadPrivacy = true;

  @override
  void initState() {
    getUser();
    getTheme();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  showSnackBar(
    msg,
    color,
  ) {
    widget._scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(
          msg,
          style: TextStyle(
            color: Theming().lightTextColor,
          ),
        ),
        duration: new Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        elevation: 3.0,
        backgroundColor: color,
      ),
    );
  }

  Future getUser() async {
    final FirebaseUser currentUser = await auth.currentUser();
    setState(() {
      userid = currentUser.uid;
    });

    firestore.collection("users").document(userid).get().then((value) {
      var userData = value.data;
      setState(() {
        userPrivacy = userData["privacy"];
        loadPrivacy = false;
      });
    });
  }

  Future getTheme() async {
    var setColor = await Common().readData("theme");
    if (setColor == null || setColor == "") {
      setState(() {
        currentThemeColor = "blue";
      });
    } else {
      setState(() {
        currentThemeColor = setColor;
      });
    }
  }

  updateUserPrivacy() async {
    // setState(() {
    //   loadPrivacy = true;
    // });
    await firestore.collection('users').document(userid).updateData({
      'privacy': userPrivacy,
    }).then((value) {
      // setState(() {
      //   loadPrivacy = false;
      // });
      showSnackBar(
        "Privacy updated successfully",
        Colors.green,
      );
    });
  }

  Future deleteAccount() async {
    firestore.collection("users").document(userid).delete();
    await Common().writeData("method", "");
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }
    await auth.signOut();
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => SplashScreen(),
      ),
    );
  }

  Future<bool> _confirmDeleteAccount() {
    return Alert(
      context: context,
      style: AlertStyle(
        isCloseButton: false,
        isOverlayTapDismiss: false,
        animationType: AnimationType.fromLeft,
        backgroundColor: Theme.of(context).primaryColor,
        descStyle: TextStyle(
          color: Theming().lightTextColor,
        ),
        titleStyle: TextStyle(
          color: Theming().lightTextColor,
        ),
      ),
      type: AlertType.none,
      title: "WARNING!",
      desc:
          "Are you sure you want to reset your account? \r\n Your all data will be deleted.",
      buttons: [
        DialogButton(
          color: Colors.black87,
          child: Text(
            "No",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(false),
          width: 120,
        ),
        DialogButton(
          color: Colors.black87,
          child: Text(
            "Yes",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          onPressed: () async {
            deleteAccount();
          },
          width: 120,
        ),
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(
        horizontal: 20.0,
      ),
      children: <Widget>[
        SizedBox(
          height: 20.0,
        ),
        Text(
          "Choose your theme",
          style: TextStyle(
            fontSize: 18.0,
            color: Theming().lightTextColor,
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        Wrap(
          spacing: 22.0,
          runSpacing: 12.0,
          children: <Widget>[
            GestureDetector(
              onTap: () async {
                await Common().writeData(
                  "theme",
                  "blue",
                );
                setState(() {
                  currentThemeColor = "blue";
                });
                DynamicTheme.of(context).setThemeData(
                  ThemeData(
                    primaryColor: Colors.blue,
                    accentColor: Colors.blue,
                    primarySwatch: Colors.blue,
                    brightness: Brightness.dark,
                    scaffoldBackgroundColor: Theming().scaffoldColor,
                    appBarTheme: AppBarTheme(
                      elevation: 10.0,
                    ),
                    fontFamily: 'Overpass',
                  ),
                );
              },
              child: ColorPicker(
                visibility: currentThemeColor == "blue" ? true : false,
                color: Colors.blue,
                name: "blue",
              ),
            ),
            GestureDetector(
              onTap: () async {
                await Common().writeData(
                  "theme",
                  "brown",
                );
                setState(() {
                  currentThemeColor = "brown";
                });
                DynamicTheme.of(context).setThemeData(
                  ThemeData(
                    primaryColor: Colors.brown,
                    accentColor: Colors.brown,
                    primarySwatch: Colors.brown,
                    brightness: Brightness.dark,
                    scaffoldBackgroundColor: Theming().scaffoldColor,
                    appBarTheme: AppBarTheme(
                      elevation: 10.0,
                    ),
                    fontFamily: 'Overpass',
                  ),
                );
              },
              child: ColorPicker(
                visibility: currentThemeColor == "brown" ? true : false,
                color: Colors.brown,
                name: "brown",
              ),
            ),
            GestureDetector(
              onTap: () async {
                await Common().writeData(
                  "theme",
                  "orange",
                );
                setState(() {
                  currentThemeColor = "orange";
                });
                DynamicTheme.of(context).setThemeData(
                  ThemeData(
                    primaryColor: Colors.orange,
                    accentColor: Colors.orange,
                    primarySwatch: Colors.orange,
                    brightness: Brightness.dark,
                    scaffoldBackgroundColor: Theming().scaffoldColor,
                    appBarTheme: AppBarTheme(
                      elevation: 10.0,
                    ),
                    fontFamily: 'Overpass',
                  ),
                );
              },
              child: ColorPicker(
                visibility: currentThemeColor == "orange" ? true : false,
                color: Colors.orange,
                name: "orange",
              ),
            ),
            GestureDetector(
              onTap: () async {
                await Common().writeData(
                  "theme",
                  "yellow",
                );
                setState(() {
                  currentThemeColor = "yellow";
                });
                DynamicTheme.of(context).setThemeData(
                  ThemeData(
                    primaryColor: Colors.yellow,
                    accentColor: Colors.yellow,
                    primarySwatch: Colors.yellow,
                    brightness: Brightness.dark,
                    scaffoldBackgroundColor: Theming().scaffoldColor,
                    appBarTheme: AppBarTheme(
                      elevation: 10.0,
                    ),
                    fontFamily: 'Overpass',
                  ),
                );
              },
              child: ColorPicker(
                visibility: currentThemeColor == "yellow" ? true : false,
                color: Colors.yellow,
                name: "yellow",
              ),
            ),
            GestureDetector(
              onTap: () async {
                await Common().writeData(
                  "theme",
                  "green",
                );
                setState(() {
                  currentThemeColor = "green";
                });
                DynamicTheme.of(context).setThemeData(
                  ThemeData(
                    primaryColor: Colors.green,
                    accentColor: Colors.green,
                    primarySwatch: Colors.green,
                    brightness: Brightness.dark,
                    scaffoldBackgroundColor: Theming().scaffoldColor,
                    appBarTheme: AppBarTheme(
                      elevation: 10.0,
                    ),
                    fontFamily: 'Overpass',
                  ),
                );
              },
              child: ColorPicker(
                visibility: currentThemeColor == "green" ? true : false,
                color: Colors.green,
                name: "green",
              ),
            ),
            GestureDetector(
              onTap: () async {
                await Common().writeData(
                  "theme",
                  "purple",
                );
                setState(() {
                  currentThemeColor = "purple";
                });
                DynamicTheme.of(context).setThemeData(
                  ThemeData(
                    primaryColor: Colors.purple,
                    accentColor: Colors.purple,
                    primarySwatch: Colors.purple,
                    brightness: Brightness.dark,
                    scaffoldBackgroundColor: Theming().scaffoldColor,
                    appBarTheme: AppBarTheme(
                      elevation: 10.0,
                    ),
                    fontFamily: 'Overpass',
                  ),
                );
              },
              child: ColorPicker(
                visibility: currentThemeColor == "purple" ? true : false,
                color: Colors.purple,
                name: "purple",
              ),
            ),
            GestureDetector(
              onTap: () async {
                await Common().writeData(
                  "theme",
                  "pink",
                );
                setState(() {
                  currentThemeColor = "pink";
                });
                DynamicTheme.of(context).setThemeData(
                  ThemeData(
                    primaryColor: Colors.pink,
                    accentColor: Colors.pink,
                    primarySwatch: Colors.pink,
                    brightness: Brightness.dark,
                    scaffoldBackgroundColor: Theming().scaffoldColor,
                    appBarTheme: AppBarTheme(
                      elevation: 10.0,
                    ),
                    fontFamily: 'Overpass',
                  ),
                );
              },
              child: ColorPicker(
                visibility: currentThemeColor == "pink" ? true : false,
                color: Colors.pink,
                name: "pink",
              ),
            ),
            GestureDetector(
              onTap: () async {
                await Common().writeData(
                  "theme",
                  "red",
                );
                setState(() {
                  currentThemeColor = "red";
                });
                DynamicTheme.of(context).setThemeData(
                  ThemeData(
                    primaryColor: Colors.red,
                    accentColor: Colors.red,
                    primarySwatch: Colors.red,
                    brightness: Brightness.dark,
                    scaffoldBackgroundColor: Theming().scaffoldColor,
                    appBarTheme: AppBarTheme(
                      elevation: 10.0,
                    ),
                    fontFamily: 'Overpass',
                  ),
                );
              },
              child: ColorPicker(
                visibility: currentThemeColor == "red" ? true : false,
                color: Colors.red,
                name: "red",
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Divider(
          height: 1,
          color: Theming().dividerColor,
        ),
        SizedBox(
          height: 10.0,
        ),
        Text(
          "Your privacy",
          style: TextStyle(
            fontSize: 18.0,
            color: Theming().lightTextColor,
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Hide your data from other users",
            ),
            loadPrivacy
                ? SpinKitWave(
                    color: Colors.white,
                    size: 30.0,
                  )
                : FlutterSwitch(
                    activeColor: Theme.of(context).primaryColor,
                    value: userPrivacy,
                    borderRadius: 30.0,
                    showOnOff: true,
                    onToggle: (val) {
                      setState(() {
                        userPrivacy = val;
                      });
                      updateUserPrivacy();
                    },
                  ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Divider(
          height: 1,
          color: Theming().dividerColor,
        ),
        SizedBox(
          height: 10.0,
        ),
        GestureDetector(
          onTap: () {
            _confirmDeleteAccount();
          },
          child: Container(
            height: MediaQuery.of(context).size.height / 3,
            alignment: Alignment.bottomCenter,
            child: Card(
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.white70,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(
                  10.0,
                ),
              ),
              margin: EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 8.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(
                    10.0,
                  ),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 1.0,
                  ),
                  leading: Container(
                    height: 25.0,
                    padding: EdgeInsets.only(
                      right: 12.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          width: 1.0,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    child: SizedBox(
                      height: 20.0,
                      width: 20.0,
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.trashAlt,
                          color: Theming().lightTextColor,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    "RESET MY ACCOUNT",
                    style: TextStyle(
                      color: Theming().lightTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ColorPicker extends StatefulWidget {
  final String name;
  final bool visibility;
  final Color color;
  ColorPicker({
    this.name,
    this.visibility,
    this.color,
  });
  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.0,
      width: 70.0,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.all(
          Radius.circular(
            50.0,
          ),
        ),
        border: Border.all(
          color: Colors.white,
        ),
      ),
      child: Visibility(
        visible: widget.visibility,
        child: Center(
          child: FaIcon(
            FontAwesomeIcons.palette,
          ),
        ),
      ),
    );
  }
}
