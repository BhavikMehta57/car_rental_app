import 'dart:io';

import 'package:car_rental_app/assistant/request.dart';
import 'package:car_rental_app/models/placePrediction.dart';
import 'package:car_rental_app/screens/search_dropOff.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:car_rental_app/models/user.dart';
import 'package:car_rental_app/screens/owner_homePage.dart';
import 'package:car_rental_app/services/firebase_services.dart';
import 'package:car_rental_app/services/validation_services.dart';
import 'package:car_rental_app/widgets/widgets.dart';
import 'package:nanoid/nanoid.dart';

import '../configMaps.dart';

class VehicleDetails extends StatefulWidget {
  @override
  _VehicleDetailsState createState() => _VehicleDetailsState();
}

class _VehicleDetailsState extends State<VehicleDetails> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _modelNameController = TextEditingController();
  TextEditingController _vehicleNumberController = TextEditingController();
  TextEditingController _ownerNameController = TextEditingController();
  TextEditingController _colorController = TextEditingController();
  TextEditingController _aadharcardController = TextEditingController();
  TextEditingController _rentAmount = TextEditingController();
  TextEditingController location = TextEditingController();

  String vehicleLoc = "";
  String vehicleLatitude = "";
  String vehicleLongitude = "";

  VehicleUser owner = VehicleUser();
  PlacePrediction vehicleLocation;
  File imageFile;

  List<PlacePrediction> placePredictionList = [];

  Future<void> _pickImage(ImageSource source) async {
    final selected = await ImagePicker().getImage(source: source);
    setState(() {
      imageFile = File(selected.path);
    });
  }

  void _clear() {
    setState(() {
      imageFile = null;
    });
  }

  // _save() async {
  //   FirebaseFunctions().uploadFoodAndImages(owner, imageFile, context);
  // }

  FirebaseFunctions firebaseFunctions = FirebaseFunctions();

  void initVehicleUser() {
    owner.vehicleId = nanoid(8);
    owner.modelName = _modelNameController.text;
    owner.vehicleNumber = _vehicleNumberController.text;
    owner.vehicleLoc = vehicleLoc;
    owner.vehicleLatitude = vehicleLatitude;
    owner.vehicleLongitude = vehicleLongitude;
    owner.ownerName = _ownerNameController.text;
    owner.color = _colorController.text;
    owner.aadharNumber = _aadharcardController.text;
    owner.hasCompletedRegistration = true;
    owner.amount = _rentAmount.text;
    owner.ownerphoneNumber = FirebaseAuth.instance.currentUser.phoneNumber;
    owner.status = "Available";
  }

  void findPlace(String placeName) async {
    if (placeName.length > 0) {
      String autoCompleteUrl = "";
      if(kIsWeb) {
        autoCompleteUrl = 'https://cors-anywhere.herokuapp.com/https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$geocodingApi&components=country:in';
      }
      else{
        autoCompleteUrl = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$geocodingApi&components=country:in';
      }
      var res = await RequestAssistant.getRequest(autoCompleteUrl);

      if (res == 'failed') {
        return;
      }
      if (res['status'] == 'OK') {
        var predictions = res['predictions'];
        var placeList = (predictions as List)
            .map((e) => PlacePrediction.fromJson(e))
            .toList();
        setState(() {
          placePredictionList = placeList;
        });
      }
      print(placePredictionList[0].place_id);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Builder(
        builder: (context) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomBackButton(pageHeader: 'Register your car'),
                    SizedBox(
                      height: 20,
                    ),
                    imageFile != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Container(
                                  width: MediaQuery.of(context).size.width - 20,
                                  height: MediaQuery.of(context).size.height/4,
                                  child: Image.file(
                                    imageFile,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  FlatButton(
                                    child: Icon(Icons.refresh),
                                    onPressed: _clear,
                                  ),
                                ],
                              ),
                            ],
                          )
                        : GestureDetector(
                            onTap: () {
                              _pickImage(ImageSource.gallery);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: 200,
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.directions_car,
                                    size: 80,
                                  ),
                                  Text(
                                    'Choose your car image',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    SizedBox(
                      height: 0,
                    ),
                    InputFormField(
                      fieldName: 'Model Name',
                      obscure: false,
                      validator: ValidationService().modelNameValidator,
                      controller: _modelNameController,
                    ),
                    SizedBox(
                      height: 0.03 * deviceSize.height,
                    ),
                    InputFormField(
                      fieldName: 'Vehicle Number',
                      obscure: false,
                      validator: ValidationService().vehicleNumberValidator,
                      controller: _vehicleNumberController,
                    ),
                    SizedBox(
                      height: 0.03 * deviceSize.height,
                    ),
                    InputFormField(
                      fieldName: 'Owner Name',
                      obscure: false,
                      validator: ValidationService().ownerNameValidator,
                      controller: _ownerNameController,
                    ),
                    SizedBox(
                      height: 0.03 * deviceSize.height,
                    ),
                    InputFormField(
                      fieldName: 'Color',
                      obscure: false,
                      validator: ValidationService().colorValidator,
                      controller: _colorController,
                    ),
                    SizedBox(
                      height: 0.03 * deviceSize.height,
                    ),
                    InputFormField(
                      fieldName: 'Aadhar Number',
                      obscure: false,
                      validator: ValidationService().aadharNumberValidator,
                      controller: _aadharcardController,
                    ),
                    SizedBox(
                      height: 0.03 * deviceSize.height,
                    ),
                    InputFormField(
                      fieldName: 'Rent amount per day',
                      obscure: false,
                      controller: _rentAmount,
                      validator: ValidationService().rentAmountValidator,
                    ),
                    SizedBox(
                      height: 0.03 * deviceSize.height,
                    ),
                    TextField(
                      onChanged: (val) {
                        findPlace(val);
                      },
                      controller: location,
                      decoration: InputDecoration(
                        labelText: '\tSelect Location',
                      ),
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 8.0),
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: placePredictionList.length,
                          scrollDirection: Axis.vertical,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                                  onTap: () {
                                    vehicleLocation = placePredictionList[index];
                                    location.text = vehicleLocation.main_text + " " + vehicleLocation.secondary_text;
                                  },
                                  child: Container(
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          width: 14,
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.add_location),
                                            SizedBox(
                                              width: 14,
                                            ),
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  Text(
                                                    placePredictionList[index].main_text,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(fontSize: 16),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    placePredictionList[index].secondary_text,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                            );
                          }
                      ),
                    ),
                    SizedBox(
                      height: 0.05 * deviceSize.height,
                    ),
                    GestureDetector(
                      onTap: () async {
                        if(_formKey.currentState.validate()){
                          String placeDetailsUrl = "";
                          if (kIsWeb){
                            placeDetailsUrl = 'https://cors-anywhere.herokuapp.com/https://maps.googleapis.com/maps/api/place/details/json?place_id=${vehicleLocation.place_id}&key=$geocodingApi';
                          }
                          else {
                            placeDetailsUrl = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=${vehicleLocation.place_id}&key=$geocodingApi';
                          }
                          var res = await RequestAssistant.getRequest(placeDetailsUrl);
                          if (res == 'failed') {
                            return;
                          }
                          if (res['status'] == 'OK') {
                            vehicleLoc = res['result']['name'];
                            vehicleLatitude = res['result']['geometry']['location']['lat'].toString();
                            vehicleLongitude = res['result']['geometry']['location']['lng'].toString();
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Processing')));
                          initVehicleUser();
                          String isComplete =
                          await firebaseFunctions.uploadVehicleInfo(
                              owner.toMap(), imageFile, context);
                          if (isComplete == 'true') {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return DisplayMap();
                                },
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(isComplete)));
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return VehicleDetails();
                                },
                              ),
                            );
                          }
                        }
                      },
                      child: CustomButton(
                        text: 'Register',
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}