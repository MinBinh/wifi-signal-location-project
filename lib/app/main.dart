import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//scenes
import 'scenes/LoadingScreen.dart';
import "WifiData.dart";
import "scenes/HomeScreen.dart";
import "scenes/Checkin.dart";
import "scenes/TeacherSelect.dart";
import "scenes/IfMeetingTeacher.dart";
import "scenes/NoWifi.dart";

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => WifiData(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: NoTransitionsBuilder(),
              TargetPlatform.iOS: NoTransitionsBuilder(),
            },
          ),
        ),
      home: LoadingScreen(),
      routes: {
        "/homescreen":(context) => const HomeScreen(),
        "/scan":(context)=> LoadingScreen(),
        "/askteacher":(context)=> IfMeetingTeacher(),
        "/teacherselect":(context)=> TeacherSelect(),
        "/check":(context) => Checkin(),
        "/nowifi":(context) => NoWifi(),
      }
    );
  }
}

class NoTransitionsBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return child; // no animation at all
  }
}