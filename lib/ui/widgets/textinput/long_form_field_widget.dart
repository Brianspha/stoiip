// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../utils/app_colors.dart';
import '../../../utils/size_config.dart';

// Project imports:

class LongFormFieldWidget extends StatelessWidget {
  const LongFormFieldWidget(
      {super.key,
      required this.style,
      required this.inputStyle,
      required this.onChanged,
      required this.keyboardType,
      this.controller,
      required this.maxCharacters});
  final TextStyle style, inputStyle;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final int maxCharacters;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return TextFormField(
      enableInteractiveSelection: true,
      buildCounter: (BuildContext context_,
              {required int currentLength,
              required bool isFocused,
              required int? maxLength}) =>
          Padding(
        padding: EdgeInsets.only(left: SizeConfig.safeBlockHorizontal * 2),
        child: Text(
          '$currentLength/$maxCharacters',
          style: TextStyle(
              color: AppColors.darkGrey,
              fontSize: SizeConfig().getTextSize(13),
              fontFamily: 'RobotoLight'),
        ),
      ),
      minLines: 1,
      maxLines: 5000,
      style: inputStyle,
      onChanged: onChanged,
      controller: controller,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: SizeConfig.safeBlockHorizontal * 2,
            vertical: SizeConfig.safeBlockVertical * 4,
          ),
          alignLabelWithHint: true,
          disabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(SizeConfig.safeBlockHorizontal * 3),
          ),
          filled: true,
          fillColor: AppColors.darkGrey.withOpacity(.1),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.transparentColor),
            borderRadius:
                BorderRadius.circular(SizeConfig.safeBlockHorizontal * 3),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.transparentColor),
            borderRadius:
                BorderRadius.circular(SizeConfig.safeBlockHorizontal * 3),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.transparentColor),
            borderRadius:
                BorderRadius.circular(SizeConfig.safeBlockHorizontal * 3),
          )),
      keyboardType: TextInputType.multiline,
    );
  }
}
