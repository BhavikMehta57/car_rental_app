import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:car_rental_app/globalvariables.dart';
import 'package:car_rental_app/widgets/widgets.dart';

import '../services/firebase_services.dart';
import 'car_details.dart';

class CarList extends StatefulWidget {
  final List<dynamic> carlist;
  final int cost;
  String finalDestination;
  String initialLocation;
  String pickupDate;
  String dropOffDate;
  CarList({this.carlist, this.cost,this.finalDestination, this.initialLocation, this.dropOffDate, this.pickupDate});

  @override
  _CarListState createState() => _CarListState();
}

class _CarListState extends State<CarList> {
  @override
  void initState() {
    super.initState();
    print(widget.carlist);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 245, 242, 1),
      body: ListView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20),
        children: <Widget>[
          CustomBackButton(
            pageHeader: 'Available Cars',
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("vehicles").where("status", isEqualTo: "Available")
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
                        child: Text("No Cars Available"),
                      );
                    }
                    else{
                      return ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsCar(
                                    bookedCar : snapshot.data.docs[index]["vehicleId"],
                                    initialLocation: widget.initialLocation,
                                    finalDestination: widget.finalDestination,
                                    docSnapshot: snapshot.data.docs[index],
                                    rideCost: widget.cost,
                                    pickupDate: widget.pickupDate,
                                    dropOffDate: widget.dropOffDate,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              margin: EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              child: Column(
                                children: <Widget>[
                                  Image.network(snapshot.data.docs[index]['vehicleImg'], height: MediaQuery.of(context).size.height/7,),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            '₹' + snapshot.data.docs[index]["amount"],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                          Text(
                                            snapshot.data.docs[index]['modelName'],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            '₹' + widget.cost.toString(),
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Ride amount',
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.arrow_forward,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  }
                }
            ),
          ),
        ],
      ),
    );
  }
}
