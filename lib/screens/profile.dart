import 'dart:io';
import 'dart:async';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebasedemo/sidebar/sidebar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:foldable_sidebar/foldable_sidebar.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebasedemo/common/common.dart';
import 'package:firebasedemo/theme/theming.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:email_validator/email_validator.dart';
import 'package:unicorndial/unicorndial.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseAuth auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  var userid = "";
  TextEditingController _name = TextEditingController();
  TextEditingController _mobile = TextEditingController();
  TextEditingController _email = TextEditingController();
  bool disableEmail = false;
  bool disableMobile = false;
  bool showChangePassword = false;
  String note = "";
  bool updateProfile = false;
  bool uploadingPic = false;
  File _image;
  String _uploadedFileURL = "https://i.ibb.co/ZxrhKMw/dummy.jpg";
  FSBStatus drawerStatus = FSBStatus.FSB_CLOSE;
  bool loadingData = true;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  static FirebaseInAppMessaging fiam = FirebaseInAppMessaging();
  var tokenFCM = "";

  @override
  void initState() {
    getUser();
    initFCM();
    super.initState();
  }

  initFCM() async {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    _firebaseMessaging.subscribeToTopic("firebase_user");
    _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
        sound: true,
        badge: true,
        alert: true,
        provisional: true,
      ),
    );
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) async {
      assert(token != null);
      // print("TOKEN: $token");
      setState(() {
        tokenFCM = token;
      });
    });
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
    var method = await Common().readData("method");
    if (method == null || method == "") {
      if (currentUser.email != null) {
        await Common().writeData("method", "email");
        setState(() {
          disableEmail = true;
          showChangePassword = true;
          note = "You can not change your email address";
        });
      } else if (currentUser.phoneNumber != null) {
        await Common().writeData("method", "mobile");
        setState(() {
          disableMobile = true;
          note = "You can not change your mobile number";
        });
      }
    } else if (method == "email") {
      setState(() {
        disableEmail = true;
        showChangePassword = true;
        note = "You can not change your email address";
      });
    } else if (method == "mobile") {
      setState(() {
        disableMobile = true;
        note = "You can not change your mobile number";
      });
    }
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
          'fcmtoken': tokenFCM,
          'privacy': false,
        });
        setState(() {
          _email.text = currentUser.email;
          _mobile.text = currentUser.phoneNumber;
          loadingData = false;
        });
      } else {
        setState(() {
          if (userData['profilepic'] != null) {
            _uploadedFileURL = userData['profilepic'];
          }
          _name.text = userData["name"];
          _email.text = userData["email"];
          _mobile.text = userData["mobile"];
          loadingData = false;
        });
      }
    });
  }

  saveUserData() async {
    setState(() {
      updateProfile = true;
    });
    await firestore.collection('users').document(userid).updateData({
      'name': _name.text,
      'email': _email.text,
      'mobile': _mobile.text,
    }).then((value) {
      setState(() {
        updateProfile = false;
        showSnackBar(
          "Profile updated successfully",
          Colors.green,
        );
      });
    });
  }

  sendResetPassword() async {
    setState(() {
      updateProfile = true;
    });
    await auth.sendPasswordResetEmail(
      email: _email.text,
    );
    Timer(new Duration(seconds: 3), () async {
      showSnackBar(
        "We have sent an email to ${_email.text}",
        Colors.green,
      );
      setState(() {
        updateProfile = false;
      });
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

  Future chooseFile(type) async {
    var source;
    if (type == "gallery") {
      source = ImageSource.gallery;
    } else if (type == "camera") {
      source = ImageSource.camera;
    }
    await ImagePicker.pickImage(source: source).then((image) {
      if (image != null) {
        setState(() {
          _image = image;
        });
        uploadFile();
      }
    });
  }

  Future uploadFile() async {
    setState(() {
      updateProfile = true;
      uploadingPic = true;
    });
    String ext = path.extension(_image.path);
    String fileName = "profile/$userid$ext";
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    firebaseStorageRef.getDownloadURL().then((fileURL) async {
      setState(() {
        _uploadedFileURL = fileURL;
        uploadingPic = false;
      });
      await firestore.collection('users').document(userid).updateData({
        'profilepic': fileURL,
      }).then((value) {
        setState(() {
          updateProfile = false;
          showSnackBar(
            "Profile picture updated",
            Colors.green,
          );
        });
      });
    });
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
      ),
      body: GestureDetector(
        onHorizontalDragStart: (details) {
          setState(() {
            if (drawerStatus == FSBStatus.FSB_CLOSE) {
              drawerStatus = FSBStatus.FSB_OPEN;
            }
          });
        },
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
              name: _name.text == null ? "Your Name" : _name.text,
              page: "profile",
            ),
            screenContents: SingleChildScrollView(
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                        child: uploadingPic
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 35.0,
                                ),
                                child: Center(
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                      height: 180.0,
                                      width: 180.0,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                      child: SpinKitWave(
                                        color: Colors.white,
                                        size: 30.0,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Padding(
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
                                          _uploadedFileURL,
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
                                          // onTap: () {
                                          //   chooseFile();
                                          // },
                                          showInitialTextAbovePicture: false,
                                        ),
                                        Positioned(
                                          bottom: 0.0,
                                          right: 0.0,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                32.0,
                                              ),
                                            ),
                                            child: Container(
                                              height: 150.0,
                                              width: 50.0,
                                              decoration: BoxDecoration(
                                                color: Colors.transparent,
                                              ),
                                              child: UnicornDialer(
                                                orientation:
                                                    UnicornOrientation.VERTICAL,
                                                parentButton: Icon(
                                                  Icons.perm_identity,
                                                ),
                                                hasBackground: false,
                                                childButtons: [
                                                  UnicornButton(
                                                    currentButton:
                                                        FloatingActionButton(
                                                      heroTag: "camera",
                                                      mini: true,
                                                      child: Icon(
                                                        Icons.photo_camera,
                                                        color: Theming()
                                                            .lightTextColor,
                                                      ),
                                                      onPressed: () {
                                                        chooseFile("camera");
                                                      },
                                                    ),
                                                  ),
                                                  UnicornButton(
                                                    currentButton:
                                                        FloatingActionButton(
                                                      heroTag: "gallery",
                                                      mini: true,
                                                      child: Icon(
                                                        Icons.image,
                                                        color: Theming()
                                                            .lightTextColor,
                                                      ),
                                                      onPressed: () {
                                                        chooseFile("gallery");
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                  loadingData
                      ? Container(
                          height: 400.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                child: SpinKitWave(
                                  color: Colors.white,
                                  size: 40.0,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ),
                          children: <Widget>[
                            SizedBox(
                              height: 20.0,
                            ),
                            Text(
                              "*Note: $note",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 15.0,
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Card(
                              elevation: 3.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                      5.0,
                                    ),
                                  ),
                                ),
                                child: TextField(
                                  cursorColor: Theme.of(context).primaryColor,
                                  keyboardType: TextInputType.text,
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    color: Theming().darkTextColor,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(
                                      10.0,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        5.0,
                                      ),
                                      borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        5.0,
                                      ),
                                      borderSide: BorderSide(
                                        color: Theming().lightTextColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theming().lightTextColor,
                                      ),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    hintText: "Full Name",
                                    hintStyle: TextStyle(
                                      fontSize: 15.0,
                                      color: Theming().darkTextColor,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.perm_identity,
                                      color: Theming().darkTextColor,
                                    ),
                                  ),
                                  maxLines: 1,
                                  controller: _name,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Card(
                              elevation: 3.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                      5.0,
                                    ),
                                  ),
                                ),
                                child: TextField(
                                  cursorColor: Theme.of(context).primaryColor,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    color: Theming().darkTextColor,
                                  ),
                                  enabled: disableEmail ? false : true,
                                  decoration: InputDecoration(
                                    filled: disableEmail ? true : false,
                                    fillColor: Colors.black26,
                                    contentPadding: EdgeInsets.all(
                                      10.0,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        5.0,
                                      ),
                                      borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        5.0,
                                      ),
                                      borderSide: BorderSide(
                                        color: Theming().lightTextColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theming().lightTextColor,
                                      ),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    hintText: "Email Address",
                                    hintStyle: TextStyle(
                                      fontSize: 15.0,
                                      color: Theming().darkTextColor,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.alternate_email,
                                      color: Theming().darkTextColor,
                                    ),
                                  ),
                                  maxLines: 1,
                                  controller: _email,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Card(
                              elevation: 3.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                      5.0,
                                    ),
                                  ),
                                ),
                                child: TextField(
                                  cursorColor: Theme.of(context).primaryColor,
                                  keyboardType: TextInputType.phone,
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    color: Theming().darkTextColor,
                                  ),
                                  enabled: disableMobile ? false : true,
                                  decoration: InputDecoration(
                                    filled: disableMobile ? true : false,
                                    fillColor: Colors.black26,
                                    contentPadding: EdgeInsets.all(
                                      10.0,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        5.0,
                                      ),
                                      borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        5.0,
                                      ),
                                      borderSide: BorderSide(
                                        color: Theming().lightTextColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theming().lightTextColor,
                                      ),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    hintText: "Mobile Number",
                                    hintStyle: TextStyle(
                                      fontSize: 15.0,
                                      color: Theming().darkTextColor,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.mobile_screen_share,
                                      color: Theming().darkTextColor,
                                    ),
                                  ),
                                  maxLines: 1,
                                  controller: _mobile,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            RaisedButton(
                              onPressed: updateProfile
                                  ? null
                                  : () {
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                      var fullname = _name.text;
                                      var email = _email.text;
                                      var mobile = _mobile.text;

                                      if (fullname == "" ||
                                          email == "" ||
                                          mobile == "") {
                                        showSnackBar(
                                          "Please fill all details",
                                          Colors.red,
                                        );
                                      } else if (email != "" &&
                                          !EmailValidator.validate(email)) {
                                        showSnackBar(
                                          "Please provide valid email address",
                                          Colors.red,
                                        );
                                      } else if (mobile != "" &&
                                          !mobile.contains("+")) {
                                        showSnackBar(
                                          "Please provide mobile number with country code",
                                          Colors.red,
                                        );
                                      } else {
                                        saveUserData();
                                      }
                                    },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 8.0,
                                ),
                                child: Text(
                                  "UPDATE MY PROFILE",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                              color: Theme.of(context).primaryColor,
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            showChangePassword
                                ? RaisedButton(
                                    onPressed: updateProfile
                                        ? null
                                        : () {
                                            sendResetPassword();
                                          },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.0,
                                        horizontal: 8.0,
                                      ),
                                      child: Text(
                                        "SET/RESET PASSWORD",
                                        style: TextStyle(
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                    color: Theme.of(context).primaryColor,
                                  )
                                : Container(),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
