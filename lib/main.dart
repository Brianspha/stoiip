import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web3/ethereum.dart';
import 'package:one_context/one_context.dart';
import 'package:stosp/ui/views/chat/chat_view.dart';
import 'package:stosp/utils/app_colors.dart';
import 'package:stosp/utils/app_navigator.dart';
import 'package:stosp/utils/locator.dart';
import 'package:stosp/utils/size_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Gemini.init(apiKey: 'AIzaSyAtkA4-CX_uByvAbqBhyBei1L-9JPmjnPs');
  setupLocator();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      showSemanticsDebugger: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
          useMaterial3: true,
        ),
        home: ChatView(),
        navigatorKey: AppNavigator.navigationKey,
        builder: (BuildContext context, Widget? widget) {
          SizeConfig().init(context);
          return OneContext().builder(context, widget);
        });
  }

  // This widget is the root of your application.
}
