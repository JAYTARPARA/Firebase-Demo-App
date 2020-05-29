import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasedemo/screens/profile.dart';
import 'package:firebasedemo/screens/theme_setting.dart';
import 'package:firebasedemo/sidebar/sidebar.dart';
import 'package:firebasedemo/theme/theming.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foldable_sidebar/foldable_sidebar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class MainProfile extends StatefulWidget {
  @override
  _MainProfileState createState() => _MainProfileState();
}

class _MainProfileState extends State<MainProfile>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseAuth auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;
  TabController _tabController;
  FSBStatus drawerStatus = FSBStatus.FSB_CLOSE;
  var userid = "";
  var username = "";
  String _uploadedFileURL = "https://i.ibb.co/ZxrhKMw/dummy.jpg";

  @override
  void initState() {
    getUser();
    super.initState();
    _tabController = TabController(
      vsync: this,
      initialIndex: 0,
      length: 2,
    );
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  Future getUser() async {
    final FirebaseUser currentUser = await auth.currentUser();
    setState(() {
      userid = currentUser.uid;
    });

    firestore.collection("users").document(userid).get().then((value) {
      var userData = value.data;
      if (userData == null) {
        setState(() {
          username = "Your Name";
        });
      } else {
        if (userData['name'] != null) {
          setState(() {
            username = userData['name'];
          });
        } else {
          setState(() {
            username = "Your Name";
          });
        }
      }
    });
  }

  Future<bool> _onWillPop() {
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
      title: "EXIT APP",
      desc: "Are you sure you want to exit?",
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
          onPressed: () => exit(0),
          width: 120,
        ),
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "My Profile",
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w800,
            color: Theming().lightTextColor,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: drawerStatus == FSBStatus.FSB_OPEN
              ? FaIcon(
                  FontAwesomeIcons.times,
                  color: Theming().lightTextColor,
                )
              : FaIcon(
                  FontAwesomeIcons.bars,
                  color: Theming().lightTextColor,
                ),
          onPressed: () {
            setState(() {
              drawerStatus = drawerStatus == FSBStatus.FSB_OPEN
                  ? FSBStatus.FSB_CLOSE
                  : FSBStatus.FSB_OPEN;
            });
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theming().lightTextColor,
          labelColor: Theming().lightTextColor,
          unselectedLabelColor: Theming().lightTextColor,
          labelStyle: TextStyle(
            fontSize: 16.0,
            color: Theming().lightTextColor,
            fontWeight: FontWeight.w900,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w300,
          ),
          tabs: <Widget>[
            Tab(
              text: "PROFILE",
            ),
            Tab(
              text: "THEME & PRIVACY",
            ),
          ],
        ),
      ),
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: FoldableSidebarBuilder(
          drawerBackgroundColor: Theming().scaffoldColor,
          status: drawerStatus,
          drawer: Sidebar(
            closeDrawer: () {
              setState(() {
                drawerStatus = FSBStatus.FSB_CLOSE;
              });
            },
            profileImage: _uploadedFileURL,
            name: username,
            page: "profile",
          ),
          screenContents: GestureDetector(
            // onHorizontalDragStart: (details) {
            //   setState(() {
            //     if (drawerStatus == FSBStatus.FSB_CLOSE) {
            //       drawerStatus = FSBStatus.FSB_OPEN;
            //     }
            //   });
            // },
            onTap: () {
              setState(() {
                if (drawerStatus == FSBStatus.FSB_OPEN) {
                  drawerStatus = FSBStatus.FSB_CLOSE;
                }
              });
            },
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                Profile(_scaffoldKey),
                ThemeSetting(_scaffoldKey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
