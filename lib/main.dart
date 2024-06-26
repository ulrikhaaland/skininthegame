import 'package:flutter/material.dart';
import 'package:yadda/root_page.dart';
import 'package:yadda/auth.dart';
import 'package:yadda/utils/uidata.dart';
import 'package:yadda/pages/bottomNavigation/second_tab/game_page.dart';
import 'service/service_provider.dart';
import 'service/screen_service.dart';

void main() {
  ServiceProvider.instance.screenService = ScreenService();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      color: UIData.darkest,
      title: 'Preflop',
      theme: new ThemeData(
          // dialogTheme: DialogTheme(
          //     elevation: 1,
          //     // backgroundColor: UIData.dark,
          //     titleTextStyle: TextStyle(
          //         color: UIData.blackOrWhite, fontSize: UIData.fontSize20),
          //     contentTextStyle: TextStyle(color: UIData.blackOrWhite)),
          tabBarTheme: TabBarTheme(
              labelColor: UIData.blackOrWhite,
              unselectedLabelColor: Colors.grey[600]),
          scaffoldBackgroundColor: UIData.dark,
          buttonColor: Colors.yellow[700],
          inputDecorationTheme: InputDecorationTheme(
            counterStyle: TextStyle(color: Colors.grey[600]),
          )),
      home: new RootPage(auth: new Auth()),
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        "/login": (BuildContext context) => GamePage(),
      },
    );
  }
}
