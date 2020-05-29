import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasedemo/screens/main_profile.dart';
import 'package:firebasedemo/screens/mobile_otp.dart';
import 'package:firebasedemo/theme/theming.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  final scaffoldKey;
  Login(this.scaffoldKey);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool _obscureText = true;
  bool loading = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  // final facebookLogin = FacebookLogin();

  showSnackBar(
    msg,
    color,
  ) {
    widget.scaffoldKey.currentState.showSnackBar(
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

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  loginUserWithEmailAndPassword(email, password) async {
    setState(() {
      loading = true;
    });
    try {
      AuthResult result = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final FirebaseUser user = result.user;

      assert(user != null);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await auth.currentUser();

      if (currentUser.uid != "") {
        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) => MainProfile(),
          ),
        );
      }

      return user;
    } catch (e) {
      setState(() {
        loading = false;
      });
      print(e);
      showError(e);
      return null;
    }
  }

  showError(error) {
    print("ERROR");
    print(error.code);
    var errCode = error.code;

    if (errCode == "ERROR_USER_NOT_FOUND") {
      showSnackBar(
        "User not found!",
        Colors.red,
      );
    } else if (errCode == "ERROR_WRONG_PASSWORD") {
      showSnackBar(
        "You have entered wrong password!",
        Colors.red,
      );
    }
  }

  Future<String> signInWithGoogle() async {
    setState(() {
      loading = true;
    });
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final AuthResult authResult = await auth.signInWithCredential(
        credential,
      );

      final FirebaseUser user = authResult.user;
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await auth.currentUser();
      assert(user.uid == currentUser.uid);
      if (currentUser.uid != "") {
        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) => MainProfile(),
          ),
        );
      }
      return 'signInWithGoogle succeeded: $user';
    } else {
      setState(() {
        loading = false;
      });
      return "error";
    }
  }

  // Future<FacebookLoginResult> signInWithFacebook() async {
  //   FacebookLoginResult facebookLoginResult =
  //       await facebookLogin.logIn(['email']);

  //   switch (facebookLoginResult.status) {
  //     case FacebookLoginStatus.cancelledByUser:
  //       print("Cancelled");
  //       break;
  //     case FacebookLoginStatus.error:
  //       print("error");
  //       print(facebookLoginResult.errorMessage);
  //       break;
  //     case FacebookLoginStatus.loggedIn:
  //       print("Logged In");
  //       break;
  //   }
  //   return facebookLoginResult;
  // }

  redirectToProfile() {
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => MainProfile(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20.0,
        0,
        20,
        0,
      ),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          SizedBox(
            height: 10.0,
          ),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(
              top: 25.0,
            ),
            child: Text(
              "Log in to your account",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
                color: Theming().lightTextColor,
              ),
            ),
          ),
          SizedBox(
            height: 30.0,
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
                color: Theming().lightTextColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    5.0,
                  ),
                ),
              ),
              child: TextField(
                cursorColor: Theme.of(context).primaryColor,
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
                    borderRadius: BorderRadius.circular(
                      5.0,
                    ),
                  ),
                  hintText: "Password",
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Theming().darkTextColor,
                  ),
                  hintStyle: TextStyle(
                    fontSize: 15.0,
                    color: Theming().darkTextColor,
                  ),
                  suffixIcon: GestureDetector(
                    dragStartBehavior: DragStartBehavior.down,
                    onTap: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    child: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Theming().darkTextColor,
                    ),
                  ),
                ),
                obscureText: _obscureText,
                maxLines: 1,
                controller: _password,
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Container(
            height: 50.0,
            child: RaisedButton(
              child: Text(
                "LOGIN".toUpperCase(),
                style: TextStyle(
                  color: Theming().lightTextColor,
                ),
              ),
              onPressed: loading
                  ? null
                  : () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      var email = _email.text;
                      var password = _password.text;
                      if (email == "" || password == "") {
                        showSnackBar(
                          "Please fill all the details",
                          Colors.red,
                        );
                      } else if (!EmailValidator.validate(email)) {
                        showSnackBar(
                          "Please enter valid email address",
                          Colors.red,
                        );
                      } else {
                        await loginUserWithEmailAndPassword(
                          email,
                          password,
                        );
                      }
                    },
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0),
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Divider(
            color: Theming().dividerColor,
          ),
          SizedBox(
            height: 20.0,
          ),
          // DecoratedBox(
          //   decoration: ShapeDecoration(
          //     shape: RoundedRectangleBorder(
          //       borderRadius: new BorderRadius.circular(
          //         5.0,
          //       ),
          //     ),
          //     color: Colors.blue[800],
          //   ),
          //   child: OutlineButton(
          //     padding: EdgeInsets.symmetric(
          //       vertical: 12.0,
          //       horizontal: 12.0,
          //     ),
          //     onPressed: () async {
          //       print("Login with facebook");
          //       await signInWithFacebook();
          //     },
          //     child: Stack(
          //       children: <Widget>[
          //         Align(
          //           alignment: Alignment.centerLeft,
          //           child: FaIcon(
          //             FontAwesomeIcons.facebookF,
          //           ),
          //         ),
          //         Align(
          //           alignment: Alignment.center,
          //           child: Text(
          //             "LOGIN WITH FACEBOOK",
          //             textAlign: TextAlign.center,
          //           ),
          //         ),
          //       ],
          //     ),
          //     highlightedBorderColor: Colors.blue[800],
          //     color: Colors.blue[800],
          //     borderSide: new BorderSide(
          //       color: Colors.blue[800],
          //     ),
          //     shape: new RoundedRectangleBorder(
          //       borderRadius: new BorderRadius.circular(
          //         5.0,
          //       ),
          //     ),
          //   ),
          // ),
          // SizedBox(
          //   height: 10.0,
          // ),
          DecoratedBox(
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(
                  5.0,
                ),
              ),
              color: Colors.red[800],
            ),
            child: OutlineButton(
              padding: EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 12.0,
              ),
              onPressed: loading
                  ? null
                  : () async {
                      await signInWithGoogle();
                    },
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FaIcon(
                      FontAwesomeIcons.google,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "LOGIN WITH GOOGLE",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              highlightedBorderColor: Colors.red[800],
              color: Colors.red[800],
              borderSide: new BorderSide(
                color: Colors.red[800],
              ),
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(
                  5.0,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          DecoratedBox(
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(
                  5.0,
                ),
              ),
              color: Colors.yellow[800],
            ),
            child: OutlineButton(
              padding: EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 12.0,
              ),
              onPressed: loading
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        new MaterialPageRoute(
                          builder: (context) => MobileOtp(),
                        ),
                      );
                    },
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FaIcon(
                      FontAwesomeIcons.mobileAlt,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "LOGIN WITH OTP",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              highlightedBorderColor: Colors.yellow[800],
              color: Colors.yellow[800],
              borderSide: new BorderSide(
                color: Colors.yellow[800],
              ),
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(
                  5.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
