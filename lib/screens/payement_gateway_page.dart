import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:nanoid/nanoid.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:toast/toast.dart';
import 'package:car_rental_app/globalvariables.dart';
import 'package:car_rental_app/models/user.dart';
import 'package:car_rental_app/screens/ride_history_page.dart';
import '../services/firebase_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentPage extends StatefulWidget {
  final String amount;
  final AsyncSnapshot<DocumentSnapshot> docSnapshot;
  String finalDestination;
  String initialLocation;
  final String bookedCar;
  final String pickupDate;
  final String dropOffDate;

  PaymentPage(
      {@required this.amount,
      @required this.bookedCar,
      @required this.docSnapshot,
        @required this.finalDestination,
        @required this.initialLocation,
      @required this.pickupDate,
      @required this.dropOffDate});
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  Razorpay razorpay;
  String id;

  @override
  void initState() {
    super.initState();
    razorpay = new Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);

    openCheckOut();
    id = nanoid(10).toString();
  }
  //TODO : Remove RAZORPAY KEY Afterwards
  // rzp_test_l8yCRSz3UfiXKB
  // qKex1KtIwjUAfxYJtZVUUjaw

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    razorpay.clear();
  }

  void handlerPaymentSuccess() {
    Toast.show('Payment Successful', context);
    print('handlerPaymentSuccess');
    // saveUserHistory();
  }

  void saveUserHistory() {
    print("BookedCar :: " + widget.bookedCar);
    print("UID :: " + currentFirebaseUser.uid);
    DatabaseReference dbref = FirebaseDatabase.instance
        .reference()
        .child('user_history/${currentFirebaseUser.phoneNumber}/${widget.bookedCar}');

    Map<String, dynamic> historyMap = {
      'carId': widget.bookedCar,
      'modelName': widget.docSnapshot.data['modelName'],
      'ownerContact': widget.docSnapshot.data['ownerphoneNumber'],
      'color': widget.docSnapshot.data['color'],
      'ownerName': widget.docSnapshot.data['ownerName'],
      'vehicleNumber': widget.docSnapshot.data['vehicleNumber'],
      'amount': widget.amount,
      'pickUp' : widget.initialLocation,
      'dropOff' : widget.finalDestination,
      'pickupDate': widget.pickupDate,
      'dropofDate': widget.dropOffDate,
      'timestamp': DateTime.now().toString(),
    };
    FirebaseFirestore.instance.collection("users").doc(currentFirebaseUser.phoneNumber).collection("UserHistory").doc(id).set(historyMap);
    dbref.set(historyMap).then((value) => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RideHistory(),
          ),
        ));
  }

  void saveOwnerHistory(){

    FirebaseFirestore.instance.
    collection('users').doc(currentFirebaseUser.phoneNumber).
    get().then((value) {
      DatabaseReference dbref = FirebaseDatabase.instance
          .reference()
          .child('owner_history/${widget.bookedCar}/${currentFirebaseUser.phoneNumber}');

      Map<String, dynamic> historyMap = {
        'userName': value.data()['name'],
        'age': value.data()['age'],
        'pickUp' : widget.initialLocation,
        'dropOff' : widget.finalDestination,
        'amount': widget.amount,
        'pickupDate': widget.pickupDate,
        'dropofDate': widget.dropOffDate,
        'timestamp': DateTime.now().toString(),
      };
      dbref.set(historyMap);
      FirebaseFirestore.instance.collection("users").doc(widget.docSnapshot.data['ownerphoneNumber']).collection("OwnerHistory").doc(id).set(historyMap);
    });


    }

  void handlerErrorFailure() {
    Toast.show('Payment Failed', context);
    print('handlerErrorFailure');
  }

  void handlerExternalWallet() {
    print('handlerExternalWallet');
  }

  void openCheckOut() {
    var options = {
      'key': "rzp_test_l8yCRSz3UfiXKB",
      'amount': (int.parse(widget.amount) * 100).toString(),
      'description': 'Your ride',
      "prefill": {
        "contact": '9876543210',
        "email": FirebaseAuth.instance.currentUser.email,
      },
      "external": {
        "wallets": ["paytm"]
      }
    };

    try {
      razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    saveOwnerHistory();
    saveUserHistory();
    return RideHistory();
  }
}
