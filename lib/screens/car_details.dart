import 'package:car_rental_app/ganache/sendEther.dart';
import 'package:car_rental_app/metamask.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:car_rental_app/models/user.dart';
import 'package:car_rental_app/screens/payement_gateway_page.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

import '../widgets/widgets.dart';

class DetailsCar extends StatefulWidget {
  final QueryDocumentSnapshot docSnapshot;
  final String bookedCar;
  String finalDestination;
  String initialLocation;
  final int rideCost;
  final String pickupDate;
  final String dropOffDate;
  DetailsCar(
      {@required this.docSnapshot,
      @required this.bookedCar,
      @required this.finalDestination,
      @required this.initialLocation,
      @required this.rideCost,
      @required this.pickupDate,
      @required this.dropOffDate});

  @override
  _DetailsCarState createState() => _DetailsCarState();
}

var totalCost;

class _DetailsCarState extends State<DetailsCar> {

  double etherAmount = 0;
  String text="";

  @override
  void initState() {
    // TODO: implement initState
    etherAmount = double.parse((widget.rideCost + (int.parse(widget.docSnapshot.data()['amount']))).toString())/236474;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(235, 235, 240, 1),
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(40),
                  bottomLeft: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomBackButton(
                      pageHeader: '',
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      widget.docSnapshot.data()['modelName'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    Text(
                      widget.docSnapshot.data()['ownerName'].toUpperCase(),
                      style: TextStyle(
                        color: Color.fromRGBO(27, 34, 46, 1),
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Image.network(
                      widget.docSnapshot.data()['vehicleImg'],
                      width: MediaQuery.of(context).size.width,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SPECIFICATIONS',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SpecificationWidget(
                        text: '₹ ' + widget.docSnapshot.data()['amount'],
                        helpText: 'Car rent',
                      ),
                      SpecificationWidget(
                        text: '₹ ' + widget.rideCost.toString(),
                        helpText: 'Your ride cost',
                      ),
                      SpecificationWidget(
                        text: '₹ ' +
                            (widget.rideCost +
                                    (int.parse(widget.docSnapshot.data()['amount'])))
                                .toString(),
                        helpText: 'Total cost',
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SpecificationWidget(
                        text: widget.docSnapshot.data()['color'],
                        helpText: "Car's Color",
                      ),
                      SpecificationWidget(
                        text: widget.pickupDate,
                        helpText: 'Pickup date',
                      ),
                      SpecificationWidget(
                        text: widget.dropOffDate,
                        helpText: 'DropOff date',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
            ),
            ChangeNotifierProvider(
              create: (context) => MetaMaskProvider()..init(),
              builder: (context, child) {
                return Center(
                    child: Consumer<MetaMaskProvider>(
                      builder: (context, provider, child) {
                        if (provider.isConnected && provider.isInOperatingChain) {
                          text = 'Connected';
                          return Padding(
                            padding: EdgeInsets.all(20.0),
                            child: GestureDetector(
                              onTap: () async {
                                print(etherAmount);
                                print("Owner ${provider.accs[0]}");
                                final tx = await provider.provider_sign.sendTransaction(
                                  TransactionRequest(
                                    to: '0x4BC0BB1F6F0bC9cC024C8889C5a6015493FecE7e',
                                    value: BigInt.from(1),
                                  ),
                                );
                                tx.hash;
                                final receipt = await tx.wait();

                                print("Transaction: ${tx.blockHash}, ${tx.data}");
                                print(receipt.blockHash);
                                // Ganache().sendEther(etherAmount);
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => PaymentPage(
                                //       docSnapshot: widget.docSnapshot,
                                //       initialLocation: widget.initialLocation,
                                //       finalDestination: widget.finalDestination,
                                //       bookedCar: widget.bookedCar,
                                //       amount: (widget.rideCost +
                                //               (int.parse(widget.docSnapshot.data()['amount'])))
                                //           .toString(),
                                //       pickupDate: widget.pickupDate,
                                //       dropOffDate: widget.dropOffDate,
                                //     ),
                                //   ),
                                // );

                              },
                              child: CustomButton(
                                text: 'Pay',
                              ),
                            ),
                          );
                        } else if (provider.isConnected && !provider.isInOperatingChain) {
                          text = 'Wrong chain. Please connect to ${MetaMaskProvider.operatingChain}';
                        } else if (provider.isEnabled) {
                          return Padding(
                            padding: EdgeInsets.all(20.0),
                            child: GestureDetector(
                              onTap: () {
                                context.read<MetaMaskProvider>().connect();
                              },
                              child: CustomButton(
                                text: 'Connect to Metamask',
                              ),
                            ),
                          );
                        } else {
                          text = 'Please use a Web3 supported browser.';
                        }
                        return Container(
                          child: Text(
                            text,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline5,
                          ),
                        );
                      },
                    ),
                );
              },
            ),
          ],
        ),
      ),
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

class Data extends StatelessWidget {
  final String carTitle;
  final String carInfo;

  Data({this.carTitle, this.carInfo});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.arrow_forward_ios_rounded),
      title: Row(
        children: [
          Text(
            carTitle,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          SizedBox(
            width: 3,
          ),
          Text(
            carInfo,
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}
