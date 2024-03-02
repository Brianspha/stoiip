

import 'package:flutter/cupertino.dart';
import 'package:one_context/one_context.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> navigationKey = OneContext().key;

}