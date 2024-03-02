import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stosp/ui/viewmodels/chat/chat_viewmodel.dart';
import 'package:stosp/ui/widgets/button/text_button_with_border_widget.dart';
import 'package:stosp/utils/app_colors.dart';
import 'package:stosp/utils/size_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

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
      home: const HomeWidgetView(),
    );
  }
}

class HomeWidgetView extends StatefulWidget {
  const HomeWidgetView({super.key});

  @override
  State<StatefulWidget> createState() {
   return _HomeViewWidgetView();
  }

}
class _HomeViewWidgetView extends State<HomeWidgetView> {
  final fakeIps = List<IP>.generate(10, (_) => IP.generateFake());
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
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
                  fakeIps.length,
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
                                color:
                                AppColors.darkGrey.withOpacity(0.1),
                              ),
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(20)),
                            ),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: Image(
                              image: CachedNetworkImageProvider(
                                  fakeIps[index].url),
                            )),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: SizeConfig.safeBlockVertical * 1,
                            horizontal:
                            SizeConfig.safeBlockHorizontal * 1,
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    right:
                                    SizeConfig.safeBlockHorizontal *
                                        1),
                                child: const Icon(Icons.book),
                              ),
                              Text(
                                fakeIps[index].name,
                                style: TextStyle(
                                    fontSize:
                                    SizeConfig().getTextSize(11),
                                    fontFamily: "RobotoRegular"),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: SizeConfig.safeBlockVertical * 1,
                            horizontal:
                            SizeConfig.safeBlockHorizontal * 1,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Description",
                                  style: TextStyle(
                                      fontSize:
                                      SizeConfig().getTextSize(11),
                                      fontFamily: "RobotoRegular")),
                              Text(fakeIps[index].description,
                                  style: TextStyle(
                                      fontSize:
                                      SizeConfig().getTextSize(11),
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

        ],
      ),
    ));
  }

}
Future<void> loadData() async {
  final jsonString = await rootBundle.loadString('assets/data.json');
  final Map<String, dynamic> jsonData = json.decode(jsonString);
  final List<IP> ownedIPs;
}
