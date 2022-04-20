import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/dataHandler/appdata.dart';
import 'package:car_rental_app/screens/home_page.dart';
import 'package:car_rental_app/screens/login_page.dart';
import 'package:car_rental_app/services/authentication_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // final FirebaseApp app = await Firebase.initializeApp(
  //   name: 'carrentalapp',
  //   options: Platform.isIOS || Platform.isWindows
  //       ? FirebaseOptions(
  //     appId: '1:297855924061:ios:c6de2b69b03a5be8',
  //     apiKey: 'AIzaSyD_shO5mfO9lhy2TVWhfo1VUmARKlG4suk',
  //     projectId: 'flutter-firebase-plugins',
  //     messagingSenderId: '297855924061',
  //     databaseURL: 'https://flutterfire-cd2f7.firebaseio.com',
  //   )
  //       : FirebaseOptions(
  //       apiKey: "AIzaSyBn2hyZV0aOUOgLj2Cr4yTzrNwhCOXdDXk",
  //       authDomain: "carrentalapp-6bc1f.firebaseapp.com",
  //       projectId: "carrentalapp-6bc1f",
  //       storageBucket: "carrentalapp-6bc1f.appspot.com",
  //       messagingSenderId: "106281468330",
  //       appId: "1:106281468330:web:8fea2c2b60479d6448ebd3",
  //       measurementId: "G-MKVYNRVMF7"
  //   ),
  // );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(FirebaseAuth.instance),
        ),
        ChangeNotifierProvider(
          create: (context) => AppData(),
        ),
        StreamProvider(
          create: (context) =>
          context.read<AuthenticationService>().authStateChanges,
        ),
      ],
      child: MaterialApp(
        title: 'hopOn',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'OpenSans',
          primaryColor: Color.fromRGBO(0, 0, 0, 1),
          // 27, 34, 46
        ),
        home: AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

    if (firebaseUser != null) {
      return HomePage();
    } else {
      return LoginPage();
    }
  }
}
