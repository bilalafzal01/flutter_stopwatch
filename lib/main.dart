import 'package:chapter5/login_screen.dart';
import 'package:chapter5/stopwatch.dart';
import 'package:flutter/material.dart';

void main() => runApp(const StopwatchApp());

class StopwatchApp extends StatelessWidget {
  const StopwatchApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => LoginScreen(),
        LoginScreen.route: (context) => LoginScreen(),
        StopWatch.route: (context) => StopWatch(),
      },
      initialRoute: '/',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
    );
  }
}
