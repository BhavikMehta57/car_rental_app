import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/assistant/request.dart';
import 'package:car_rental_app/configMaps.dart';
import 'package:car_rental_app/dataHandler/appdata.dart';
import 'package:car_rental_app/models/address.dart';
import 'package:car_rental_app/models/placePrediction.dart';
import 'package:car_rental_app/widgets/widgets.dart';

class SearchDropOffLocation extends StatefulWidget {
  @override
  _SearchDropOffLocationState createState() => _SearchDropOffLocationState();
}

class _SearchDropOffLocationState extends State<SearchDropOffLocation> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();

  List<PlacePrediction> placePredictionList = [];

  @override
  Widget build(BuildContext context) {
    String placeAddress = 'Pick Up location';
    pickUpTextEditingController.text = placeAddress;

    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 245, 242, 1),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  CustomBackButton(pageHeader: 'Search Destination'),
                  SizedBox(height: 30),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        onChanged: (val) {
                          findPlace(val);
                        },
                        controller: dropOffTextEditingController,
                        decoration: InputDecoration(
                          labelText: '\tWhere to?',
                        ),
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ),
                  ),

                  //CALENDAR
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            //tile for place prediction
            (placePredictionList.length > 0)
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: ListView.separated(
                      padding: EdgeInsets.all(0),
                      itemBuilder: (context, index) {
                        return PredictionTile(
                          placePrediction: placePredictionList[index],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: EdgeInsets.only(left: 30),
                          child: Divider(),
                        );
                      },
                      itemCount: placePredictionList.length,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                    ),
                  )
                : Container(),

            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  void findPlace(String placeName) async {
    if (placeName.length > 0) {
      String autoCompleteUrl =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$geocodingApi&components=country:in';
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
    }
  }
}

class PredictionTile extends StatelessWidget {
  final PlacePrediction placePrediction;

  PredictionTile({this.placePrediction});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        getPlaceAddressDetails(placePrediction.place_id, context);
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
                        placePrediction.main_text,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        placePrediction.secondary_text,
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

  void getPlaceAddressDetails(String placeId, context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(status: 'Setting Dropoff location\nPlease Wait....'),
    );

    String placeDetailsUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$geocodingApi';

    var res = await RequestAssistant.getRequest(placeDetailsUrl);

    Navigator.pop(context);

    if (res == 'failed') {
      return;
    }

    if (res['status'] == 'OK') {
      Address address = Address();
      address.placeName = res['result']['name'];
      address.placeId = placeId;
      address.latitude = res['result']['geometry']['location']['lat'];
      address.longitude = res['result']['geometry']['location']['lng'];

      Provider.of<AppData>(context, listen: false)
          .updateDropOffLocation(address);
      print('Drop Off Location ::');
      print(address.placeName);

      Navigator.pop(context, 'obtainDirection');
    }
  }
}
