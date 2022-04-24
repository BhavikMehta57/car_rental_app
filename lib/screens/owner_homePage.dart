import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/globalvariables.dart';
import 'package:car_rental_app/models/user.dart';
import 'package:car_rental_app/services/authentication_service.dart';
import 'package:car_rental_app/services/firebase_services.dart';
import 'package:car_rental_app/widgets/confirmSheet.dart';

import '../widgets/widgets.dart';
import 'car_registration.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'owner_history.dart';
import 'profile_page.dart';

class DisplayMap extends StatefulWidget {
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  _DisplayMapState createState() => _DisplayMapState();
}

class _DisplayMapState extends State<DisplayMap> {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

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

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;

  Position currentPosition;
  AppUser userData;

  DatabaseReference tripRequestRef;
  var locationOptions = LocationOptions(
      accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 4);

  String availabilityText = 'Give on rent';
  Color availabilityColor = Colors.black;
  bool isAvailable = false;
  String exist = 'donotexist';
  Set<Marker> myCars = {};
  
  void setupPositionLocator() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = CameraPosition(target: pos, zoom: 15);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));
  }

  @override
  void initState() {
    getUser();
    setupPositionLocator();
    getMyCars();
    super.initState();
  }

  getUser() async {
    userData = await FirebaseFunctions().getUser();
    // setState(() {
    //   userData;
    // });
  }

  void getMyCars() async {
    await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser.phoneNumber).collection("vehicle_details").get().then((value) {
      for(int i=0;i<value.docs.length;i++){
        Marker carMarker = Marker(
          markerId: MarkerId(value.docs[i].data()['vehicleId']),
          position: LatLng(double.parse(value.docs[i].data()['vehicleLatitude']), double.parse(value.docs[i].data()['vehicleLongitude'])),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        );
        setState(() {
          myCars.add(carMarker);
        });
      }
      print("ZEPTOOO"+myCars.toString());
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: Container(
        width: 250,
        color: Colors.white,
        child: Drawer(
          child: ListView(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return ProfilePage();
                    }),
                  );
                },
                child: Container(
                  height: 165,
                  child: DrawerHeader(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              foregroundColor: Colors.blue,
                              backgroundImage: AssetImage(
                                'images/ToyFaces_Colored_BG_47.jpg',
                              ),
                            ),
                            //TODO 1: User photo should be here
                            SizedBox(width: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FutureBuilder<AppUser>(
                                  future: FirebaseFunctions().getUser(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Text(
                                        snapshot.data.name,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    } else {
                                      return Text('Name');
                                    }
                                  },
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Visit Profile',
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return HomePage();
                  }));
                },
                child: ListTile(
                  leading: Icon(Icons.directions_car_rounded),
                  title: Text(
                    'Rent a car',
                    // style: TextStyle(fontSize: 1),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return VehicleDetails();
                  }));
                },
                child: ListTile(
                  leading: Icon(Icons.card_membership_rounded),
                  title: Text(
                    'Register new car',
                    // style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return OwnerHistory();
                  }));
                },
                child: ListTile(
                  leading: Icon(Icons.history),
                  title: Text(
                    'My Car History',
                    // style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              //Drawer Header

              GestureDetector(
                onTap: () {
                  context.read<AuthenticationService>().signOut(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return LoginPage();
                    }),
                  );
                },
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text(
                    'Sign Out',
                    // style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: 240),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: DisplayMap._kGooglePlex,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            compassEnabled: true,
            markers: myCars,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;
              setupPositionLocator();
            },
          ),

          //Menu button
          Positioned(
            top: 44,
            left: 20,
            child: GestureDetector(
              onTap: () {
                scaffoldKey.currentState.openDrawer();
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5.0,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7))
                    ]),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: Icon(
                    Icons.menu,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ]),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .doc(FirebaseAuth.instance.currentUser.phoneNumber)
                        .collection("vehicle_details")
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
                            scrollDirection: Axis.vertical,
                            itemCount: snapshot.data.docs.length,
                            padding: EdgeInsets.only(
                              left: 5,
                              right: 5,
                            ),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children:[
                                      Container(
                                          decoration: BoxDecoration(
                                            boxShadow: defaultBoxShadow(
                                              shadowColor: shadowColorGlobal,
                                              blurRadius: 0.5,
                                            ),
                                            border: Border.all(color: Colors.transparent),
                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                          ),
                                          padding: EdgeInsets.all(10),
                                          margin: EdgeInsets.only(bottom: 5),
                                          child: Row(
                                            children: [
                                              Image(
                                                image: NetworkImage(snapshot.data.docs[index]["vehicleImg"]),
                                                width: ((MediaQuery.of(context).size.width - 56)/2) * 0.6,
                                                height: ((MediaQuery.of(context).size.width -56)/2) * 0.6,
                                              )
                                                  .cornerRadiusWithClipRRect(5)
                                                  .paddingRight(5),
                                              Expanded(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.max,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text("${snapshot.data.docs[index]["modelName"]}"),
                                                    Text("${snapshot.data.docs[index]["vehicleNumber"]}"),
                                                    Text("${snapshot.data.docs[index]["color"]}"),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  snapshot.data.docs[index]["status"] == "Available"
                                                  ?
                                                      Column(
                                                        children: [
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              color: Colors.green,
                                                              border: Border.all(color: Colors.transparent),
                                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Align(
                                                                alignment: Alignment.center,
                                                                child: Text(
                                                                  'Available',
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(
                                                                    fontSize: 15,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                  :
                                                      Column(
                                                        children: [
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              color: Colors.red,
                                                              border: Border.all(color: Colors.transparent),
                                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Align(
                                                                alignment: Alignment.center,
                                                                child: Text(
                                                                  'Rented',
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(
                                                                    fontSize: 15,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          GestureDetector(
                                                            onTap: () async {
                                                              await FirebaseFirestore.instance.collection("users").doc(currentFirebaseUser.phoneNumber).collection("vehicle_details").doc(snapshot.data.docs[index]["vehicleId"]).update(
                                                                  {
                                                                    'status': "Available"
                                                                  });
                                                              await FirebaseFirestore.instance.collection("vehicles").doc(snapshot.data.docs[index]["vehicleId"]).update(
                                                                  {
                                                                    'status': "Available"
                                                                  });
                                                            },
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                color: Colors.green,
                                                                border: Border.all(color: Colors.transparent),
                                                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(4.0),
                                                                child: Align(
                                                                  alignment: Alignment.center,
                                                                  child: Text(
                                                                    'Rent again',
                                                                    textAlign: TextAlign.center,
                                                                    style: TextStyle(
                                                                      fontSize: 12,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                ],
                                              ),
                                            ],
                                          )
                                      ),
                                    ],
                                  )
                                ],
                              );
                            },
                          );
                        }
                      }
                    }
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Check If Vehicle Info Exists
  Future<void> checkIfDocExists() async {
    try {
      var collectionRef = FirebaseFirestore.instance
          .collection('users/${currentFirebaseUser.phoneNumber}/vehicle_details');

      var doc = await collectionRef.doc(currentFirebaseUser.phoneNumber).get();
      if (doc.exists) {
        exist = 'docexist';
      } else {
        exist = 'Please Register Your Car';
      }
    } catch (e) {
      exist = e;
    }
  }

  void goOnline() {
    print(currentFirebaseUser.uid);
    print("entered");

    Geofire.initialize('carsAvailable');
    Geofire.setLocation(currentFirebaseUser.phoneNumber, currentPosition.latitude,
        currentPosition.longitude);

    tripRequestRef = FirebaseDatabase.instance
        .reference()
        .child('cars/${currentFirebaseUser.phoneNumber}/newTrip');
    tripRequestRef.set('waiting');

    tripRequestRef.onValue.listen((event) {});
  }

  void getLocationUpdates() {
    print("location updates");

    homeTabPositionStream =
        Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      if (isAvailable) {
        Geofire.setLocation(
            currentFirebaseUser.phoneNumber, position.latitude, position.longitude);
      }
      LatLng pos = LatLng(position.latitude, position.longitude);
      CameraPosition cp = new CameraPosition(target: pos, zoom: 15);
      mapController.animateCamera(CameraUpdate.newCameraPosition(cp));
    });
  }

  void goOffline() {
    Geofire.removeLocation(currentFirebaseUser.phoneNumber);
    tripRequestRef.onDisconnect();
    tripRequestRef.remove();
    tripRequestRef = null;
  }
}
