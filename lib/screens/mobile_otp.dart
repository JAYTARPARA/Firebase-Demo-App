import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasedemo/screens/profile.dart';
import 'package:firebasedemo/theme/theming.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class MobileOtp extends StatefulWidget {
  @override
  _MobileOtpState createState() => _MobileOtpState();
}

class _MobileOtpState extends State<MobileOtp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String countryCode = "+91";
  TextEditingController _mobile = TextEditingController();
  TextEditingController _otp = TextEditingController();
  bool loading = false;
  bool showOTPBox = false;
  bool _enabled = true;
  FirebaseAuth auth = FirebaseAuth.instance;
  String verificationId;
  String otp = "";

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

  @override
  void dispose() {
    super.dispose();
    _mobile.dispose();
    _otp.dispose();
  }

  void _onCountryChange(CountryCode code) {
    setState(() {
      countryCode = code.toString();
    });
    print(countryCode);
  }

  Future<void> verifyPhone() async {
    setState(() {
      loading = true;
    });
    var mobileToSend = countryCode + _mobile.text;
    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      setState(() {
        showOTPBox = true;
        loading = false;
      });
    };
    try {
      await auth.verifyPhoneNumber(
          phoneNumber: mobileToSend,
          codeAutoRetrievalTimeout: (String verId) {
            //Starts the phone number verification process for the given phone number.
            //Either sends an SMS with a 6 digit code to the phone number specified, or sign's the user in and [verificationCompleted] is called.
            this.verificationId = verId;
          },
          codeSent: smsOTPSent,
          timeout: const Duration(
            seconds: 120,
          ),
          verificationCompleted: (AuthCredential phoneAuthCredential) {
            print(phoneAuthCredential);
          },
          verificationFailed: (AuthException exceptio) {
            setState(() {
              loading = false;
            });
            print('${exceptio.message}');
          });
    } catch (e) {
      setState(() {
        loading = false;
      });
      showError(e);
    }
  }

  verifyOTP() async {
    setState(() {
      _enabled = false;
    });
    try {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId,
        smsCode: otp,
      );
      final AuthResult user = await auth.signInWithCredential(credential);
      final FirebaseUser currentUser = await auth.currentUser();
      // assert(user.uid == currentUser.uid);
      print(currentUser.uid);
      if (currentUser.uid != "") {
        // await Common().writeData("method", "phone");
        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) => Profile(),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _enabled = true;
        loading = false;
      });
      showError(e);
    }
  }

  showError(error) {
    print("ERROR");
    print(error.code);
    var errCode = error.code;

    if (errCode == "ERROR_SESSION_EXPIRED") {
      showSnackBar(
        "Session expired, please resend OTP!",
        Colors.red,
      );
    } else if (errCode == "ERROR_INVALID_VERIFICATION_CODE") {
      showSnackBar(
        "You have entered wrong OTP!",
        Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Login with OTP",
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w800,
            color: Theming().lightTextColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
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
            SizedBox(
              height: 30.0,
            ),
            CountryCodePicker(
              textStyle: TextStyle(
                fontFamily: 'Overpass',
              ),
              onChanged: _onCountryChange,
              // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
              initialSelection: '+91',
              favorite: [
                '+91',
                '+1',
              ],
              // optional. Shows only country name and flag
              showCountryOnly: false,
              // optional. Shows only country name and flag when popup is closed.
              showOnlyCountryWhenClosed: false,
              // optional. aligns the flag and the Text left
              alignLeft: false,
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
                  keyboardType: TextInputType.number,
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
              height: 10.0,
            ),
            Container(
              height: 50.0,
              child: RaisedButton(
                child: Text(
                  "SEND OTP".toUpperCase(),
                  style: TextStyle(
                    color: Theming().lightTextColor,
                  ),
                ),
                onPressed: loading
                    ? null
                    : () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        var mobile = _mobile.text;
                        if (mobile == "") {
                          showSnackBar(
                            "Please enter mobile number",
                            Colors.red,
                          );
                        } else {
                          await verifyPhone();
                        }
                      },
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            showOTPBox
                ? Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height / 3,
                          child: FlareActor(
                            "assets/images/otp.flr",
                            animation: "otp",
                            fit: BoxFit.fitHeight,
                            alignment: Alignment.center,
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text("Enter OTP sent to ${countryCode + _mobile.text}"),
                        SizedBox(
                          height: 10.0,
                        ),
                        PinCodeTextField(
                          length: 6,
                          obsecureText: false,
                          animationType: AnimationType.fade,
                          autoFocus: true,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(5),
                            fieldHeight: 50,
                            fieldWidth: 40,
                            activeFillColor: Theme.of(context).primaryColor,
                            activeColor: Theme.of(context).primaryColor,
                            inactiveColor: Colors.green,
                          ),
                          animationDuration: Duration(
                            milliseconds: 300,
                          ),
                          backgroundColor: Colors.transparent,
                          enableActiveFill: false,
                          autoDismissKeyboard: true,
                          textInputType: TextInputType.number,
                          textStyle: TextStyle(
                            color: Theming().lightTextColor,
                          ),
                          // errorAnimationController: errorController,
                          controller: _otp,
                          enabled: _enabled,
                          onCompleted: (v) async {
                            print("Completed");
                            print(v);
                            setState(() {
                              otp = v;
                            });
                            await verifyOTP();
                          },
                          onChanged: (value) {
                            print(value);
                          },
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                      ],
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
