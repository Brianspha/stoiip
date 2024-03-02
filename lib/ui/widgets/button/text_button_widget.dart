// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../utils/size_config.dart';

// Project imports:

class TextButtonWidget extends StatelessWidget {
  const TextButtonWidget(
      {super.key,
      required this.buttonTitle,
      required this.buttonTextFontFamily,
      required this.buttonTextColor,
      required this.onPressed});
  final String buttonTitle, buttonTextFontFamily;
  final Color buttonTextColor;
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: onPressed,
        child: FittedBox(
          child: Text(buttonTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: buttonTextColor,
                  fontSize: SizeConfig().getTextSize(15))),
        ));
  }
}
