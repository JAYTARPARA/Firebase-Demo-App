import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebasedemo/theme/theming.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserDetails extends StatefulWidget {
  final String userid;
  UserDetails(this.userid);

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Firestore firestore = Firestore.instance;
  bool loadingUser = true;
  var name = "";
  var email = "";
  var mobile = "";
  var profilepic = "https://i.ibb.co/ZxrhKMw/dummy.jpg";

  @override
  void initState() {
    getUserDetails();
    super.initState();
  }

  Future getUserDetails() async {
    firestore.collection("users").document(widget.userid).get().then((value) {
      var userData = value.data;
      setState(() {
        name = userData["name"] == null || userData["name"] == ""
            ? "N/A"
            : userData["name"];
        email = userData["email"] == null || userData["email"] == ""
            ? userData['privacy'] ? "hidden by user" : "N/A"
            : userData['privacy'] ? "hidden by user" : userData["email"];
        mobile = userData["mobile"] == null || userData["mobile"] == ""
            ? userData['privacy'] ? "hidden by user" : "N/A"
            : userData['privacy'] ? "hidden by user" : userData["mobile"];
        profilepic = userData["profilepic"];
        loadingUser = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "User Detail",
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w800,
            color: Theming().lightTextColor,
          ),
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FaIcon(
                FontAwesomeIcons.arrowLeft,
                color: Theming().lightTextColor,
              ),
            ],
          ),
        ),
      ),
      body: loadingUser
          ? Container(
              child: Center(
                child: SpinKitWave(
                  color: Colors.white,
                  size: 40.0,
                ),
              ),
            )
          : Container(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Container(
                          height: 250.0,
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            image: DecorationImage(
                              image: AssetImage(
                                "assets/images/profile-bg.jpg",
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 35.0,
                            ),
                            child: Center(
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Stack(
                                  children: <Widget>[
                                    CircularProfileAvatar(
                                      profilepic,
                                      radius: 90,
                                      placeHolder: (context, url) =>
                                          SpinKitWave(
                                        color: Colors.white,
                                        size: 30.0,
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
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                      ),
                      children: <Widget>[
                        SizedBox(
                          height: 20.0,
                        ),
                        Divider(
                          height: 1,
                          color: Theming().dividerColor,
                        ),
                        ListTile(
                          leading: FaIcon(
                            FontAwesomeIcons.user,
                            size: 20.0,
                          ),
                          title: Text(
                            name,
                          ),
                        ),
                        Divider(
                          height: 1,
                          color: Theming().dividerColor,
                        ),
                        ListTile(
                          leading: FaIcon(
                            FontAwesomeIcons.envelope,
                            size: 20.0,
                          ),
                          title: Text(
                            email,
                          ),
                        ),
                        Divider(
                          height: 1,
                          color: Theming().dividerColor,
                        ),
                        ListTile(
                          leading: FaIcon(
                            FontAwesomeIcons.mobileAlt,
                            size: 20.0,
                          ),
                          title: Text(
                            mobile,
                          ),
                        ),
                        Divider(
                          height: 1,
                          color: Theming().dividerColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
