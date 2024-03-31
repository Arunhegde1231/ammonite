import 'dart:convert';
import 'package:ammonite/categoryscreen.dart';
import 'package:ammonite/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:system_theme/system_theme.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen() : super();

  @override
  // ignore: library_private_types_in_public_api
  _DiscoverScreenState createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  List<Map<String, dynamic>> categoriesWithIcons = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    setState(() {
      loading = true;
    });

    try {
      final response = await http
          .get(Uri.parse('https://tilvids.com/api/v1/videos/categories'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          categoriesWithIcons = responseData.entries
              .map((entry) =>
                  {'name': entry.value, 'icon': _getIconForCategory(entry.key)})
              .toList();
          loading = false;
        });
      } else {
        // Handle error
        if (kDebugMode) {
          print('Failed to fetch categories: ${response.statusCode}');
        }
        setState(() {
          loading = false;
        });
      }
    } catch (error) {
      // Handle error
      if (kDebugMode) {
        print('Error fetching categories: $error');
      }
      setState(() {
        loading = false;
      });
    }
  }

  IconData _getIconForCategory(String categoryId) {
    switch (categoryId) {
      case '1':
        return Icons.music_note_outlined;
      case '2':
        return Icons.movie_outlined;
      case '3':
        return Icons.bike_scooter_outlined;
      case '4':
        return Icons.brush_outlined;
      case '5':
        return Icons.sports;
      case '6':
        return Icons.airplane_ticket_outlined;
      case '7':
        return Icons.games_outlined;
      case '8':
        return Icons.emoji_people_rounded;
      case '9':
        return Icons.theater_comedy_outlined;
      case '10':
        return Icons.tv_outlined;
      case '11':
        return Icons.newspaper_outlined;
      case '12':
        return Icons.settings_applications;
      case '13':
        return Icons.school_outlined;
      case '14':
        return Icons.volunteer_activism_outlined;
      case '15':
        return Icons.science_outlined;
      case '16':
        return Icons.forest_outlined;
      case '17':
        return Icons.child_friendly_outlined;
      case '18':
        return Icons.fastfood_rounded;
      default:
        return Icons.category;
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
        appBar: AppBar(
          title: const Text('Discover'),
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.settings_outlined),
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'account',
                  child: Text('Account'),
                ),
              ],
              onSelected: (String value) {
                if (value == 'account') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: ((context) => const SettingsScreen()),
                    ),
                  );
                }
              },
            ),
            PopupMenuButton(
              icon: const Icon(Icons.account_circle_outlined),
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'account',
                  child: Text('Account'),
                ),
              ],
              onSelected: (String value) {
                if (value == 'account') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: ((context) => const SettingsScreen()),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : categoriesWithIcons.isEmpty
                ? const Center(child: Text('No categories found'))
                : GridView.count(
                    crossAxisCount: 2,
                    children: List.generate(
                      categoriesWithIcons.length,
                      (index) => _buildCategoryButton(
                          categoriesWithIcons[index]['name'],
                          categoriesWithIcons[index]['icon']),
                    ),
                  ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _buildCategoryButton(String category, IconData iconData) {
    final accentcolor = SystemTheme.accentColor.accent;
    int r = accentcolor.red;
    int g = accentcolor.green;
    int b = accentcolor.blue;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        child: SizedBox(
          height: 36,
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CategoryVideosScreen(category: category),
                ),
              );
            },
            label: Text(category),
            icon: Icon(iconData),
            elevation: 5,
            backgroundColor: Color.fromARGB(255, r, g, b),
            foregroundColor: Colors.black,
          ),
        ),
      ),
    );
  }
}
