// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../../../utils/app_colors.dart';
import '../../../utils/size_config.dart';

class NormalInputWidget extends StatefulWidget {
  const NormalInputWidget(
      {super.key,
      this.enable,
      this.controller,
      required this.enableMinLength,
      required this.formatters,
      required this.label,
      required this.hint,
      this.onChanged,
      required this.style,
      required this.inputStyle,
      required this.isPasswordField,
      this.onChangedModel,
      this.keyboardType,
      this.errorText,
      this.valid,
      this.minLength,
      this.counterStyle,
      this.counterText,
      this.errorStyle,
      this.borderRadius,
      this.fillColor,
      this.hoverColor,
      this.suffixWidget,
      this.cursorColor});
  final String label;
  final String? errorText;
  final String hint;
  final TextStyle style;
  final TextStyle inputStyle;
  final bool isPasswordField;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onChangedModel;
  final TextInputType? keyboardType;
  final List<TextInputFormatter> formatters;
  final bool? valid;
  final bool enableMinLength;
  final int? minLength;
  final TextEditingController? controller;
  final bool? enable;
  final TextStyle? counterStyle;
  final String? counterText;
  final TextStyle? errorStyle;
  final BorderRadius? borderRadius;
  final Color? fillColor;
  final Color? hoverColor;
  final Color? cursorColor;
  final Widget? suffixWidget;
  @override
  State<StatefulWidget> createState() {
    return NormalInputWidgetState();
  }
}

class NormalInputWidgetState extends State<NormalInputWidget> {
  TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    setState(() {
      if (widget.controller == null) {
        _controller = TextEditingController();
      } else {
        _controller = widget.controller!;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        FittedBox(
          child: Text(
            widget.label,
            style: widget.style,
          ),
        ),
        Padding(
            padding:
                EdgeInsets.fromLTRB(0, SizeConfig.safeBlockVertical * 2, 0, 0),
            child: TextFormField(
                cursorColor: widget.cursorColor ?? AppColors.whiteColor,
                enabled: widget.enable ?? true,
                enableInteractiveSelection: true,
                validator: (widget.enableMinLength)
                    ? (String? value) {
                        return (value!.length >= widget.minLength!)
                            ? null
                            : widget.errorText;
                      }
                    : (String? value) {
                        return widget.valid! ? null : widget.errorText;
                      },
                textAlign: TextAlign.start,
                inputFormatters: widget.formatters,
                keyboardType: widget.keyboardType,
                obscureText: widget.isPasswordField,
                style: widget.inputStyle,
                onChanged: widget.onChanged ?? widget.onChangedModel,
                controller: _controller,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                    hoverColor: widget.hoverColor,
                    errorStyle: widget.errorStyle,
                    counterText: widget.counterText,
                    counterStyle: widget.counterStyle,
                    contentPadding: EdgeInsets.only(
                        top: SizeConfig.safeBlockVertical * .5,
                        left: SizeConfig.safeBlockVertical * 1),
                    alignLabelWithHint: true,
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          SizeConfig.safeBlockHorizontal * 3),
                    ),
                    hintText: widget.hint,
                    hintStyle: widget.inputStyle,
                    filled: true,
                    fillColor: widget.fillColor ??
                        AppColors.darkGrey.withOpacity(.1),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: AppColors.transparentColor),
                      borderRadius: widget.borderRadius ??
                          BorderRadius.circular(
                              SizeConfig.safeBlockHorizontal * 3),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: AppColors.transparentColor),
                      borderRadius: this.widget.borderRadius ??
                          BorderRadius.circular(
                              SizeConfig.safeBlockHorizontal * 3),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: AppColors.transparentColor),
                      borderRadius: this.widget.borderRadius ??
                          BorderRadius.circular(
                              SizeConfig.safeBlockHorizontal * 3),
                    )))),
      ],
    );
  }
}
