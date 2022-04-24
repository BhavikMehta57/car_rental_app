import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseAuthentication {
  String phoneNumber = "";

  sendOTP(String phoneNumber) async {
    this.phoneNumber = phoneNumber;
    FirebaseAuth auth = FirebaseAuth.instance;
    ConfirmationResult confirmationResult = await auth.signInWithPhoneNumber(
        '$phoneNumber',
        // RecaptchaVerifier(
        //   container: '__ff-recaptcha-container',
        //   size: RecaptchaVerifierSize.compact,
        //   theme: RecaptchaVerifierTheme.dark,
        // )
    );
    printMessage("OTP Sent to $phoneNumber");
    return confirmationResult;
  }

  authenticateMe(ConfirmationResult confirmationResult, String otp) async {
    UserCredential userCredential = await confirmationResult.confirm(otp);
    print(userCredential.credential);
    userCredential.additionalUserInfo.isNewUser
        ? printMessage("Successful Authentication")
        : printMessage("User already exists");
    return userCredential;
    }

    printMessage(String msg) {
      debugPrint(msg);
    }
}