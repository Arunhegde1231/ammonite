import 'package:ammonite/discover.dart';
import 'package:ammonite/home.dart';
import 'package:ammonite/trending.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => Homescreen(),
        '/discover': (context) => DiscoverScreen(),
        '/trending': (context) => TrendingScreen(),
      },
    );
  }
}
