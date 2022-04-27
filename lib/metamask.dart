import 'package:flutter/cupertino.dart';
import 'package:flutter_web3/flutter_web3.dart';

class MetaMaskProvider extends ChangeNotifier {
  static const operatingChain = 1337;
  List accounts = [];
  String currentAddress = '';
  Ethereum ethereum;

  int currentChain = 1337;

  bool get isEnabled => ethereum != null;

  bool get isInOperatingChain => currentChain == operatingChain;

  bool get isConnected => isEnabled && currentAddress.isNotEmpty;

  List get accs => accounts;

  // ignore: non_constant_identifier_names
  Signer get provider_sign => Web3Provider.fromEthereum(ethereum).getSigner();

  Future<void> connect() async {
    if (isEnabled) {
      final accs = await ethereum.requestAccount();
      if (accs.isNotEmpty) currentAddress = accs.first;

      currentChain = await ethereum.getChainId();

      accounts = accs;

      notifyListeners();
    }
  }

  clear() {
    currentAddress = '';
    currentChain = -1;
    notifyListeners();
  }

  init() {
    if (isEnabled) {
      ethereum.onAccountsChanged((accounts) {
        clear();
      });
      ethereum.onChainChanged((accounts) {
        clear();
      });
    }
  }
}