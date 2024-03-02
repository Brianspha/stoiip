import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:lottie/lottie.dart';
import 'package:open_filex/open_filex.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stosp/ui/viewmodels/chat/chat_viewmodel.dart';
import 'package:uuid/uuid.dart';

import '../../../providers/chat_view_provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_navigator.dart';
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';
import '../../../utils/locator.dart';
import '../../../utils/size_config.dart';
import '../../widgets/button/text_button_with_border_widget.dart';
import '../../widgets/containers/padded_container.dart';

class ChatView extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ChatViewState();
  }
}

class Media {
  final String url;
  Media({required this.url});
}

class SocialMedia {
  final String name;
  final List<Media> media;
  SocialMedia({required this.media, required this.name});
}

class _ChatViewState extends ConsumerState<ChatView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ChatViewModel _chatViewModel = ref.watch(chatViewProvider);

    SizeConfig().init(context);
    return PaddedContainer(
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                        AppNavigator.navigationKey.currentState!.context)
                    .copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: Chat(
                  inputOptions: InputOptions(
                      enabled: _chatViewModel.chatViewModelState.canType),
                  customMessageBuilder: (types.CustomMessage message,
                      {required int messageWidth}) {
                    return loadCustomMessageWidget(message: message);
                  },
                  typingIndicatorOptions: TypingIndicatorOptions(
                      typingUsers:
                          _chatViewModel.chatViewModelState.typingUsers),
                  messages: _chatViewModel.chatViewModelState.messages,
                  //  onAttachmentPressed: _handleAttachmentPressed,
                  onMessageTap: (BuildContext context, types.Message message) {
                    _chatViewModel.handleMessageTap(
                        message: message, context: context);
                  },
                  onPreviewDataFetched:
                      (types.TextMessage message, types.PreviewData data) {
                    _chatViewModel.handlePreviewDataFetched(
                        message: message, previewData: data);
                  },
                  onSendPressed: (types.PartialText message) {
                    _chatViewModel.handleOnSendPressed(message: message);
                  },
                  showUserAvatars: true,
                  showUserNames: true,
                  user: _chatViewModel.chatViewModelState.userB,
                  theme: DefaultChatTheme(
                    seenIcon: Text(
                      'read',
                      style: TextStyle(
                        fontSize: SizeConfig().getTextSize(10),
                      ),
                    ),
                  ),
                ))));
  }
}

List<SocialMedia> _generateSocialMedia(
    {required int count, required List<String> socialMedias}) {
  return List.generate(
      socialMedias.length,
      (index) => SocialMedia(
          media: List.generate(
              count, (i) => Media(url: 'https://picsum.photos/200')),
          name: socialMedias[index]));
}
