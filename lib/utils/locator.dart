// Dart imports:

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter_web3/ethereum.dart';
import 'package:flutter_web3/ethers.dart';

// Package imports:
import 'package:get_it/get_it.dart';
import 'package:stosp/ui/viewmodels/chat/chat_viewmodel.dart';
import 'package:stosp/ui/viewmodels/ip/ip_viewmodel.dart';

import '../services/data/chainsafe.dart';
import 'app_navigator.dart';
import 'constants.dart';

GetIt locator = GetIt.asNewInstance();

void setupLocator() {
  try {
    final chatViewModel = ChatViewModelImpl();
    chatViewModel.initialiseChat();
    locator.registerSingleton<ChatViewModel>(chatViewModel, signalsReady: true);
    locator.registerSingleton<ChainSafeService>(ChainSafeService(),
        signalsReady: true);
    locator.registerSingleton<AppNavigator>(AppNavigator(), signalsReady: true);
  } catch (error) {
    debugPrint("error in locator: ${error}");
  }
}
