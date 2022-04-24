import 'package:car_rental_app/screens/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:car_rental_app/models/user.dart';
import 'package:car_rental_app/screens/payement_gateway_page.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

import '../widgets/widgets.dart';

class Ganache {
  String rpcUrl = "http://127.0.0.1:7545";
  String wsUrl = "ws://127.0.0.1:7545/";

  void sendEther(etherAmount) async {
    Web3Client client = Web3Client(rpcUrl, Client(), socketConnector: (){
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });

    String privateKey = "87eac9cb1b3f2a1d11894e6a66d9e4f06f3cca746f894a87cdf83fba5518c381";

    Credentials credentials = await client.credentialsFromPrivateKey(privateKey);
    EthereumAddress receiver = EthereumAddress.fromHex("0xA1b02b776a136f6922b7A91A47089b9ee69eF631");
    EthereumAddress ownAddress = await credentials.extractAddress();
    print(ownAddress);
    client.sendTransaction(credentials, Transaction(from: ownAddress, to: receiver, value: EtherAmount.fromUnitAndValue(EtherUnit.ether, BigInt.from(etherAmount))));
  }

}
