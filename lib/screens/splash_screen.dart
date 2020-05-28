import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasedemo/screens/home.dart';
import 'package:firebasedemo/screens/profile.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String animation;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    defineFlow();
  }

  defineFlow() async {
    bool loggedin = await checkUser();
    Future.delayed(
        Duration(
          milliseconds: 3000,
        ), () {
      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          child: loggedin ? Profile() : Home(),
        ),
      );
    });
  }

  checkUser() async {
    final FirebaseUser currentUser = await auth.currentUser();
    if (currentUser != null) {
      if (currentUser.uid != "") {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
    // var chkLoggedin = await Common().readData('loggedin');
    // if (chkLoggedin != null && chkLoggedin == "yes") {
    //   return true;
    // } else {
    //   return false;
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        child: Center(
          child: Container(
            height: MediaQuery.of(context).size.height / 2.0,
            child: Center(
              child: FlareActor(
                "assets/images/splash_screen.flr",
                fit: BoxFit.cover,
                animation: "Untitled",
              ),
            ),
          ),
        ),
      ),
    );
  }
}
