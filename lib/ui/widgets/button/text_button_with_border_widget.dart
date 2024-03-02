// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:stosp/ui/widgets/button/text_button_widget.dart';

// Project imports:
import '../../../utils/size_config.dart';

// Project imports:

class TextButtonWithBorderWidget extends StatelessWidget {
  const TextButtonWithBorderWidget(
      {super.key,
      required this.buttonTitle,
      required this.buttonTextFontFamily,
      required this.buttonTextColor,
      required this.onPressed,
      required this.buttonBorderColor,
      required this.width,
      required this.height,
      this.radius = 60.0});
  final String buttonTitle, buttonTextFontFamily;
  final Color buttonTextColor, buttonBorderColor;
  final void Function()? onPressed;
  final double width;
  final double height;
  final double radius;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        border: Border.all(
            color: buttonBorderColor, width: SizeConfig.safeBlockVertical * .1),
        borderRadius: BorderRadius.all(
            Radius.circular(radius) //                 <--- border radius here
            ),
      ),
      child: TextButtonWidget(
        onPressed: onPressed,
        buttonTextColor: buttonTextColor,
        buttonTextFontFamily: buttonTextFontFamily,
        buttonTitle: buttonTitle,
      ),
    );
  }
}
