import 'dart:convert';
import 'dart:io';
import 'package:faker/faker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_web3/ethereum.dart';
import 'package:flutter_web3/ethers.dart';
import 'package:lottie/lottie.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:html' as webFile;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:stosp/services/data/chainsafe.dart';
import 'package:stosp/ui/viewmodels/ip/ip_viewmodel.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/chat_file.dart';
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';
import '../../../utils/locator.dart';
import '../../../utils/size_config.dart';

///File Contains implementation of the chat view model
/// Does not follow coding standards
/// This view model state is mutable

abstract class ChatViewModel extends SafeChangeNotifier {
  void initialiseChat();
  void updateMessage({required types.Message message});
  void getFile();
  void updateCurrentResponse({required Source response});
  void handleAttachmentPressed({required BuildContext context});
  void requestMessage({required String prompt});
  void handleOnSendPressed({required types.PartialText message});
  void handleMessageTap(
      {required BuildContext context, required types.Message message});
  void handlePreviewDataFetched(
      {required types.TextMessage message,
      required types.PreviewData previewData});
  ChatViewModelState get chatViewModelState;
  void createIP({required String ipName, required String ipDescription});
  void updateCanTypeState();
  void updateKeyword({required String value});
  void updateDescription({required String value});
  void updateIPName({required String value});
  void generateDescription();
  void generateAtrributes();
  void onCreateIP();

  void issueNewIP();

  void viewAllIPs();

  void connectWallet();
  void getOwnedIPs();

  void createWidget();
  IPViewModelState get ipViewModelState;
  void deployIP({required IPSettings details});
  void registerIPWithPolicy(
      {required IPSematicsWithPolicy semanticsWithPolicy});

  void getOwnedIps();
  void currentIP({required IPDetails details});
  void purchaseLicense({required IPDetails details});
  void issuedLicenses();
  void setUserAddress({required String account});
  void processing();
  void initialise();
}

class ChatViewModelImpl extends ChatViewModel {
  ChatViewModelState _chatViewModelState = ChatViewModelState.empty();
  final _gemini = Gemini.instance;

  @override
  void handleAttachmentPressed({required BuildContext context}) {
    _handleFileSelection();
  }

  @override
  void requestMessage({required String prompt}) {
    _requestMessage(prompt: prompt);
  }

  @override
  Future<void> generateDescription() async {
    if (_chatViewModelState.keywordsController.text.isEmpty) return;
    _chatViewModelState = _chatViewModelState.copyWith(
        canType: false,
        generating: true,
        keywords: _chatViewModelState.keywordsController.text.split(','));
    notifyListeners();
    final description = await _generateGeminiPrompt(
        prompt:
            'Please write a concise description, no more than 100 words, using the following keywords : ${_chatViewModelState.keywords.toString()} related to intellectual property rights.');
    _chatViewModelState.ipDescriptionController.text = description ?? '';
    _chatViewModelState.defaultJSON["description"] = description;
    _chatViewModelState = _chatViewModelState.copyWith(
        description: description,
        canType: true,
        defaultJSON: _chatViewModelState.defaultJSON,
        generating: false,
        ipDescriptionController: _chatViewModelState.ipDescriptionController);
    notifyListeners();
  }

  @override
  Future<void> generateAtrributes() async {
    if (_chatViewModelState.keywordsController.text.isEmpty) return;
    _chatViewModelState = _chatViewModelState.copyWith(
      canType: false,
      generating: true,
    );
    notifyListeners();
    final sampleAtributes = [
      {"trait_type": "Artist", "value": "{{artist_name}}"},
      {"trait_type": "Resolution", "value": "{{resolution}}"},
      {"trait_type": "File Format", "value": "{{file_format}}"},
      {"trait_type": "Edition", "value": "{{edition}}"}
    ];
    final attributes = await _generateGeminiPrompt(
        prompt:
            'Please write a concise list of 3 attributes with the following attributes ${sampleAtributes} your job is to fill in the details where {{}} appears the results should be an array');
    _chatViewModelState.defaultJSON["attributes"] = attributes;
    _chatViewModelState = _chatViewModelState.copyWith(
      canType: true,
      defaultJSON: _chatViewModelState.defaultJSON,
      generating: false,
    );
    notifyListeners();
  }

  @override
  void handleMessageTap(
      {required BuildContext context, required types.Message message}) {
    _handleMessageTap(context, message);
  }

  @override
  void initialiseChat() {
    _chatViewModelState.typingUsers.add(_chatViewModelState.stosp);
    _chatViewModelState = _chatViewModelState.copyWith(
        typingUsers: _chatViewModelState.typingUsers);
    _addMessage(types.Message.fromJson({
      "author": {
        "firstName": _chatViewModelState.stosp.firstName,
        "id": _chatViewModelState.stosp.id,
        "lastName": _chatViewModelState.stosp.lastName
      },
      "createdAt": DateTime.now().millisecondsSinceEpoch,
      "createdAt": DateTime.now().millisecondsSinceEpoch,
      "id": "c67ed376-52bf-4d4e-ba2a-7a0f8467b22a",
      "status": "delivered",
      "text": '''👋 Hi! Welcome to STOSP! 🛡️ 

We're here to help you easily create and manage Intellectual Property rights (IPs) for your existing or new content! 

Let's get you started! 🚀''',
      "type": "text"
    }));
    notifyListeners();
    Future.delayed(Duration(seconds: 1), () {
      _addMessage(types.Message.fromJson({
        "author": {
          "firstName": _chatViewModelState.stosp.firstName,
          "id": _chatViewModelState.stosp.id,
          "lastName": _chatViewModelState.stosp.lastName
        },
        "createdAt": DateTime.now().millisecondsSinceEpoch,
        "id": 'ConnectWallet',
        "status": "delivered",
        "text": 'ConnectWallet',
        "type": "custom"
      }));
      _hideSystemTyping();
    });
  }

  @override
  void handlePreviewDataFetched(
      {required types.TextMessage message,
      required types.PreviewData previewData}) {
    _handlePreviewDataFetched(message: message, previewData: previewData);
  }

  @override
  void updateMessage({required types.Message message}) {
    // Message update logic here
    notifyListeners();
  }

  @override
  void getFile() {
    // File retrieval logic here
    notifyListeners();
  }

  @override
  ChatViewModelState get chatViewModelState => _chatViewModelState;

  @override
  void updateCurrentResponse({required Source response}) {
    _addMessage(types.Message.fromJson({
      "author": {
        "firstName": _chatViewModelState.userB.firstName,
        "id": _chatViewModelState.userB.id,
        "lastName": _chatViewModelState.userB.lastName
      },
      "createdAt": DateTime.now().millisecondsSinceEpoch,
      "id": Uuid().v4(),
      "status": "delivered",
      "text": "From ${sourceToString(response)}",
      "type": "text"
    }));
    _chatViewModelState =
        chatViewModelState.copyWith(currentResponse: response);
    _showSystemTyping();

    Future.delayed(const Duration(seconds: 1), () {
      _addMessage(types.Message.fromJson({
        "author": {
          "firstName": _chatViewModelState.stosp.firstName,
          "id": _chatViewModelState.stosp.id,
          "lastName": _chatViewModelState.stosp.lastName
        },
        "createdAt": DateTime.now().millisecondsSinceEpoch,
        "id": Uuid().v4(),
        "status": "delivered",
        "text": "Alright, ${sourceToStringWithMessage(response)}",
        "type": "text"
      }));
      _addMessage(types.Message.fromJson({
        "author": {
          "firstName": _chatViewModelState.stosp.firstName,
          "id": _chatViewModelState.stosp.id,
          "lastName": _chatViewModelState.stosp.lastName
        },
        "createdAt": DateTime.now().millisecondsSinceEpoch,
        "id": "Select Image/Video",
        "status": "delivered",
        "text": "Select Image",
        "type": "custom"
      }));
      _hideSystemTyping();
    });
  }

  void _hideSystemTyping() {
    _chatViewModelState.typingUsers.clear();
    _chatViewModelState = _chatViewModelState.copyWith(
        typingUsers: _chatViewModelState.typingUsers);
    notifyListeners();
  }

  void _showSystemTyping() {
    _chatViewModelState.typingUsers.clear();
    _chatViewModelState.typingUsers.add(_chatViewModelState.stosp);
    _chatViewModelState = _chatViewModelState.copyWith(
        typingUsers: _chatViewModelState.typingUsers);
    notifyListeners();
  }

  void _addMessage(types.Message message) {
    if (_chatViewModelState.messages.contains(message)) return;
    _chatViewModelState.messages.insert(0, message);
    _chatViewModelState =
        _chatViewModelState.copyWith(messages: _chatViewModelState.messages);
    notifyListeners();
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.isNotEmpty) {
      final message = types.Message.fromJson({
        "author": {
          "firstName": _chatViewModelState.userB.firstName,
          "id": _chatViewModelState.userB.id,
          "lastName": _chatViewModelState.userB.lastName
        },
        "createdAt": DateTime.now().millisecondsSinceEpoch,
        "id": "IP Creator",
        "status": "delivered",
        "text": "IP Creator",
        "type": "custom",
        "metada": {"ipImageURL": result.files.first.bytes!}
      });
      _chatViewModelState = _chatViewModelState.copyWith(
          currentFile: ChatFile(
        path: result.files.first.bytes!!,
        mimeType: lookupMimeType(result.files.first.name!),
        name: result.files.first.name,
        size: result.files.first.size,
        uri: result.files.first.bytes!,
        uploadedURL: '',
      ));

      _addMessage(message);
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: _chatViewModelState.userB,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      _addMessage(message);
    }
  }

  void _handlePreviewDataFetched(
      {required types.TextMessage message,
      required types.PreviewData previewData}) {
    final index =
        _chatViewModelState.messages.indexWhere((m) => m.id == message.id);
    if (index != -1) {
      // Assuming messages are of various types, ensure you're updating a TextMessage.
      final types.Message updatedMessage = _chatViewModelState.messages[index];
      if (updatedMessage is types.TextMessage) {
        final updatedTextMessage =
            updatedMessage.copyWith(previewData: previewData);
        // Update the message list with the updated message
        final List<types.Message> updatedMessages =
            List<types.Message>.from(_chatViewModelState.messages);
        updatedMessages[index] = updatedTextMessage;

        // Update the state with the new messages list
        _chatViewModelState =
            _chatViewModelState.copyWith(messages: updatedMessages);
        notifyListeners();
      }
    }
  }

  @override
  void handleOnSendPressed({required types.PartialText message}) {
    _handleSendPressed(message);
  }

  void _handleSendPressed(types.PartialText message) {
    if (_chatViewModelState.canType) {
      final textMessage = types.TextMessage(
        author: _chatViewModelState.userB,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: message.text,
      );
      _addMessage(textMessage);
    }
  }

  void _requestMessage({required String prompt}) async {
    _chatViewModelState.typingUsers.add(_chatViewModelState.stosp);
    _chatViewModelState = _chatViewModelState.copyWith(
        typingUsers: _chatViewModelState.typingUsers);
    notifyListeners();
    _gemini.chat([
      Content(parts: [Parts(text: prompt)], role: 'user')
    ]).then(((value) {
      // _messages.add(types.Message.fromJson());
      _chatViewModelState.typingUsers.remove(_chatViewModelState.stosp);
      _chatViewModelState.typingUsers.remove(_chatViewModelState.stosp);
      debugPrint(value?.output);
      _chatViewModelState = _chatViewModelState.copyWith(
          messages: _chatViewModelState.messages,
          typingUsers: _chatViewModelState.typingUsers);
      notifyListeners();
    })).catchError((e) {
      debugPrint('streamGenerateContent exception');
    });
  }

  Future<String?> _generateGeminiPrompt({required String prompt}) async {
    String? output = '';
    try {
      _chatViewModelState = _chatViewModelState.copyWith(canType: false);
      notifyListeners();
      final results = await _gemini.chat([
        Content(parts: [Parts(text: prompt)], role: 'user')
      ]);
      debugPrint(results?.output);
      output = results?.output;
    } catch (error) {
      debugPrint("error generating prompt: ${error.toString()}");
    }

    return output;
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index = _chatViewModelState.messages
              .indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_chatViewModelState.messages[index] as types.FileMessage)
                  .copyWith(
            isLoading: true,
          );

          _chatViewModelState.messages[index] = updatedMessage;
          _chatViewModelState = _chatViewModelState.copyWith(
              messages: _chatViewModelState.messages);
          notifyListeners();
          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index = _chatViewModelState.messages
              .indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_chatViewModelState.messages[index] as types.FileMessage)
                  .copyWith(
            isLoading: null,
          );

          _chatViewModelState = _chatViewModelState.copyWith(
              messages: _chatViewModelState.messages);
          notifyListeners();
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  @override
  void createIP({required String ipName, required String ipDescription}) {
    final message = types.Message.fromJson({
      "author": {
        "firstName": _chatViewModelState.stosp.firstName,
        "id": _chatViewModelState.stosp.id,
        "lastName": _chatViewModelState.stosp.lastName
      },
      "createdAt": DateTime.now().millisecondsSinceEpoch,
      "id": "Creating IP",
      "status": "delivered",
      "text": "Creating IP",
      "type": "custom",
    });
    _chatViewModelState = _chatViewModelState.copyWith(canType: false);
    _addMessage(message);
    _createIP(ipName: ipName, ipDescription: ipDescription);
  }

  Future<void> _createIP(
      {required String ipName, required String ipDescription}) async {
    await generateAtrributes();
    _chatViewModelState.defaultJSON["name"] = ipName;
    _chatViewModelState.defaultJSON["description"] = ipDescription;
    notifyListeners();
    await uploadImage();
    await uploadIPJSON();
    initialise();
    // _chatViewModelState.messages.removeAt(0);
    final message = types.Message.fromJson({
      "author": {
        "firstName": _chatViewModelState.stosp.firstName,
        "id": _chatViewModelState.stosp.id,
        "lastName": _chatViewModelState.stosp.lastName
      },
      "createdAt": DateTime.now().millisecondsSinceEpoch,
      "id": "IP Created",
      "status": "delivered",
      "text": "IP Created",
      "type": "custom",
      "remoteId": jsonEncode({
        "ipCreated": true,
        "transactionHash":
            "0xb3e5137532b5d131ee9dab5787ca5bec46cea0383a33194e0f79c089aa52d08d"
      })
    });
    _chatViewModelState = _chatViewModelState.copyWith(
        canType: false,
        ipCreatedResults: IPCreatedResults(
            transactionHash:
                '0xb3e5137532b5d131ee9dab5787ca5bec46cea0383a33194e0f79c089aa52d08d',
            status: true));
    final message1 = types.Message.fromJson({
      "author": {
        "firstName": _chatViewModelState.stosp.firstName,
        "id": _chatViewModelState.stosp.id,
        "lastName": _chatViewModelState.stosp.lastName
      },
      "createdAt": DateTime.now().millisecondsSinceEpoch,
      "id": "Start",
      "status": "delivered",
      "text": "Start",
      "type": "custom",
    });
    _chatViewModelState = _chatViewModelState.copyWith(
        canType: false,
        ipCreatedResults: IPCreatedResults(
            transactionHash:
                '0xb3e5137532b5d131ee9dab5787ca5bec46cea0383a33194e0f79c089aa52d08d',
            status: true));
    _addMessage(message);
    _addMessage(message1);
    // registerIPWithPolicy(semanticsWithPolicy: IPSematicsWithPolicy(ipName: ipName, url: '', policyId: BigInt.parse("0"), contentHash: null, tokenId: null, policySettings: null,));
  }

  @override
  void updateCanTypeState() {
    _chatViewModelState =
        _chatViewModelState.copyWith(canType: !_chatViewModelState.canType);
    notifyListeners();
  }

  @override
  void updateIPName({required String value}) {
    _chatViewModelState = _chatViewModelState.copyWith(name: value);
    notifyListeners();
  }

  @override
  void updateKeyword({required String value}) {
    if (value.isEmpty) return;
    _chatViewModelState =
        _chatViewModelState.copyWith(keywords: value.split(','));
    notifyListeners();
  }

  @override
  void updateDescription({required String value}) {
    _chatViewModelState = _chatViewModelState.copyWith(description: value);
    notifyListeners();
  }

  @override
  void onCreateIP() {
    createIP(
        ipName: _chatViewModelState.name,
        ipDescription: _chatViewModelState.description.isEmpty
            ? _chatViewModelState.ipDescriptionController.text
            : _chatViewModelState.description);
  }

  @override
  void issueNewIP() {
    _showSystemTyping();
    Future.delayed(Duration(seconds: 1), () {
      _hideSystemTyping();
      _addMessage(types.Message.fromJson({
        "author": {
          "firstName": _chatViewModelState.stosp.firstName,
          "id": _chatViewModelState.stosp.id,
          "lastName": _chatViewModelState.stosp.lastName
        },
        "createdAt": DateTime.now().millisecondsSinceEpoch,
        "id": '''Where would you like me to get your content from?''',
        "status": "delivered",
        "text": '''Where would you like me to get your content from?''',
        "type": "custom"
      }));
    });
  }

  @override
  void viewAllIPs() {
    _addMessage(types.Message.fromJson({
      "author": {
        "firstName": _chatViewModelState.userB.firstName,
        "id": _chatViewModelState.userB.id,
        "lastName": _chatViewModelState.userB.lastName
      },
      "createdAt": DateTime.now().millisecondsSinceEpoch,
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "status": "delivered",
      "text": 'View All IPs',
      "type": "text"
    }));
    _addMessage(types.Message.fromJson({
      "author": {
        "firstName": _chatViewModelState.stosp.firstName,
        "id": _chatViewModelState.stosp.id,
        "lastName": _chatViewModelState.stosp.lastName
      },
      "createdAt": DateTime.now().millisecondsSinceEpoch,
      "id": "loading",
      "status": "delivered",
      "text": 'loading',
      "type": "custom"
    }));
    Future.delayed(Duration(seconds: 10), () {
      _chatViewModelState.messages.removeAt(0);
      _chatViewModelState = _chatViewModelState.copyWith(
          ownedIPs: List<IP>.generate(10, (_) => IP.generateFake()),
          messages: _chatViewModelState.messages);
      _addMessage(types.Message.fromJson({
        "author": {
          "firstName": _chatViewModelState.stosp.firstName,
          "id": _chatViewModelState.stosp.id,
          "lastName": _chatViewModelState.stosp.lastName
        },
        "createdAt": DateTime.now().millisecondsSinceEpoch,
        "id": "viewIPS",
        "status": "delivered",
        "text": 'viewIPS',
        "type": "custom"
      }));
    });
  }

  @override
  void connectWallet() async {
    Web3Provider web3provider;
    _chatViewModelState = _chatViewModelState.copyWith(generating: true);
    _addMessage(types.Message.fromJson({
      "author": {
        "firstName": _chatViewModelState.userB.firstName,
        "id": _chatViewModelState.userB.id,
        "lastName": _chatViewModelState.userB.lastName
      },
      "createdAt": DateTime.now().millisecondsSinceEpoch,
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "status": "delivered",
      "text": 'Connect Wallet',
      "type": "text"
    }));
    notifyListeners();
    debugPrint("In connect wallet");
    // `Ethereum.isSupported` is the same as `ethereum != null`
    if (ethereum != null) {
      try {
        final Web3Provider web3provider = Web3Provider(ethereum!);
        _chatViewModelState =
            _chatViewModelState.copyWith(web3Provider: web3provider);
        notifyListeners();
        // Prompt user to connect to the provider, i.e. confirm the connection modal
        final accounts = await ethereum!.requestAccount();
        debugPrint("accounts: $accounts");
        if (accounts.isNotEmpty) {
          _chatViewModelState = _chatViewModelState.copyWith(
              user: User(
                account: accounts.first,
                connected: true,
              ),
              generating: false);
          _addMessage(types.Message.fromJson({
            "author": {
              "firstName": _chatViewModelState.stosp.firstName,
              "id": _chatViewModelState.stosp.id,
              "lastName": _chatViewModelState.stosp.lastName
            },
            "createdAt": DateTime.now().millisecondsSinceEpoch,
            "id": DateTime.now().millisecondsSinceEpoch.toString(),
            "status": "delivered",
            "text":
                "Yay 😊, Ive connected your wallet account ${accounts.first}",
            "type": "text"
          }));
          _addMessage(types.Message.fromJson({
            "author": {
              "firstName": _chatViewModelState.stosp.firstName,
              "id": _chatViewModelState.stosp.id,
              "lastName": _chatViewModelState.stosp.lastName
            },
            "createdAt": DateTime.now().millisecondsSinceEpoch,
            "id": "Start",
            "status": "delivered",
            "text": "",
            "type": "custom"
          }));
          notifyListeners();
        }
        // Subscribe to `chainChanged` event
        ethereum!.onChainChanged((chainId) {
          debugPrint("chainId: ${chainId}");
        });

// Subscribe to `accountsChanged` event.
        ethereum!.onAccountsChanged((accounts) {
          debugPrint("accounts: ${accounts}");
        });
        // Subscribe to `message` event, need to convert JS message object to dart object.
        ethereum!.on('message', (message) {
          dartify(message); // baz
        });
      } on EthereumUserRejected {
        _showErrorMessage(
            message:
                'Im having issues connect to your wallet, please try again :XD');
        debugPrint('User rejected the modal');
      }
    } else {
      _showErrorMessage(
          message:
              'Im having issues connect to your wallet, please try again :XD');
    }
    notifyListeners();
  }

  void _showErrorMessage({required String message}) {
    _addMessage(types.Message.fromJson({
      "author": {
        "firstName": _chatViewModelState.stosp.firstName,
        "id": _chatViewModelState.stosp.id,
        "lastName": _chatViewModelState.stosp.lastName
      },
      "createdAt": DateTime.now().millisecondsSinceEpoch,
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "status": "delivered",
      "text": message,
      "type": "text"
    }));
    _addMessage(types.Message.fromJson({
      "author": {
        "firstName": _chatViewModelState.stosp.firstName,
        "id": _chatViewModelState.stosp.id,
        "lastName": _chatViewModelState.stosp.lastName
      },
      "createdAt": DateTime.now().millisecondsSinceEpoch,
      "id": "error",
      "status": "delivered",
      "text": 'error',
      "type": "custom"
    }));
  }

  @override
  void getOwnedIPs() {
    _addMessage(types.Message.fromJson({
      "author": {
        "firstName": _chatViewModelState.stosp.firstName,
        "id": _chatViewModelState.stosp.id,
        "lastName": _chatViewModelState.stosp.lastName
      },
      "createdAt": DateTime.now().millisecondsSinceEpoch,
      "id": "loading",
      "status": "delivered",
      "text": 'loading',
      "type": "custom"
    }));
    Future.delayed(Duration(seconds: 10), () {
      _chatViewModelState.messages.removeAt(0);
      _chatViewModelState = _chatViewModelState.copyWith(
          ownedIPs: List<IP>.generate(10, (_) => IP.generateFake()),
          messages: _chatViewModelState.messages);
      _addMessage(types.Message.fromJson({
        "author": {
          "firstName": _chatViewModelState.stosp.firstName,
          "id": _chatViewModelState.stosp.id,
          "lastName": _chatViewModelState.stosp.lastName
        },
        "createdAt": DateTime.now().millisecondsSinceEpoch,
        "id": "viewIPS",
        "status": "delivered",
        "text": 'viewIPS',
        "type": "custom"
      }));
    });
  }

  @override
  Future<void> createWidget() async {
    try {
      _chatViewModelState = _chatViewModelState.copyWith(generating: true);
      notifyListeners();
      // Path to your Flutter project
      var projectPath = '/Users/siphamandlamjoli/Documents/GitHub/stosp/widget';

      // The command to build the Flutter web project
      var command = 'flutter';
      // The arguments to pass to the command
      var arguments = ['build', 'web'];

      // Change the current working directory to the project path
      Directory.current = projectPath;

      // Run the command and wait for the output
      var result = await Process.run(command, arguments, runInShell: true);
      debugPrint("resuts: ${result}");
      // Check the result
      if (result.exitCode == 0) {
        debugPrint('Build successful');
        debugPrint(result.stdout);
      } else {
        debugPrint('Build failed');
        debugPrint(result.stderr);
      }
      _chatViewModelState = _chatViewModelState.copyWith(generating: false);
      notifyListeners();
    }
    catch(error){
      debugPrint("error creating widget: ${error}");
      _chatViewModelState = _chatViewModelState.copyWith(generating: false);
      notifyListeners();
    }
  }

  Future<void> uploadImage() async {
    final url = await ChainSafeService().uploadFile(
        bucketId: "17196335-2450-46eb-b763-e91f68fc60f8",
        file: _chatViewModelState.currentFile.path,
        uploadPath: _chatViewModelState.currentFile.name);
    _chatViewModelState.defaultJSON["image"] = url;
    _chatViewModelState = _chatViewModelState.copyWith(
        defaultJSON: _chatViewModelState.defaultJSON,
        currentFile:
            _chatViewModelState.currentFile.copyWith(uploadedURL: url));
    notifyListeners();
  }

  Future<webFile.Blob> _writeFile(String content, String fileName) async {
    final file = webFile.Blob([content], 'text/plain', 'native');

    debugPrint('File written successfully');
    return file;
  }

  Future<void> uploadIPJSON() async {
    final url = await ChainSafeService().uploadNormalFile(
        data: _chatViewModelState.defaultJSON.toString(),
        uploadPath: _chatViewModelState.currentFile.name);
    _chatViewModelState.defaultJSON["jsonURI"] = url;
    _chatViewModelState = _chatViewModelState.copyWith(
      defaultJSON: _chatViewModelState.defaultJSON,
    );
    debugPrint(
        "_chatViewModelState.defaultJSON: ${_chatViewModelState.defaultJSON}");
    notifyListeners();
  }

  IPViewModelState _ipViewModelState = IPViewModelState.empty();
  @override
  // TODO: implement ipViewModelState
  IPViewModelState get ipViewModelState => _ipViewModelState;

  @override
  void currentIP({required IPDetails details}) {
    _ipViewModelState = _ipViewModelState.copyWith(
      currentIPDetail: details,
    );
    notifyListeners();
  }

  @override
  Future<void> getOwnedIps() async {
    try {
      final ips = await _ipViewModelState.ipRegistrar
          ?.call('userIps', [_ipViewModelState.account]);
      debugPrint("ips: ${ips}");
    } catch (error) {
      debugPrint("error registering IP: ${error}");
    }
  }

  @override
  Future<void> issuedLicenses() async {
    try {
      final licenses = await _ipViewModelState.ipHolder?.call(
          'accountLicenses', [_ipViewModelState.currentIPDetail.ipIdAccount]);
      debugPrint("tx: ${licenses}");
    } catch (error) {
      debugPrint("error registering IP: ${error}");
    }
  }

  @override
  Future<void> purchaseLicense({required IPDetails details}) async {
    try {
      final approvalTx =
          await _ipViewModelState.tokenContract?.send('approve', [
        details.ipIdAccount,
        BigInt.parse(
            '115792089237316195423570985008687907853269984665640564039457584007913129639935')
      ]);
      final licenseId = await _ipViewModelState.tokenContract?.send(
          'issueLicense', [
        details.policyId,
        details.ipIdAccount,
        1,
        _ipViewModelState.account,
        "0x"
      ]);
      debugPrint("approvalTx: ${approvalTx} licenseId: ${licenseId}");
    } catch (error) {
      debugPrint("error registering IP: ${error}");
    }
  }

  @override
  Future<void> deployIP({required IPSettings details}) async {
    try {
      final tx = await _ipViewModelState.ipRegistrar?.send('deployIP', [
        details.ipAssetRegistry,
        details.resolver,
        details.nftToken,
        details.registrationModule,
        details.policyRegistrar,
        details.licensingModule,
        details.spg,
        details.licenseCost,
        details.licenseToken
      ]);
      debugPrint("tx: ${tx?.hash}");
    } catch (error) {
      debugPrint("error registering IP: ${error}");
    }
  }

  @override
  void initialise() {
    connectWallet();
    final Web3Provider provider = _chatViewModelState.web3Provider!;
    Contract ipRegistrar = Contract(
        '0xe101633d2975dF9242Be1eFA5d2fAb59cD09089B', REGISTRAR_ABI, provider);
    Contract ipHolder = Contract('0x', IP_ISSUER_ABI, provider);
    Contract tokenContract = Contract(
        '0xD4C6410283cC010f9A1c2B0d370FBAdcbe598447', TOKEN_ABI, provider);
    Contract nftIssuer = Contract(
        '0xE0A0e9d44F5662A20a4383a4f68B28E625A5c4a1', NFT_ISSUER_ABI, provider);
    _ipViewModelState = _ipViewModelState.copyWith(
        ipRegistrar: ipRegistrar,
        ipHolder: ipHolder,
        tokenContract: tokenContract,
        nftIssuer: nftIssuer);
    notifyListeners();
  }

  @override
  void setUserAddress({required String account}) {
    _ipViewModelState = _ipViewModelState.copyWith(
      account: account,
    );
    notifyListeners();
  }

  @override
  Future<void> registerIPWithPolicy(
      {required IPSematicsWithPolicy semanticsWithPolicy}) async {
    try {
      semanticsWithPolicy = semanticsWithPolicy.copyWith(
          url: _chatViewModelState.defaultJSON["jsonURI"]);
      final tx = await _ipViewModelState.ipRegistrar?.send('deployIP', [
        semanticsWithPolicy.ipName,
        semanticsWithPolicy.url,
        semanticsWithPolicy.policyId,
        semanticsWithPolicy.contentHash,
        semanticsWithPolicy.tokenId,
        [
          semanticsWithPolicy.policySettings.transferable,
          semanticsWithPolicy.policySettings.royaltyPolicy,
          semanticsWithPolicy.policySettings.mintingFee,
          semanticsWithPolicy.policySettings.mintingFeeToken,
          [
            semanticsWithPolicy.policySettings.policy.attribution,
            semanticsWithPolicy.policySettings.policy.commercialUse,
            semanticsWithPolicy.policySettings.policy.commercialAttribution,
            semanticsWithPolicy.policySettings.policy.commercializerChecker,
            semanticsWithPolicy.policySettings.policy.commercializerCheckerData,
            semanticsWithPolicy.policySettings.policy.commercialRevShare,
            semanticsWithPolicy.policySettings.policy.derivativesAllowed,
            semanticsWithPolicy.policySettings.policy.derivativesAttribution,
            semanticsWithPolicy.policySettings.policy.derivativesApproval,
            semanticsWithPolicy.policySettings.policy.derivativesReciprocal,
            semanticsWithPolicy.policySettings.policy.territories,
            semanticsWithPolicy.policySettings.policy.distributionChannels,
            semanticsWithPolicy.policySettings.policy.contentRestrictions,
          ]
        ]
      ]);
      debugPrint("tx: ${tx?.hash}");
    } catch (error) {
      debugPrint("error registering IP: ${error}");
    }
  }

  @override
  void processing() {
    _ipViewModelState =
        _ipViewModelState.copyWith(processing: !_ipViewModelState.processing);
    notifyListeners();
  }
}

class IPCreatedResults {
  final String transactionHash;
  final bool status;
  IPCreatedResults({required this.transactionHash, required this.status});
  static IPCreatedResults empty() {
    return IPCreatedResults(status: false, transactionHash: '');
  }
}

class IP {
  final String name;
  final String description;
  final String url;
  final int tokenId;
  IP(
      {required this.name,
      required this.description,
      required this.tokenId,
      required this.url});
  static IP empty() {
    return IP(description: '', name: '', tokenId: -1, url: '');
  }

  // Generate a single instance of IP with fake data
  static IP generateFake() {
    final faker = Faker();
    return IP(
      name: faker.person.name(),
      description: faker.lorem.sentence(),
      tokenId: faker.randomGenerator.integer(9999),
      url: 'https://picsum.photos/200/300',
    );
  }
}

class User {
  final String account;
  final bool connected;
  User({required this.account, required this.connected});
  static User empty() {
    return User(connected: false, account: '');
  }
}

class ChatViewModelState {
  final List<types.User> users;
  final List<types.Message> messages;
  final Source currentResponse;
  final types.User stosp;
  final types.User userB;
  final List<types.User> typingUsers;
  final ChatFile currentFile;
  final List<String> keywords;
  final String description;
  final String name;
  final bool canType;
  final TextEditingController ipNameController;
  final TextEditingController ipDescriptionController;
  final TextEditingController keywordsController;
  final bool generating;
  final IPCreatedResults ipCreatedResults;
  final User user;
  final List<IP> ownedIPs;
  final Map defaultJSON;
  final Web3Provider? web3Provider;
  ChatViewModelState(
      {required this.users,
      required this.web3Provider,
      required this.defaultJSON,
      required this.ipCreatedResults,
      required this.generating,
      required this.ipNameController,
      required this.ipDescriptionController,
      required this.keywordsController,
      required this.messages,
      required this.user,
      required this.keywords,
      required this.currentResponse,
      required this.stosp,
      required this.ownedIPs,
      required this.userB,
      required this.description,
      required this.name,
      required this.canType,
      required this.currentFile,
      required this.typingUsers});

  // Dart model method to get an empty state
  static ChatViewModelState empty() {
    return ChatViewModelState(
        ipCreatedResults: IPCreatedResults.empty(),
        currentFile: ChatFile.empty(),
        users: [
          const types.User(
            firstName: "STOSP",
            id: '82091008-a484-4a89-ae75-a22bf8d6f3a1',
          ),
          const types.User(
            firstName: "User",
            id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
          )
        ],
        messages: [],
        currentResponse: Source.gallery,
        stosp: const types.User(
          firstName: "STOSP",
          id: '82091008-a484-4a89-ae75-a22bf8d6f3a1',
        ),
        userB: const types.User(
          firstName: "User",
          id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
        ),
        typingUsers: [],
        keywords: [],
        description: '',
        name: '',
        canType: false,
        ipNameController: TextEditingController(),
        ipDescriptionController: TextEditingController(),
        keywordsController: TextEditingController(),
        generating: false,
        user: User.empty(),
        ownedIPs: [],
        defaultJSON: {
          "name": "",
          "description": "",
          "image": "",
          "attributes": []
        },
        web3Provider: null);
  }

  // Dart model method to copy the state with updated values
  ChatViewModelState copyWith(
      {List<types.User>? users,
      List<types.Message>? messages,
      Source? currentResponse,
      types.User? stosp,
      types.User? userB,
      ChatFile? currentFile,
      String? name,
      String? description,
      List<types.User>? typingUsers,
      bool? canType,
      Map? defaultJSON,
      TextEditingController? ipNameController,
      TextEditingController? ipDescriptionController,
      TextEditingController? keywordsController,
      bool? generating,
      User? user,
      List<IP>? ownedIPs,
      IPCreatedResults? ipCreatedResults,
      List<String>? keywords,
      Web3Provider? web3Provider}) {
    return ChatViewModelState(
      web3Provider: web3Provider ?? this.web3Provider,
      defaultJSON: defaultJSON ?? this.defaultJSON,
      ownedIPs: ownedIPs ?? this.ownedIPs,
      user: user ?? this.user,
      ipCreatedResults: ipCreatedResults ?? this.ipCreatedResults,
      generating: generating ?? this.generating,
      ipNameController: ipNameController ?? this.ipNameController,
      ipDescriptionController:
          ipDescriptionController ?? this.ipDescriptionController,
      keywordsController: keywordsController ?? this.keywordsController,
      keywords: keywords ?? this.keywords,
      currentFile: currentFile ?? this.currentFile,
      stosp: stosp ?? this.stosp,
      userB: userB ?? this.userB,
      users: users ?? this.users,
      messages: messages ?? this.messages,
      currentResponse: currentResponse ?? this.currentResponse,
      typingUsers: typingUsers ?? this.typingUsers,
      description: description ?? this.description,
      name: name ?? this.name,
      canType: canType ?? this.canType,
    );
  }
}

class IPViewModelState {
  final Contract? ipRegistrar;
  final Contract? ipHolder;
  final Contract? tokenContract;
  final Contract? nftIssuer;
  final List<IPDetails> ipDetails;
  final IPDetails currentIPDetail;
  final List<BigInt> issuedLicenses;
  final IPSettings settings;
  final String account;
  final bool processing;
  IPViewModelState(
      {required this.tokenContract,
      required this.processing,
      required this.nftIssuer,
      required this.account,
      required this.ipRegistrar,
      required this.ipHolder,
      required this.ipDetails,
      required this.settings,
      required this.currentIPDetail,
      required this.issuedLicenses});

  // copyWith method to create a new instance with the same or updated properties
  IPViewModelState copyWith(
      {Contract? ipRegistrar,
      Contract? ipHolder,
      Contract? tokenContract,
      Contract? nftIssuer,
      List<IPDetails>? ipDetails,
      IPDetails? currentIPDetail,
      IPSettings? settings,
      String? account,
      bool? processing,
      List<BigInt>? issuedLicenses}) {
    return IPViewModelState(
      processing: processing ?? this.processing,
      account: account ?? this.account,
      settings: settings ?? this.settings,
      tokenContract: tokenContract ?? this.tokenContract,
      nftIssuer: nftIssuer ?? this.nftIssuer,
      ipDetails: ipDetails ?? this.ipDetails,
      currentIPDetail: currentIPDetail ?? this.currentIPDetail,
      issuedLicenses: issuedLicenses ?? this.issuedLicenses,
      ipRegistrar: ipRegistrar ?? this.ipRegistrar,
      ipHolder: ipHolder ?? this.ipHolder,
    );
  }

  // Static method to create an empty IPViewModelState
  static IPViewModelState empty() {
    return IPViewModelState(
      ipRegistrar:
          null, // Assuming Contract has an empty constructor or similar method
      ipHolder: null,
      ipDetails: [],
      currentIPDetail: IPDetails.empty(),
      issuedLicenses: [],
      tokenContract: null,
      nftIssuer: null, settings: IPSettings.empty(),
      account: '', processing: false,
    );
  }

  @override
  int get hashCode => ipRegistrar.hashCode ^ ipHolder.hashCode;
}

class PILPolicy {
  final bool attribution;
  final bool commercialUse;
  final bool commercialAttribution;
  final String commercializerChecker;
  final Uint8List commercializerCheckerData;
  final int commercialRevShare;
  final bool derivativesAllowed;
  final bool derivativesAttribution;
  final bool derivativesApproval;
  final bool derivativesReciprocal;
  final List<String> territories;
  final List<String> distributionChannels;
  final List<String> contentRestrictions;

  PILPolicy({
    required this.attribution,
    required this.commercialUse,
    required this.commercialAttribution,
    required this.commercializerChecker,
    required this.commercializerCheckerData,
    required this.commercialRevShare,
    required this.derivativesAllowed,
    required this.derivativesAttribution,
    required this.derivativesApproval,
    required this.derivativesReciprocal,
    required this.territories,
    required this.distributionChannels,
    required this.contentRestrictions,
  });
  PILPolicy copyWith({
    bool? attribution,
    bool? commercialUse,
    bool? commercialAttribution,
    String? commercializerChecker,
    Uint8List? commercializerCheckerData,
    int? commercialRevShare,
    bool? derivativesAllowed,
    bool? derivativesAttribution,
    bool? derivativesApproval,
    bool? derivativesReciprocal,
    List<String>? territories,
    List<String>? distributionChannels,
    List<String>? contentRestrictions,
  }) {
    return PILPolicy(
      attribution: attribution ?? this.attribution,
      commercialUse: commercialUse ?? this.commercialUse,
      commercialAttribution:
          commercialAttribution ?? this.commercialAttribution,
      commercializerChecker:
          commercializerChecker ?? this.commercializerChecker,
      commercializerCheckerData:
          commercializerCheckerData ?? this.commercializerCheckerData,
      commercialRevShare: commercialRevShare ?? this.commercialRevShare,
      derivativesAllowed: derivativesAllowed ?? this.derivativesAllowed,
      derivativesAttribution:
          derivativesAttribution ?? this.derivativesAttribution,
      derivativesApproval: derivativesApproval ?? this.derivativesApproval,
      derivativesReciprocal:
          derivativesReciprocal ?? this.derivativesReciprocal,
      territories: territories ?? this.territories,
      distributionChannels: distributionChannels ?? this.distributionChannels,
      contentRestrictions: contentRestrictions ?? this.contentRestrictions,
    );
  }

  // Static method for an empty PILPolicy instance
  static PILPolicy empty() {
    return PILPolicy(
      attribution: false,
      commercialUse: false,
      commercialAttribution: false,
      commercializerChecker: '',
      commercializerCheckerData: Uint8List(0),
      commercialRevShare: 0,
      derivativesAllowed: false,
      derivativesAttribution: false,
      derivativesApproval: false,
      derivativesReciprocal: false,
      territories: [],
      distributionChannels: [],
      contentRestrictions: [],
    );
  }
}

class RegisterPILPolicyParams {
  final bool transferable;
  final String royaltyPolicy;
  final int mintingFee;
  final String mintingFeeToken;
  final PILPolicy policy;

  RegisterPILPolicyParams({
    required this.transferable,
    required this.royaltyPolicy,
    required this.mintingFee,
    required this.mintingFeeToken,
    required this.policy,
  });
  RegisterPILPolicyParams copyWith({
    bool? transferable,
    String? royaltyPolicy,
    int? mintingFee,
    String? mintingFeeToken,
    PILPolicy? policy,
  }) {
    return RegisterPILPolicyParams(
      transferable: transferable ?? this.transferable,
      royaltyPolicy: royaltyPolicy ?? this.royaltyPolicy,
      mintingFee: mintingFee ?? this.mintingFee,
      mintingFeeToken: mintingFeeToken ?? this.mintingFeeToken,
      policy: policy ?? this.policy,
    );
  }

  // Static method for an empty RegisterPILPolicyParams instance
  static RegisterPILPolicyParams empty() {
    return RegisterPILPolicyParams(
      transferable: false,
      royaltyPolicy: '',
      mintingFee: 0,
      mintingFeeToken: '',
      policy: PILPolicy.empty(),
    );
  }
}

class IPRegistration {
  final String nftName;
  final String nftDescription;
  final String nftUrl;
  final String nftImage;
  final String ipKey;
  final String ipValue;
  final IPSematics ipsemantics;

  IPRegistration({
    required this.nftName,
    required this.nftDescription,
    required this.nftUrl,
    required this.nftImage,
    required this.ipKey,
    required this.ipValue,
    required this.ipsemantics,
  });
  IPRegistration copyWith({
    String? nftName,
    String? nftDescription,
    String? nftUrl,
    String? nftImage,
    String? ipKey,
    String? ipValue,
    IPSematics? ipsemantics,
  }) {
    return IPRegistration(
      nftName: nftName ?? this.nftName,
      nftDescription: nftDescription ?? this.nftDescription,
      nftUrl: nftUrl ?? this.nftUrl,
      nftImage: nftImage ?? this.nftImage,
      ipKey: ipKey ?? this.ipKey,
      ipValue: ipValue ?? this.ipValue,
      ipsemantics: ipsemantics ?? this.ipsemantics,
    );
  }

  static IPRegistration empty() {
    return IPRegistration(
      nftName: '',
      nftDescription: '',
      nftUrl: '',
      nftImage: '',
      ipKey: '',
      ipValue: '',
      ipsemantics: IPSematics.empty(),
    );
  }
}

class IPSematicsWithPolicy {
  final String ipName;
  final String url;
  final BigInt policyId;
  final Uint8List contentHash;
  final BigInt tokenId;
  final RegisterPILPolicyParams policySettings;

  IPSematicsWithPolicy({
    required this.ipName,
    required this.url,
    required this.policyId,
    required this.contentHash,
    required this.tokenId,
    required this.policySettings,
  });
  IPSematicsWithPolicy copyWith({
    String? ipName,
    String? url,
    BigInt? policyId,
    Uint8List? contentHash,
    BigInt? tokenId,
    RegisterPILPolicyParams? policySettings,
  }) {
    return IPSematicsWithPolicy(
      ipName: ipName ?? this.ipName,
      url: url ?? this.url,
      policyId: policyId ?? this.policyId,
      contentHash: contentHash ?? this.contentHash,
      tokenId: tokenId ?? this.tokenId,
      policySettings: policySettings ?? this.policySettings,
    );
  }

  static IPSematicsWithPolicy empty() {
    return IPSematicsWithPolicy(
      ipName: '',
      url: '',
      policyId: BigInt.zero,
      contentHash: Uint8List(32),
      tokenId: BigInt.zero,
      policySettings: RegisterPILPolicyParams.empty(),
    );
  }
}

class IPSematics {
  final String ipName;
  final String url;
  final BigInt policyId;
  final Uint8List contentHash;
  final BigInt tokenId;

  IPSematics({
    required this.ipName,
    required this.url,
    required this.policyId,
    required this.contentHash,
    required this.tokenId,
  });
  IPSematics copyWith({
    String? ipName,
    String? url,
    BigInt? policyId,
    Uint8List? contentHash,
    BigInt? tokenId,
  }) {
    return IPSematics(
      ipName: ipName ?? this.ipName,
      url: url ?? this.url,
      policyId: policyId ?? this.policyId,
      contentHash: contentHash ?? this.contentHash,
      tokenId: tokenId ?? this.tokenId,
    );
  }

  static IPSematics empty() {
    return IPSematics(
      ipName: '',
      url: '',
      policyId: BigInt.zero,
      contentHash: Uint8List(32),
      tokenId: BigInt.zero,
    );
  }
}

class IPSettings {
  final String ipAssetRegistry;
  final String resolver;
  final String nftToken;
  final String registrationModule;
  final String policyRegistrar;
  final String licensingModule;
  final String spg;
  final BigInt licenseCost;
  final String licenseToken;

  IPSettings({
    required this.ipAssetRegistry,
    required this.resolver,
    required this.nftToken,
    required this.registrationModule,
    required this.policyRegistrar,
    required this.licensingModule,
    required this.spg,
    required this.licenseCost,
    required this.licenseToken,
  });
  IPSettings copyWith({
    String? ipAssetRegistry,
    String? resolver,
    String? nftToken,
    String? registrationModule,
    String? policyRegistrar,
    String? licensingModule,
    String? spg,
    BigInt? licenseCost,
    String? licenseToken,
  }) {
    return IPSettings(
      ipAssetRegistry: ipAssetRegistry ?? this.ipAssetRegistry,
      resolver: resolver ?? this.resolver,
      nftToken: nftToken ?? this.nftToken,
      registrationModule: registrationModule ?? this.registrationModule,
      policyRegistrar: policyRegistrar ?? this.policyRegistrar,
      licensingModule: licensingModule ?? this.licensingModule,
      spg: spg ?? this.spg,
      licenseCost: licenseCost ?? this.licenseCost,
      licenseToken: licenseToken ?? this.licenseToken,
    );
  }

  static IPSettings empty() {
    return IPSettings(
      ipAssetRegistry: '',
      resolver: '',
      nftToken: '',
      registrationModule: '',
      policyRegistrar: '',
      licensingModule: '',
      spg: '',
      licenseCost: BigInt.zero,
      licenseToken: '',
    );
  }
}

class IPDetails {
  final BigInt policyId;
  final BigInt indexOnIpId;
  final String ipIdAccount; // Placeholder for ERC6551Account

  IPDetails({
    required this.policyId,
    required this.indexOnIpId,
    required this.ipIdAccount, // Adjust as necessary
  });
  IPDetails copyWith({
    BigInt? policyId,
    BigInt? indexOnIpId,
    String? ipIdAccount,
  }) {
    return IPDetails(
      policyId: policyId ?? this.policyId,
      indexOnIpId: indexOnIpId ?? this.indexOnIpId,
      ipIdAccount: ipIdAccount ?? this.ipIdAccount,
    );
  }

  static IPDetails empty() {
    return IPDetails(
      policyId: BigInt.zero,
      indexOnIpId: BigInt.zero,
      ipIdAccount: '', // Adjust as necessary
    );
  }
}

class IPLease {
  final BigInt policyId;
  final String licensorIpId;
  final BigInt amount;
  final String receiver;
  final Uint8List royaltyContext;

  IPLease({
    required this.policyId,
    required this.licensorIpId,
    required this.amount,
    required this.receiver,
    required this.royaltyContext,
  });
  IPLease copyWith({
    BigInt? policyId,
    String? licensorIpId,
    BigInt? amount,
    String? receiver,
    Uint8List? royaltyContext,
  }) {
    return IPLease(
      policyId: policyId ?? this.policyId,
      licensorIpId: licensorIpId ?? this.licensorIpId,
      amount: amount ?? this.amount,
      receiver: receiver ?? this.receiver,
      royaltyContext: royaltyContext ?? this.royaltyContext,
    );
  }

  static IPLease empty() {
    return IPLease(
      policyId: BigInt.zero,
      licensorIpId: '',
      amount: BigInt.zero,
      receiver: '',
      royaltyContext: Uint8List(0),
    );
  }
}

class MetadataV1 {
  final String name;
  final Uint8List hash;
  final int registrationDate;
  final String registrant;
  final String uri;

  MetadataV1({
    required this.name,
    required this.hash,
    required this.registrationDate,
    required this.registrant,
    required this.uri,
  });
  MetadataV1 copyWith({
    String? name,
    Uint8List? hash,
    int? registrationDate,
    String? registrant,
    String? uri,
  }) {
    return MetadataV1(
      name: name ?? this.name,
      hash: hash ?? this.hash,
      registrationDate: registrationDate ?? this.registrationDate,
      registrant: registrant ?? this.registrant,
      uri: uri ?? this.uri,
    );
  }

  // A method to generate an "empty" instance of MetadataV1
  static MetadataV1 empty() {
    return MetadataV1(
      name: '',
      hash: Uint8List(32), // Assuming a placeholder for a 32-byte array
      registrationDate: 0,
      registrant: '',
      uri: '',
    );
  }
}
