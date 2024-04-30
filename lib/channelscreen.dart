import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';

class ChannelScreen extends StatefulWidget {
  const ChannelScreen({Key? key});
  @override
  State<ChannelScreen> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
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
        body: SafeArea(
          child: GestureDetector(),
        ),
      ),
    );
  }
}
