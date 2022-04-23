import 'package:car_rental_app/authentication/otp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/screens/home_page.dart';
import 'package:car_rental_app/screens/signup_page.dart';
import 'package:car_rental_app/services/authentication_service.dart';
import 'package:car_rental_app/widgets/widgets.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  var phoneController = TextEditingController();
  var passwordController = TextEditingController();

  Future<void> loginUser(BuildContext context) async {
    String phone = "+91" + phoneController.text;
    try {
      print("Getting ds...");
      DocumentSnapshot ds =
      await _firestore.collection("users").doc(phone).get();
      print("Got ds...");
      if (!ds.exists) {
        final snackBar = SnackBar(
          content: Text('User does not exist!'),
          duration: Duration(seconds: 3),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      } else {
        String pass = ds.data()["Password"];
        bool isBlocked = ds.data()["isBlocked"];

        if (pass == passwordController.text) {
          //Check user type
          //Prevent Log In if account is blocked
          if (isBlocked) {
            final snackBar = SnackBar(
              content: Text('This account has been blocked'),
              duration: Duration(seconds: 3),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            return;
          }
          // Password is correct, hence send OTP
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return Otp(
                    phone: phone,
                    onVerificationFailure: () {
                      print("OTP Verification Failed");
                      final snackBar = SnackBar(
                        content: Text('OTP verification failed !'),
                        duration: Duration(seconds: 3),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      return;
                    },
                    onVerificationSuccess: (AuthCredential credential) async {
                      print("OTP Verification successful !");
                      final result =
                      await _auth.signInWithCredential(credential);

                      User user = result.user;

                      if (user != null) {
                        print("User Not Null, Loggin In, Redirecing To Home");
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => HomePage(),
                            ),
                                (Route<dynamic> route) => false);
                      } else {
                        print("Auth Failed! (Login)");
                      }
                    },
                    verifyButtonOnTap:
                        (String verificationId, String enteredCode) async {
                      try {
                        final AuthCredential credential =
                        PhoneAuthProvider.credential(
                            verificationId: verificationId,
                            smsCode: enteredCode);

                        final UserCredential userCreds =
                        await _auth.signInWithCredential(credential);
                        final User currentUser =
                            FirebaseAuth.instance.currentUser;

                        assert(userCreds.user.uid == currentUser.uid);

                        if (userCreds.user != null) {
                          print(
                              "User Not Null, Logging In, Redirecing To Home");
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                                  (Route<dynamic> route) => false);
                          return "Success";
                        } else {
                          print("Auth Failed! (Login, from verify callback)");
                          return "Some error occured";
                        }
                      } catch (e) {
                        print("Here is the catched error");
                        print(e);
                        if (e is PlatformException) return (e.code);
                        return "Invalid OTP!";
                      }
                    });
              },
            ),
          );
        } else {
          //Passwords don't match, show error
          final snackBar = SnackBar(
            content: Text('Invalid Credentials !'),
            duration: Duration(seconds: 3),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          return;
        }
      }
    } catch (e) {
      print(e);
      final snackBar = SnackBar(
        content:
        Text('Some error occurred! Please check you internet connection.'),
        duration: Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(top: 250),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Car Rental App',
                  style: TextStyle(
                    fontSize: 30,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'MuseoModerno',
                    // color: Colors.white,
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      InputTextField(
                        controller: phoneController,
                        label: 'Phone Number',
                        obscure: false,
                        icon: Icon(Icons.phone_android_outlined),
                      ),
                      InputTextField(
                        controller: passwordController,
                        label: 'Password',
                        obscure: true,
                        icon: Icon(Icons.lock),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      GestureDetector(
                        onTap: () async {
                          // network connectivity
                          var connectivityResult =
                              await Connectivity().checkConnectivity();
                          if (connectivityResult != ConnectivityResult.mobile &&
                              connectivityResult != ConnectivityResult.wifi) {
                            showSnackBar('No Internet connectivity');
                            return;
                          }

                          if (phoneController.text.length != 10) {
                            showSnackBar(
                                'Please provide a valid phone number');
                          }

                          if (passwordController.text.length < 6) {
                            showSnackBar(
                                'Please provide a password of length more than 6');
                          }
                          BuildContext dialogContext;
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              dialogContext = context;
                              return ProgressDialog(
                                status: 'Sending OTP...',
                              );
                            },
                          );
                          await loginUser(context);
                          Navigator.pop(dialogContext);
                        },
                        child: CustomButton(
                          text: 'Login',
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return SignUpPage();
                            }),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have any account?\t",
                              style: TextStyle(fontSize: 10),
                            ),
                            Text(
                              'SignUp here',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
