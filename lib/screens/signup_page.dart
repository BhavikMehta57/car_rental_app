import 'package:car_rental_app/authentication/otp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/screens/complete_profile.dart';
import 'package:car_rental_app/screens/login_page.dart';
import 'package:car_rental_app/services/authentication_service.dart';

import '../widgets/widgets.dart';
import 'home_page.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
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

  var phoneController = TextEditingController();

  var passwordController = TextEditingController();

  var confirmPassController = TextEditingController();

  // Future<void> addUserToDatabase() async {
  //   String phone = '+91' + phoneController.text;
  //   await _firestore.collection("users").doc(phone).set({
  //     // "Full Name": fullName,
  //     // "Phone Number": phone,
  //     // "Email": email,
  //     // "Password": password,
  //     // "Profile Url": DefaultProfilPhotoURL,
  //     "Registered On": DateTime.now().toString(),
  //     "isKYC": false,
  //     "isBlocked": false,
  //     "isApproved": true,
  //   });
  // }

  Future<void> processRegisterRequest(context) async {
    String phone = "+91" + phoneController.text;
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
                //Sign In using auth credentials
                final result = await _auth.signInWithCredential(credential);
                print(
                    "Tried logging in with phone auth credentials... from SignUp");
                User user = result.user;

                // Store user details in database
                // await addUserToDatabase();

                if (user != null) {
                  print("User Not Null, Sign In, Redirecting To Home");
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => CompleteProfile(),
                      ),
                          (Route<dynamic> route) => false);
                } else {
                  print("Auth Failed! (Login from SignUp)");
                }
              },
              verifyButtonOnTap:
                  (String verificationId, String enteredCode) async {
                try {
                  final AuthCredential credential =
                  PhoneAuthProvider.credential(
                      verificationId: verificationId, smsCode: enteredCode);

                  final UserCredential userCreds =
                  await _auth.signInWithCredential(credential);
                  final User currentUser = FirebaseAuth.instance.currentUser;

                  print("Adding to firestore");
                  // Store user details in database
                  // await addUserToDatabase();

                  assert(userCreds.user.uid == currentUser.uid);

                  if (userCreds.user != null) {
                    print("User Not Null, Signing In, Redirecting To Home");
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => CompleteProfile(),
                        ),
                            (Route<dynamic> route) => false);
                    return "Success";
                  } else {
                    print("Auth Failed! (Login, from verify callback)");
                    return "Some error occurred!";
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(top: 250),
          child: Column(
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
                    // InputTextField(
                    //   controller: passwordController,
                    //   label: 'Password',
                    //   obscure: true,
                    //   icon: Icon(Icons.lock),
                    // ),
                    // InputTextField(
                    //   controller: confirmPassController,
                    //   label: 'Confirm Password',
                    //   obscure: true,
                    //   icon: Icon(Icons.lock),
                    // ),
                    SizedBox(
                      height: 20,
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
                        if (passwordController.text == confirmPassController.text) {
                          //Check if mobile number is already registered
                          try {
                            DocumentSnapshot ds =
                            await _firestore
                                .collection("users")
                                .doc("+91" + phoneController.text)
                                .get();

                            if (ds.exists) {
                              final snackBar = SnackBar(
                                content: Text(
                                    'User with this mobile already exists !'),
                                duration:
                                Duration(seconds: 3),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                              return;
                            } else {
                              // Process registration
                              await processRegisterRequest(
                                  context);
                            }
                          } catch (e) {
                            print(e);
                            final snackBar = SnackBar(
                              content: Text(
                                  'Some error occurred! Please check you internet connection.'),
                              duration: Duration(seconds: 3),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                            return;
                          }
                        } else {
                          final snackBar = SnackBar(
                            content: Text(
                                'Passwords do not match'),
                            duration: Duration(seconds: 3),
                          );
                          ScaffoldMessenger.of(context)
                              .showSnackBar(snackBar);
                          return;
                        }
                        // BuildContext dialogContext;
                        // showDialog(
                        //   context: context,
                        //   barrierDismissible: false,
                        //   builder: (BuildContext context) {
                        //     dialogContext = context;
                        //     return ProgressDialog(
                        //       status: 'Registering you\nPlease wait',
                        //     );
                        //   },
                        // );

                        // Navigator.pop(dialogContext);
                      },
                      child: CustomButton(
                        text: 'Sign Up',
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
                            return LoginPage();
                          }),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already a registered user?\t',
                            style: TextStyle(fontSize: 10),
                          ),
                          Text(
                            'Login here',
                            style:
                                TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
