import 'package:car_rental_app/screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:nanoid/nanoid.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:toast/toast.dart';
import 'package:car_rental_app/globalvariables.dart';
import 'package:car_rental_app/models/user.dart';
import 'package:car_rental_app/screens/ride_history_page.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import '../services/firebase_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentPage extends StatefulWidget {
  final String amount;
  final QueryDocumentSnapshot docSnapshot;
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
  // Razorpay razorpay;
  String id;

  @override
  void initState() {
    super.initState();
    // razorpay = new Razorpay();
    //
    // razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    // razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    // razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
    //
    // openCheckOut();
    id = nanoid(10).toString();
  }
  //TODO : Remove RAZORPAY KEY Afterwards
  // rzp_test_l8yCRSz3UfiXKB
  // qKex1KtIwjUAfxYJtZVUUjaw

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  // void sendEther() async {
  // Web3Client client = Web3Client(rpcUrl, Client(), socketConnector: (){
  //   return IOWebSocketChannel.connect(wsUrl).cast<String>();
  // });
  //
  // String privateKey = "87eac9cb1b3f2a1d11894e6a66d9e4f06f3cca746f894a87cdf83fba5518c381";
  //
  // Credentials credentials = await client.credentialsFromPrivateKey(privateKey);
  // EthereumAddress receiver = EthereumAddress.fromHex("0xA1b02b776a136f6922b7A91A47089b9ee69eF631");
  // EthereumAddress ownAddress = await credentials.extractAddress();
  //
  // client.sendTransaction(credentials, Transaction(from: ownAddress, to: receiver, value: EtherAmount.fromUnitAndValue(EtherUnit.ether, etherAmount)));
  // }

  // void handlerPaymentSuccess() {
  //   Toast.show('Payment Successful', context);
  //   print('handlerPaymentSuccess');
  //   // saveUserHistory();
  // }

  void saveUserHistory() {
    print("BookedCar :: " + widget.bookedCar);
    print("UID :: " + currentFirebaseUser.uid);
    DatabaseReference dbref = FirebaseDatabase.instance
        .reference()
        .child('user_history/${currentFirebaseUser.phoneNumber}/${widget.bookedCar}');

    Map<String, dynamic> historyMap = {
      'carId': widget.bookedCar,
      'modelName': widget.docSnapshot.data()['modelName'],
      'ownerContact': widget.docSnapshot.data()['ownerphoneNumber'],
      'color': widget.docSnapshot.data()['color'],
      'ownerName': widget.docSnapshot.data()['ownerName'],
      'vehicleNumber': widget.docSnapshot.data()['vehicleNumber'],
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
      FirebaseFirestore.instance.collection("users").doc(widget.docSnapshot.data()['ownerphoneNumber']).collection("OwnerHistory").doc(id).set(historyMap);
    });


    }

  void updateCarStatus(){
    FirebaseFirestore.instance.collection("users").doc(widget.docSnapshot.data()['ownerphoneNumber']).collection("vehicle_details").doc(widget.bookedCar).update(
        {
          'status': "Rented"
        });
    FirebaseFirestore.instance.collection("vehicles").doc(widget.bookedCar).update(
        {
          'status': "Rented"
        });
  }
  // void handlerErrorFailure() {
  //   Toast.show('Payment Failed', context);
  //   print('handlerErrorFailure');
  // }
  //
  // void handlerExternalWallet() {
  //   print('handlerExternalWallet');
  // }
  //
  // void openCheckOut() {
  //   var options = {
  //     'key': "rzp_test_l8yCRSz3UfiXKB",
  //     'amount': (int.parse(widget.amount) * 100).toString(),
  //     'description': 'Your ride',
  //     "prefill": {
  //       "contact": '9876543210',
  //       "email": FirebaseAuth.instance.currentUser.email,
  //     },
  //     "external": {
  //       "wallets": ["paytm"]
  //     }
  //   };
  //
  //   try {
  //     razorpay.open(options);
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    updateCarStatus();
    saveOwnerHistory();
    saveUserHistory();
    return RideHistory();
  }
}
