// Flutter imports:
import 'package:flutter/widgets.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  static late double textScaleFactor;

  void init(BuildContext context) {
    //print('context in sizeConfigv2" ${context}');
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
    textScaleFactor = _mediaQueryData.textScaleFactor;
  }

  // Helper methods for responsive sizing
  double getBlockHorizontal(double percent) => blockSizeHorizontal * percent;
  double getBlockVertical(double percent) => blockSizeVertical * percent;
  double getSafeAreaHorizontal(double percent) => _safeAreaHorizontal * percent;
  double getSafeAreaVertical(double percent) => _safeAreaVertical * percent;
  double getTextSize(double fontSize) =>
      _mediaQueryData.textScaler.scale(fontSize);
}
