import 'dart:io';

import 'package:firebasedemo/screens/login.dart';
import 'package:firebasedemo/screens/register.dart';
import 'package:firebasedemo/theme/theming.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      vsync: this,
      initialIndex: 0,
      length: 2,
    );
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
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
          "Firebase Demo",
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w800,
            color: Theming().lightTextColor,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
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
              text: "LOGIN",
            ),
            Tab(
              text: "REGISTER",
            ),
          ],
        ),
      ),
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: TabBarView(
          controller: _tabController,
          children: <Widget>[
            Login(_scaffoldKey),
            Register(_scaffoldKey),
          ],
        ),
      ),
    );
  }
}
