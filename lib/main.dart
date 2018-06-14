import 'package:flutter/material.dart';
import './login_page.dart';
import 'launch_page.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final sandColor = const Color(0xFFE4DACE);
  final medallionColor = const Color(0xFFE5BB4B);
  final blueColor = const Color(0xFF4C8EB0);
  final spiceColor = const Color(0xFF631E17);


  @override
  Widget build(BuildContext context) {
    
    return new MaterialApp(
      title: 'Clan Photos',
      home: new LaunchPage(),
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.

        canvasColor: sandColor,
        scaffoldBackgroundColor: sandColor,
        splashColor: spiceColor,
      ),
      
    );
  }
}


