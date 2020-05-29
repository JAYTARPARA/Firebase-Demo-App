import 'dart:io';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasedemo/screens/user_details.dart';
import 'package:firebasedemo/sidebar/sidebar.dart';
import 'package:firebasedemo/theme/theming.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:foldable_sidebar/foldable_sidebar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class AllUsers extends StatefulWidget {
  @override
  _AllUsersState createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseAuth auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;
  var userid = "";
  var username = "";
  String _uploadedFileURL = "https://i.ibb.co/ZxrhKMw/dummy.jpg";
  FSBStatus drawerStatus = FSBStatus.FSB_CLOSE;

  @override
  void initState() {
    getUser();
    super.initState();
  }

  showSnackBar(
    msg,
    color,
  ) {
    _scaffoldKey.currentState.showSnackBar(
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
      if (userData == null) {
        firestore.collection('users').document(userid).setData({
          'userid': currentUser.uid,
          'email': currentUser.email,
          'mobile': currentUser.phoneNumber,
          'profilepic': "https://i.ibb.co/ZxrhKMw/dummy.jpg",
        });
      } else {
        setState(() {
          if (userData['profilepic'] != null) {
            _uploadedFileURL = userData['profilepic'];
          }
        });
      }
      if (userData['name'] != null) {
        setState(() {
          username = userData['name'];
        });
      } else {
        setState(() {
          username = "Your Name";
        });
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
          "All Users",
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
      ),
      body: GestureDetector(
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
        child: WillPopScope(
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
              page: "all_users",
            ),
            screenContents: Padding(
              padding: EdgeInsets.only(
                top: 10.0,
              ),
              child: StreamBuilder(
                stream: firestore.collection("users").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.data == null)
                    return Center(
                      child: SpinKitWave(
                        color: Colors.white,
                        size: 50.0,
                      ),
                    );
                  return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot user = snapshot.data.documents[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                              builder: (context) => UserDetails(user["userid"]),
                            ),
                          );
                        },
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
                            vertical: 6.0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(
                                64,
                                75,
                                96,
                                0.9,
                              ),
                              borderRadius: BorderRadius.circular(
                                10.0,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 10.0,
                              ),
                              leading: Container(
                                padding: EdgeInsets.only(
                                  right: 12.0,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      width: 1.0,
                                      color: Colors.white24,
                                    ),
                                  ),
                                ),
                                child: SizedBox(
                                  height: 50.0,
                                  width: 50.0,
                                  child: Center(
                                    child: CircularProfileAvatar(
                                      user['profilepic'] == null
                                          ? "https://i.ibb.co/ZxrhKMw/dummy.jpg"
                                          : user['profilepic'],
                                      radius: 50,
                                      placeHolder: (context, url) =>
                                          SpinKitWave(
                                        color: Colors.white,
                                        size: 10.0,
                                      ),
                                      animateFromOldImageOnUrlChange: true,
                                      backgroundColor: Colors.transparent,
                                      borderWidth: 2,
                                      borderColor:
                                          Theme.of(context).primaryColor,
                                      elevation: 10.0,
                                      cacheImage: true,
                                      showInitialTextAbovePicture: false,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                user['name'] == null || user["name"] == ""
                                    ? "N/A"
                                    : user['name'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Row(
                                children: <Widget>[
                                  FaIcon(
                                    FontAwesomeIcons.envelope,
                                    color: Colors.white,
                                    size: 18.0,
                                  ),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  Text(
                                    user['email'] == null || user["email"] == ""
                                        ? user['privacy']
                                            ? "hidden by user"
                                            : "N/A"
                                        : user['privacy']
                                            ? "hidden by user"
                                            : user['email'],
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                      builder: (context) =>
                                          UserDetails(user["userid"]),
                                    ),
                                  );
                                },
                                child: FaIcon(
                                  FontAwesomeIcons.arrowRight,
                                  color: Colors.white,
                                  size: 20.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
