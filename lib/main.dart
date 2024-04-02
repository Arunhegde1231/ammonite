// ignore_for_file: use_key_in_widget_constructors

import 'package:ammonite/library.dart';
import 'package:ammonite/notifications.dart';
import 'package:flutter/material.dart';
import 'package:ammonite/discover.dart';
import 'package:ammonite/home.dart';
import 'package:ammonite/search.dart';
import 'package:system_theme/system_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemTheme.accentColor.load();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const Homescreen(),
    const DiscoverScreen(),
    const SearchScreen(),
    const NotificationScreen(),
    const LibraryScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/discover');
        break;
      case 2:
        Navigator.pushNamed(context, '/search');
        break;
      case 3:
        Navigator.pushNamed(context, '/notifications');
        break;
      case 4:
        Navigator.pushNamed(context, '/library');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentcolor = SystemTheme.accentColor.accent;
    int r = accentcolor.red;
    int g = accentcolor.green;
    int b = accentcolor.blue;
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, r, g, b),
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, r, g, b),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: Scaffold(
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: NavigationBar(
          destinations: const <NavigationDestination>[
            NavigationDestination(
                selectedIcon: Icon(Icons.home),
                icon: Icon(Icons.home_outlined),
                label: "Home"),
            NavigationDestination(
                selectedIcon: Icon(Icons.explore),
                icon: Icon(Icons.explore_outlined),
                label: "Discover"),
            NavigationDestination(
                selectedIcon: Icon(Icons.search_rounded),
                icon: Icon(Icons.search_outlined),
                label: "Search"),
            NavigationDestination(
                selectedIcon: Icon(Icons.notifications),
                icon: Icon(Icons.notifications_outlined),
                label: "Notifications"),
            NavigationDestination(
                selectedIcon: Icon(Icons.folder),
                icon: Icon(Icons.folder_outlined),
                label: "Library"),
          ],
          onDestinationSelected: _onItemTapped,
          selectedIndex: _selectedIndex,
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
