import 'dart:convert';
import 'dart:js';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flexible_grid_view/flexible_grid_view.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:stosp/ui/viewmodels/chat/chat_viewmodel.dart';
import 'package:stosp/utils/size_config.dart';
import 'package:url_launcher/url_launcher.dart';
import '../ui/widgets/button/text_button_with_border_widget.dart';
import '../ui/widgets/textinput/long_form_field_widget.dart';
import '../ui/widgets/textinput/normal_input_widget.dart';
import 'app_colors.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'app_navigator.dart';
import 'constants.dart';
import 'locator.dart';

Widget loadCustomMessageWidget({required types.CustomMessage message}) {
  switch (message.id) {
    case "Creating IP":
      return _loadIPCreatedWidget(message: message);
    case "IP Creator":
      return _loadIPCreatorWidget(message: message);
    case "Select Image/Video":
      return _loadFilePickerWidget(message: message);
    case "IP Created":
      return _loadCreateIPLoadingWidget(message: message);
    case "Start":
      return _loadStart(message: message);
    case "ConnectWallet":
      return _loadConnectWallet(message: message);
    case "error":
      return _loadErrorWidget(message: message);
    case "loading":
      return _loadFetchingWidget(message: message);
    case "viewIPS":
      return _loadViewIPsWidget(message: message);
    default:
      return _loadMediaSourceWidget(message: message);
  }
}

Widget _loadFetchingWidget({required types.CustomMessage message}) {
  return Lottie.asset(
    'assets/animations/loading.json',
    onLoaded: (composition) {
      // Configure the AnimationController with the duration of the
      // Lottie file and start the animation.
    },
  );
}

Widget _loadViewIPsWidget({required types.CustomMessage message}) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.lightGrey,
      border: Border.all(
        color: AppColors.darkGrey.withOpacity(0.1),
      ),
      borderRadius: const BorderRadius.all(Radius.circular(20)),
    ),
    width: SizeConfig.safeBlockHorizontal * 100,
    height: SizeConfig.safeBlockVertical * 100,
    child: Column(
      children: [
        SizedBox(
          width: SizeConfig.safeBlockHorizontal * 90,
          height: SizeConfig.safeBlockVertical * 90,
          child: GridView.count(
            primary: false,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
            children: List.generate(
                locator.get<ChatViewModel>().chatViewModelState.ownedIPs.length,
                (index) => Container(
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        border: Border.all(
                          color: AppColors.darkGrey.withOpacity(0.1),
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                      ),
                      width: SizeConfig.safeBlockHorizontal * 100,
                      height: SizeConfig.safeBlockVertical * 100,
                      child: Column(
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                color: AppColors.lightGrey,
                                border: Border.all(
                                  color: AppColors.darkGrey.withOpacity(0.1),
                                ),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Image(
                                image: CachedNetworkImageProvider(locator
                                    .get<ChatViewModel>()
                                    .chatViewModelState
                                    .ownedIPs[index]
                                    .url),
                              ),
                              clipBehavior: Clip.antiAliasWithSaveLayer),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: SizeConfig.safeBlockVertical * 1,
                              horizontal: SizeConfig.safeBlockHorizontal * 1,
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      right:
                                          SizeConfig.safeBlockHorizontal * 1),
                                  child: const Icon(Icons.book),
                                ),
                                Text(
                                  locator
                                      .get<ChatViewModel>()
                                      .chatViewModelState
                                      .ownedIPs[index]
                                      .name,
                                  style: TextStyle(
                                      fontSize: SizeConfig().getTextSize(11),
                                      fontFamily: "RobotoRegular"),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: SizeConfig.safeBlockVertical * 1,
                              horizontal: SizeConfig.safeBlockHorizontal * 1,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Description",
                                    style: TextStyle(
                                        fontSize: SizeConfig().getTextSize(11),
                                        fontFamily: "RobotoRegular")),
                                Text(
                                    locator
                                        .get<ChatViewModel>()
                                        .chatViewModelState
                                        .ownedIPs[index]
                                        .description,
                                    style: TextStyle(
                                        fontSize: SizeConfig().getTextSize(11),
                                        fontFamily: "RobotoRegular"))
                              ],
                            ),
                          ),

                          // Other widgets remain the same
                        ],
                      ),
                    )),
          ),
        ),
        Expanded(
            child: Padding(
          padding:
              EdgeInsets.symmetric(vertical: SizeConfig.safeBlockVertical * 2),
          child: TextButtonWithBorderWidget(
            onPressed: () {
              locator.get<ChatViewModel>().createWidget();
            },
            buttonTitle:
                locator.get<ChatViewModel>().chatViewModelState.generating
                    ? "Creating Widget"
                    : "Create Widget",
            buttonTextFontFamily: 'RobotoRegular',
            buttonTextColor: AppColors.darkGrey,
            buttonBorderColor: AppColors.primaryColor,
            width: SizeConfig.safeBlockHorizontal * 8,
            height: SizeConfig.safeBlockVertical * 5,
          ),
        ))
      ],
    ),
  );
}

Widget _loadConnectWallet({required types.CustomMessage message}) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.lightGrey,
      border: Border.all(
        color: AppColors.darkGrey.withOpacity(0.1),
      ),
      borderRadius: const BorderRadius.all(Radius.circular(20)),
    ),
    width: SizeConfig.safeBlockHorizontal * 40,
    height: SizeConfig.safeBlockVertical * 11,
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: SizeConfig.safeBlockVertical * 2),
          child: Text(
            "Please connect your metamask",
            style: TextStyle(fontSize: SizeConfig().getTextSize(13)),
          ),
        ),
        Expanded(
            child: Padding(
          padding: EdgeInsets.only(bottom: SizeConfig.safeBlockVertical * 1),
          child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                      AppNavigator.navigationKey.currentState!.context)
                  .copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                },
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: SizeConfig.safeBlockHorizontal * 0.5),
                  child: TextButtonWithBorderWidget(
                    onPressed: () {
                      locator.get<ChatViewModel>().connectWallet();
                    },
                    buttonTitle: locator
                                .get<ChatViewModel>()
                                .chatViewModelState
                                .generating &&
                            !locator
                                .get<ChatViewModel>()
                                .chatViewModelState
                                .user
                                .connected
                        ? "Connecting Wallet"
                        : "Connect Wallet",
                    buttonTextFontFamily: 'RobotoRegular',
                    buttonTextColor: AppColors.darkGrey,
                    buttonBorderColor: AppColors.primaryColor,
                    width: SizeConfig.safeBlockHorizontal * 8,
                    height: SizeConfig.safeBlockVertical * 5,
                  ),
                ),
              )),
        ))
      ],
    ),
  );
}

Widget _loadStart({required types.CustomMessage message}) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.lightGrey,
      border: Border.all(
        color: AppColors.darkGrey.withOpacity(0.1),
      ),
      borderRadius: const BorderRadius.all(Radius.circular(20)),
    ),
    width: SizeConfig.safeBlockHorizontal * 40,
    height: SizeConfig.safeBlockVertical * 11,
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: SizeConfig.safeBlockVertical * 2),
          child: Text(
            "What would you like to do?",
            style: TextStyle(fontSize: SizeConfig().getTextSize(13)),
          ),
        ),
        Expanded(
            child: Padding(
          padding: EdgeInsets.only(bottom: SizeConfig.safeBlockVertical * 1),
          child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                      AppNavigator.navigationKey.currentState!.context)
                  .copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                },
              ),
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: SizeConfig.safeBlockHorizontal * 0.5),
                      child: TextButtonWithBorderWidget(
                        onPressed: () {
                          locator.get<ChatViewModel>().viewAllIPs();
                        },
                        buttonTitle: "View All IPs",
                        buttonTextFontFamily: 'RobotoRegular',
                        buttonTextColor: AppColors.darkGrey,
                        buttonBorderColor: AppColors.primaryColor,
                        width: SizeConfig.safeBlockHorizontal * 8,
                        height: SizeConfig.safeBlockVertical * 5,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: SizeConfig.safeBlockHorizontal * 0.5),
                      child: TextButtonWithBorderWidget(
                        onPressed: () {
                          locator.get<ChatViewModel>().issueNewIP();
                        },
                        buttonTitle: "Issue new IP",
                        buttonTextFontFamily: 'RobotoRegular',
                        buttonTextColor: AppColors.darkGrey,
                        buttonBorderColor: AppColors.primaryColor,
                        width: SizeConfig.safeBlockHorizontal * 8,
                        height: SizeConfig.safeBlockVertical * 5,
                      ),
                    ),
                  ],
                ),
              )),
        ))
      ],
    ),
  );
}

Widget _loadIPCreatedWidget({required types.CustomMessage message}) {
  return Lottie.asset(
    'assets/animations/creating.json',
    onLoaded: (composition) {
      // Configure the AnimationController with the duration of the
      // Lottie file and start the animation.
    },
  );
}

Widget _loadErrorWidget({required types.CustomMessage message}) {
  return Lottie.asset(
    'assets/animations/sad.json',
    onLoaded: (composition) {
      // Configure the AnimationController with the duration of the
      // Lottie file and start the animation.
    },
  );
}

Widget _loadCreateIPLoadingWidget({required types.CustomMessage message}) {
  final metadata =
      locator.get<ChatViewModel>().chatViewModelState.ipCreatedResults;
  return Container(
    decoration: BoxDecoration(
      color: AppColors.lightGrey,
      border: Border.all(
        color: AppColors.darkGrey.withOpacity(0.1),
      ),
      borderRadius: const BorderRadius.all(Radius.circular(20)),
    ),
    width: SizeConfig.safeBlockHorizontal * 100,
    height: SizeConfig.safeBlockVertical * 15,
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: SizeConfig.safeBlockVertical * 2,
            left: SizeConfig.safeBlockHorizontal * 2.5,
            right: SizeConfig.safeBlockHorizontal * 2.5,
          ),
          child: Text(
            metadata.status
                ? "IP Created Successfully"
                : "Something went wrong",
            style: TextStyle(fontSize: SizeConfig().getTextSize(13)),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: SizeConfig.safeBlockVertical * 1,
            left: SizeConfig.safeBlockHorizontal * 2.5,
            right: SizeConfig.safeBlockHorizontal * 2.5,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Transaction hash",
                style: TextStyle(fontSize: SizeConfig().getTextSize(10)),
              ),
              Padding(
                padding:
                    EdgeInsets.only(right: SizeConfig.safeBlockHorizontal * 1),
                child: GestureDetector(
                  child: RichText(
                      text: TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              if (!await launchUrl(
                                  Uri.parse(
                                      'https://etherscan.io/tx/${metadata.transactionHash}'),
                                  mode: LaunchMode.inAppBrowserView)) {
                                throw Exception(
                                    'Could not launch ${'https://etherscan.io/tx/${metadata.transactionHash}'}');
                              }
                            },
                          style: TextStyle(
                              fontSize: SizeConfig().getTextSize(10),
                              color: AppColors.complementaryBlue),
                          children: <TextSpan>[
                        TextSpan(
                            text:
                                'https://etherscan.io/tx/${metadata.transactionHash}'),
                      ])),
                  onTap: () async {
                    if (!await launchUrl(
                        Uri.parse(
                            'https://etherscan.io/tx/${metadata.transactionHash}'),
                        mode: LaunchMode.inAppBrowserView)) {
                      throw Exception(
                          'Could not launch ${'https://etherscan.io/tx/${metadata.transactionHash}'}');
                    }
                  },
                ),
              )
            ],
          ),
        ),
        // Other Padding widgets for input fields remain the same
      ],
    ),
  );
}

Widget _loadIPCreatorWidget({required types.CustomMessage message}) {
  final formKey = GlobalKey<FormState>();
  return Container(
    decoration: BoxDecoration(
      color: AppColors.lightGrey,
      border: Border.all(
        color: AppColors.darkGrey.withOpacity(0.1),
      ),
      borderRadius: const BorderRadius.all(Radius.circular(20)),
    ),
    width: SizeConfig.safeBlockHorizontal * 100,
    height: locator
            .get<ChatViewModel>()
            .chatViewModelState
            .ipDescriptionController
            .text
            .isEmpty
        ? SizeConfig.safeBlockVertical * 110
        : SizeConfig.safeBlockVertical * 120,
    child: Form(
      key: formKey,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: SizeConfig.safeBlockVertical * 2,
              left: SizeConfig.safeBlockHorizontal * 2.5,
              right: SizeConfig.safeBlockHorizontal * 2.5,
            ),
            child: Text(
              message.id,
              style: TextStyle(fontSize: SizeConfig().getTextSize(13)),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: SizeConfig.safeBlockVertical * 1,
              left: SizeConfig.safeBlockHorizontal * 2.5,
              right: SizeConfig.safeBlockHorizontal * 2.5,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: SizeConfig.safeBlockVertical * 15,
                  height: SizeConfig.safeBlockVertical * 15,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    // Make sure to replace `path` with a Uint8List of image data
                    child: Image.memory(locator
                        .get<ChatViewModel>()
                        .chatViewModelState
                        .currentFile
                        .path), // Replace with actual image data
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: SizeConfig.safeBlockVertical * 1,
                    bottom: SizeConfig.safeBlockVertical * 1,
                  ),
                  child: NormalInputWidget(
                    errorStyle: TextStyle(
                        color: AppColors.accentColorRed,
                        fontSize: SizeConfig.textScaleFactor * 8,
                        fontFamily: 'RobotoRegular'),
                    errorText: locator
                                .get<ChatViewModel>()
                                .chatViewModelState
                                .ipNameController
                                .text
                                .isNotEmpty &&
                            locator
                                    .get<ChatViewModel>()
                                    .chatViewModelState
                                    .ipNameController
                                    .text
                                    .length >
                                5 &&
                            locator
                                    .get<ChatViewModel>()
                                    .chatViewModelState
                                    .ipNameController
                                    .text
                                    .length <=
                                50
                        ? ''
                        : 'Name must be less than 50 characters and greater than 5',
                    valid: locator
                            .get<ChatViewModel>()
                            .chatViewModelState
                            .ipNameController
                            .text
                            .isNotEmpty &&
                        locator
                                .get<ChatViewModel>()
                                .chatViewModelState
                                .ipNameController
                                .text
                                .length >
                            5 &&
                        locator
                                .get<ChatViewModel>()
                                .chatViewModelState
                                .ipNameController
                                .text
                                .length <=
                            50,
                    controller: locator
                        .get<ChatViewModel>()
                        .chatViewModelState
                        .ipNameController,
                    keyboardType: TextInputType.text,
                    formatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.singleLineFormatter,
                    ],
                    onChanged: (String value) {
                      // locator.get<ChatViewModel>().updateIPName(value: value);
                    },
                    isPasswordField: false,
                    label: "IP Name",
                    style: TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: SizeConfig().getTextSize(13),
                        fontFamily: 'RobotoLight'),
                    inputStyle: TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: SizeConfig().getTextSize(13),
                        fontFamily: 'RobotoLight'),
                    minLength: 50,
                    enableMinLength: true,
                    hint: '',
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: SizeConfig.safeBlockVertical * 1,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: SizeConfig.safeBlockVertical * 2),
                        child: Text(
                          "IP Description",
                          style: TextStyle(
                              color: AppColors.darkGrey,
                              fontSize: SizeConfig().getTextSize(13),
                              fontFamily: 'RobotoLight'),
                        ),
                      ),
                      SizedBox(
                        width: SizeConfig.safeBlockHorizontal * 100,
                        child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: LongFormFieldWidget(
                              controller: locator
                                  .get<ChatViewModel>()
                                  .chatViewModelState
                                  .ipDescriptionController,
                              maxCharacters: 10000,
                              keyboardType: TextInputType.multiline,
                              onChanged: (String value) {},
                              style: TextStyle(
                                  color: AppColors.darkGrey,
                                  fontSize: SizeConfig.textScaleFactor * 13,
                                  fontFamily: 'RobotoLight'),
                              inputStyle: TextStyle(
                                  color: AppColors.darkGrey,
                                  fontSize: SizeConfig.textScaleFactor * 13,
                                  fontFamily: 'RobotoLight'),
                            )),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: SizeConfig.safeBlockVertical * 1,
                    bottom: SizeConfig.safeBlockVertical * 1,
                  ),
                  child: NormalInputWidget(
                    valid: true,
                    controller: locator
                        .get<ChatViewModel>()
                        .chatViewModelState
                        .keywordsController,
                    keyboardType: TextInputType.text,
                    formatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.singleLineFormatter,
                    ],
                    onChanged: (String value) {
                      //locator.get<ChatViewModel>().updateKeyword(value: value);
                    },
                    isPasswordField: false,
                    label: "Keywords",
                    style: TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: SizeConfig().getTextSize(13),
                        fontFamily: 'RobotoLight'),
                    inputStyle: TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: SizeConfig().getTextSize(13),
                        fontFamily: 'RobotoLight'),
                    minLength: 50,
                    enableMinLength: true,
                    hint:
                        'Enter Keywords to be used by Gemini separated by a comma',
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: SizeConfig.safeBlockVertical * 1,
                  ),
                  child: TextButtonWithBorderWidget(
                    onPressed: () {
                      if (!locator
                          .get<ChatViewModel>()
                          .chatViewModelState
                          .generating) {
                        locator.get<ChatViewModel>().generateDescription();
                      }
                    },
                    buttonTitle: locator
                            .get<ChatViewModel>()
                            .chatViewModelState
                            .generating
                        ? "Generating"
                        : "Generate Description",
                    buttonTextFontFamily: 'RobotoRegular',
                    buttonTextColor: AppColors.darkGrey,
                    buttonBorderColor: AppColors.primaryColor,
                    width: SizeConfig.safeBlockHorizontal * 100,
                    height: SizeConfig.safeBlockVertical * 5,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: SizeConfig.safeBlockVertical * 1,
                  ),
                  child: TextButtonWithBorderWidget(
                    onPressed: () {
                      debugPrint(
                          "formKey.currentState!.validate(): ${!locator.get<ChatViewModel>().chatViewModelState.generating && locator.get<ChatViewModel>().chatViewModelState.ipDescriptionController.text.isNotEmpty && locator.get<ChatViewModel>().chatViewModelState.ipNameController.text.isNotEmpty}");
                      if (!locator
                              .get<ChatViewModel>()
                              .chatViewModelState
                              .generating &&
                          locator
                              .get<ChatViewModel>()
                              .chatViewModelState
                              .ipDescriptionController
                              .text
                              .isNotEmpty &&
                          locator
                              .get<ChatViewModel>()
                              .chatViewModelState
                              .ipNameController
                              .text
                              .isNotEmpty) {
                        locator.get<ChatViewModel>().onCreateIP();
                      }
                    },
                    buttonTitle: "Continue",
                    buttonTextFontFamily: 'RobotoRegular',
                    buttonTextColor: AppColors.darkGrey,
                    buttonBorderColor: AppColors.primaryColor,
                    width: SizeConfig.safeBlockHorizontal * 100,
                    height: SizeConfig.safeBlockVertical * 5,
                  ),
                )
                // Other widgets remain the same
              ],
            ),
          ),
          // Other Padding widgets for input fields remain the same
        ],
      ),
    ),
  );
}

Widget _loadFilePickerWidget({required types.CustomMessage message}) {
  return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        border: Border.all(
          color: AppColors.darkGrey.withOpacity(0.1),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      width: SizeConfig.safeBlockHorizontal * 40,
      height: SizeConfig.safeBlockVertical * 15,
      child: Column(children: [
        Padding(
          padding: EdgeInsets.only(bottom: SizeConfig.safeBlockVertical * 2),
          child: Text(
            message.id,
            style: TextStyle(fontSize: SizeConfig().getTextSize(13)),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: SizeConfig.safeBlockVertical * 1),
          child: TextButtonWithBorderWidget(
            onPressed: () {
              locator.get<ChatViewModel>().handleAttachmentPressed(
                  context: AppNavigator.navigationKey.currentState!.context!);
            },
            buttonTitle: "Select File",
            buttonTextFontFamily: 'RobotoRegular',
            buttonTextColor: AppColors.darkGrey,
            buttonBorderColor: AppColors.primaryColor,
            width: SizeConfig.safeBlockHorizontal * 8,
            height: SizeConfig.safeBlockVertical * 5,
          ),
        )
      ]));
}

Widget _loadMediaSourceWidget({required types.CustomMessage message}) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.lightGrey,
      border: Border.all(
        color: AppColors.darkGrey.withOpacity(0.1),
      ),
      borderRadius: const BorderRadius.all(Radius.circular(20)),
    ),
    width: SizeConfig.safeBlockHorizontal * 40,
    height: SizeConfig.safeBlockVertical * 11,
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: SizeConfig.safeBlockVertical * 2),
          child: Text(
            message.id,
            style: TextStyle(fontSize: SizeConfig().getTextSize(13)),
          ),
        ),
        Expanded(
            child: Padding(
          padding: EdgeInsets.only(bottom: SizeConfig.safeBlockVertical * 1),
          child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                      AppNavigator.navigationKey.currentState!.context)
                  .copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                },
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: SizeConfig.safeBlockHorizontal * 0.5),
                    child: TextButtonWithBorderWidget(
                      onPressed: () {
                        locator
                            .get<ChatViewModel>()
                            .updateCurrentResponse(response: Source.gallery);
                      },
                      buttonTitle: "From Gallery",
                      buttonTextFontFamily: 'RobotoRegular',
                      buttonTextColor: AppColors.darkGrey,
                      buttonBorderColor: AppColors.primaryColor,
                      width: SizeConfig.safeBlockHorizontal * 8,
                      height: SizeConfig.safeBlockVertical * 5,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: SizeConfig.safeBlockHorizontal * 0.5),
                    child: TextButtonWithBorderWidget(
                      onPressed: () {
                        locator.get<ChatViewModel>().updateCurrentResponse(
                              response: Source.youtube,
                            );
                      },
                      buttonTitle: "From Youtube",
                      buttonTextFontFamily: 'RobotoRegular',
                      buttonTextColor: AppColors.darkGrey,
                      buttonBorderColor: AppColors.primaryColor,
                      width: SizeConfig.safeBlockHorizontal * 8,
                      height: SizeConfig.safeBlockVertical * 5,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: SizeConfig.safeBlockHorizontal * 0.5),
                    child: TextButtonWithBorderWidget(
                      onPressed: () {
                        locator.get<ChatViewModel>().updateCurrentResponse(
                              response: Source.tiktok,
                            );
                      },
                      buttonTitle: "From Tik Tok",
                      buttonTextFontFamily: 'RobotoRegular',
                      buttonTextColor: AppColors.darkGrey,
                      buttonBorderColor: AppColors.primaryColor,
                      width: SizeConfig.safeBlockHorizontal * 8,
                      height: SizeConfig.safeBlockVertical * 5,
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                          left: SizeConfig.safeBlockHorizontal * 0.5),
                      child: TextButtonWithBorderWidget(
                        onPressed: () {
                          locator.get<ChatViewModel>().updateCurrentResponse(
                                response: Source.instagram,
                              );
                        },
                        buttonTitle: "From Instagram",
                        buttonTextFontFamily: 'RobotoRegular',
                        buttonTextColor: AppColors.darkGrey,
                        buttonBorderColor: AppColors.primaryColor,
                        width: SizeConfig.safeBlockHorizontal * 8,
                        height: SizeConfig.safeBlockVertical * 5,
                      )),
                ],
              )),
        ))
      ],
    ),
  );
}

String sourceToStringWithMessage(Source source) {
  switch (source) {
    case Source.youtube:
      return "Please login to your youtube account";
    case Source.tiktok:
      return "Please login to your Tik Tok account";
    case Source.facebook:
      return "Please login to your Facebook account";
    case Source.instagram:
      return "Please login to your Instagram account";
    case Source.gallery:
      return "Please Select media from your gallery";
  }
}

String sourceToString(Source source) {
  switch (source) {
    case Source.youtube:
      return "Youtube";
    case Source.tiktok:
      return "Tik Tok";
    case Source.facebook:
      return "Facebook";
    case Source.instagram:
      return "Instagram";
    case Source.gallery:
      return "Gallery";
  }
}
