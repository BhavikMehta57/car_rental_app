import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:car_rental_app/globalvariables.dart';
import 'package:car_rental_app/screens/home_page.dart';
import 'package:car_rental_app/widgets/widgets.dart';

class RideHistory extends StatefulWidget {
  @override
  _RideHistoryState createState() => _RideHistoryState();
}

class _RideHistoryState extends State<RideHistory> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        children: <Widget>[
          CustomBackButton(pageHeader: 'My rides'),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 450,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(25),),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ]
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(FirebaseAuth.instance.currentUser.phoneNumber)
                      .collection("UserHistory")
                      .snapshots()
                  ,
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                    if(!snapshot.hasData){
                      print("Connection state: has no data");
                      return Column(
                        children: [
                          SizedBox(
                            height:MediaQuery.of(context).size.height*0.2,
                          ),
                          CircularProgressIndicator(),
                        ],
                      );
                    }
                    else if(snapshot.connectionState == ConnectionState.waiting){
                      print("Connection state: waiting");
                      return Column(children: [
                        SizedBox(
                          height:MediaQuery.of(context).size.height*0.2,
                        ),
                        CircularProgressIndicator(),
                      ],
                      );
                    }
                    else{
                      print("Connection state: hasdata");
                      if(snapshot.data.docs.length == 0){
                        return Center(
                          child: Text("No Cars Registered Yet"),
                        );
                      }
                      else{
                        return ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              height: 400,
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SpecificationWidget(
                                        text: snapshot.data.docs[index]["modelName"],
                                        helpText: "Your car",
                                      ),
                                      SpecificationWidget(
                                        text: snapshot.data.docs[index]["color"],
                                        helpText: "Car's color",
                                      ),
                                      SpecificationWidget(
                                        text: snapshot.data.docs[index]["vehicleNumber"],
                                        helpText: 'Car number',
                                      ),
                                      SpecificationWidget(
                                        text: snapshot.data.docs[index]["ownerName"],
                                        helpText: 'Owner name',
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 40,
                                  ),
                                  SpecificationWidget(
                                    text: snapshot.data.docs[index]["pickUp"],
                                    helpText: 'Pickup location',
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  SpecificationWidget(
                                    text: snapshot.data.docs[index]["dropOff"],
                                    helpText: 'DropOff location',
                                  ),
                                  SizedBox(
                                    height: 40,
                                  ),
                                  Row(
                                    children: [
                                      Text('From\t\t'),
                                      Text(
                                        snapshot.data.docs[index]["pickupDate"],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      Text('\t\tTo\t\t'),
                                      Text(
                                        snapshot.data.docs[index]["dropofDate"],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Row(
                                    children: [
                                      Text('Amount Paid:\t\t'),
                                      Text(
                                        '₹ ${snapshot.data.docs[index]["amount"]}\t\t\t',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      Icon(Icons.check_circle),
                                      SizedBox(
                                        width: 50,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    }
                  }
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Info extends StatelessWidget {
  final String infoText;
  final String infoData;

  Info({this.infoText, this.infoData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                infoText,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: Text(
                ':',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: Text(
                infoData,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
      ],
    );
  }
}

class SpecificationWidget extends StatelessWidget {
  final String helpText;
  final String text;

  SpecificationWidget({@required this.text, @required this.helpText});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          text,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 6,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Color.fromRGBO(246, 246, 246, 1),
            borderRadius: BorderRadius.all(
              Radius.circular(6),
            ),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              helpText,
              style: TextStyle(fontSize: 10, color: Colors.black54),
            ),
          ),
        ),
      ],
    );
  }
}
