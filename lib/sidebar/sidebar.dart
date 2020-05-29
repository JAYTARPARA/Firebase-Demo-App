import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasedemo/common/common.dart';
import 'package:firebasedemo/screens/main_profile.dart';
import 'package:firebasedemo/screens/all_users.dart';
import 'package:firebasedemo/screens/splash_screen.dart';
import 'package:firebasedemo/theme/theming.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Sidebar extends StatefulWidget {
  final Function closeDrawer;
  final profileImage;
  final name;
  final page;
  const Sidebar({
    this.closeDrawer,
    this.profileImage,
    this.name,
    this.page,
  });

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<bool> _logout() {
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
      title: "LOG OUT",
      desc: "Are you sure you want to log out?",
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
          },
          width: 120,
        ),
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return Container(
      color: Colors.grey[700],
      width: mediaQuery.size.width * 0.60,
      height: mediaQuery.size.height,
      child: Column(
        children: <Widget>[
          Container(
              width: double.infinity,
              height: 200.0,
              color: Colors.black54,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: CircularProfileAvatar(
                      widget.profileImage,
                      radius: 60,
                      placeHolder: (context, url) => SpinKitWave(
                        color: Colors.white,
                        size: 30.0,
                      ),
                      animateFromOldImageOnUrlChange: true,
                      backgroundColor: Colors.transparent,
                      borderWidth: 2,
                      borderColor: Theme.of(context).primaryColor,
                      elevation: 10.0,
                      cacheImage: true,
                      showInitialTextAbovePicture: false,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ],
              )),
          ListTile(
            onTap: () {
              if (widget.page != "profile") {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) => MainProfile(),
                  ),
                );
              }
            },
            leading: Icon(
              Icons.person,
            ),
            title: Text(
              "My Profile",
            ),
            trailing: Visibility(
              visible: widget.page == "profile" ? true : false,
              child: Icon(
                Icons.check_circle_outline,
              ),
            ),
          ),
          Divider(
            height: 1,
            color: Theming().dividerColor,
          ),
          ListTile(
            onTap: () {
              if (widget.page != "all_users") {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) => AllUsers(),
                  ),
                );
              }
            },
            leading: Icon(
              Icons.group,
            ),
            title: Text(
              "All Users",
            ),
            trailing: Visibility(
              visible: widget.page == "all_users" ? true : false,
              child: Icon(
                Icons.check_circle_outline,
              ),
            ),
          ),
          Divider(
            height: 1,
            color: Theming().dividerColor,
          ),
          ListTile(
            onTap: () {
              _logout();
            },
            leading: Icon(
              Icons.exit_to_app,
            ),
            title: Text(
              "Log Out",
            ),
          ),
          Divider(
            height: 1,
            color: Theming().dividerColor,
          ),
        ],
      ),
    );
  }
}
