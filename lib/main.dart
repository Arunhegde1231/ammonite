import 'package:ammonite/discover.dart';
import 'package:ammonite/home.dart';
import 'package:ammonite/trending.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 209, 116, 225), brightness: Brightness.light,),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 125, 66, 227), brightness: Brightness.dark,),
      ),
      themeMode: ThemeMode.system,
      routes: {
        '/': (context) => Homescreen(),
        '/discover': (context) => DiscoverScreen(),
        '/trending': (context) => TrendingScreen(),
      },
    );
  }
}
