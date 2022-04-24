import 'dart:async';
import 'package:car_rental_app/authentication/web_auth.dart';
import 'package:car_rental_app/screens/home_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:car_rental_app/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

class Otp extends StatefulWidget {
  final String phone;
  final Function onVerificationSuccess;
  final Function onVerificationFailure;
  final Function verifyButtonOnTap;
  Otp({@required this.phone, @required this.onVerificationSuccess, @required this.onVerificationFailure, @required this.verifyButtonOnTap});

  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _auth = FirebaseAuth.instance;
  String phone, verificationId;
  FocusNode firstDigit = FocusNode();
  FocusNode secondDigit = FocusNode();
  FocusNode thirdDigit = FocusNode();
  FocusNode forthDigit = FocusNode();
  bool codeSent = false, isLoading=false;
  TextEditingController _codeController = TextEditingController();
  int _counter = 59;
  Timer _timer;
  var temp;

  void _startTimer() {
    _counter = 59;
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer.periodic(
      Duration(seconds: 1),
          (_timer) {
        setState(() {
          if (_counter > 0) {
            _counter--;
          } else {
            _timer.cancel();
          }
        });
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
    phone = widget.phone;
    print("Send OPT calld form initState of OTP");
    sendOTP();
  }

  sendOTP() async {
    print("Indside Send OPT");
    try {
      if(kIsWeb){
        temp = await FirebaseAuthentication().sendOTP(phone);
        // ConfirmationResult confirmationResult = await _auth.signInWithPhoneNumber(phone, RecaptchaVerifier(
        //   container: '__ff-recaptcha-container',
        //   size: RecaptchaVerifierSize.compact,
        //   theme: RecaptchaVerifierTheme.dark,
        // ));
        // print(confirmationResult);
        // UserCredential userCredential = await confirmationResult.confirm('123456');
        // userCredential.additionalUserInfo.isNewUser
        //     ? print("Successful Authentication")
        //     : print("User already exists");
      }
      else{
        _auth.verifyPhoneNumber(
          phoneNumber: phone,
          timeout: Duration(seconds: 60),
          verificationCompleted: (AuthCredential credential) async {
            print("verification completed call back called from OPT SCREEEN !!!");
            widget.onVerificationSuccess(credential);
          },
          verificationFailed: (FirebaseAuthException exception) {
            print(exception.code);
            print("Verification Failed !! from OTP SCREEN ");
            print(exception);
            widget.onVerificationFailure();
          },
          codeSent: (String verificationId, [int forceResendToken]) {
            this.verificationId = verificationId;
            print(verificationId);
            print("Code Sent !!");
            setState(() {codeSent = true;});
          },
          codeAutoRetrievalTimeout:(val) {
            verificationId = val;
            print("codeAutoRetrievalTimeout\n" + val);
          },
        );}
    } catch (e) {
      print(e);
      final snackBar = SnackBar(
        content: Text('ReCAPTCHA verification failed !'),
        duration: Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.pop(context);
      return;
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: SingleChildScrollView(
          child: Observer(
            builder: (_) => Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // FadeAnimation(
                  //     0.4,
                  //     commonCacheImageWidget(SignLogo, 100,
                  //         width: 100, fit: BoxFit.fill)),
                  // SizedBox(height: 16),
                  Text('Security Code', style: boldTextStyle(size: 18)),
                  16.height,
                  Text(
                    'We have sent the verification code to the phone number you provided.' + "\n$phone\nEnter the OTP after ReCAPTCHA verification.",
                    style: primaryTextStyle(size: 16),
                    textAlign: TextAlign.center,
                  ),
                  // PinEntryTextField(),
                  TextFormField(
                    controller: _codeController,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      _codeController.text = value;
                      _codeController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _codeController.text.length),
                      );
                    },
                  ),
                  16.height,
                  _counter != 0
                      ? Text.rich(
                    TextSpan(
                      text: 'Re-send after',
                      style: secondaryTextStyle(),
                      children: <TextSpan>[
                        TextSpan(
                            text: ' $_counter seconds',
                            style: boldTextStyle(
                                color: Colors.black, size: 14)),
                      ],
                    ),
                  ).center()
                      : Text("Resend OTP").center().onTap(() {
                    //resent OTP
                    _startTimer();
                    verificationId="";
                    setState(() {codeSent = false;});
                    sendOTP();
                  }),
                  16.height,
                  if (isLoading) CircularProgressIndicator() else Padding(
                    padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                    child: GestureDetector(
                      child: CustomButton(
                        text: "Verify",),
                      onTap: () async {
                        final code = _codeController.text.trim();
                        if(code.length != 6){
                          final snackBar = SnackBar(
                            content: Text('Enter Valid OTP !'),
                            duration: Duration(seconds: 3),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          return;
                        }
                        else{
                          /// Verify OTP Manually !
                          setState(() {
                            isLoading=true;
                          });
                          if(kIsWeb){
                            String result = await widget.verifyButtonOnTap(temp.verificationId, code);
                            setState(() {
                              isLoading=false;
                            });

                            if(result != "Success"){
                              final snackBar = SnackBar(
                                content: Text(result),
                                duration: Duration(seconds: 3),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              return;
                            }
                          }
                          else{
                            String result = await widget.verifyButtonOnTap(verificationId, code);
                            setState(() {
                              isLoading=false;
                            });

                            if(result != "Success"){
                              final snackBar = SnackBar(
                                content: Text(result),
                                duration: Duration(seconds: 3),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              return;
                            }
                          }
                        }
                      },
                    ),
                  ),
                ],
              ).paddingAll(16),
            ),
          ),
        ),
      ),
    );
  }
}