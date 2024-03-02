


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stosp/ui/viewmodels/chat/chat_viewmodel.dart';

import '../utils/locator.dart';

final  ChangeNotifierProvider<ChatViewModel>
chatViewProvider =
ChangeNotifierProvider<ChatViewModel>((ref) {
  return locator.get<ChatViewModel>();
});