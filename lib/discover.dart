import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen() : super();

  @override
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
      final response = await http.get(Uri.parse('https://tilvids.com/api/v1/videos/categories'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          categoriesWithIcons = responseData.entries
              .map((entry) => {'name': entry.value, 'icon': _getIconForCategory(entry.key)})
              .toList();
          loading = false;
        });
      } else {
        // Handle error
        print('Failed to fetch categories: ${response.statusCode}');
        setState(() {
          loading = false;
        });
      }
    } catch (error) {
      // Handle error
      print('Error fetching categories: $error');
      setState(() {
        loading = false;
      });
    }
  }

  IconData _getIconForCategory(String categoryId) {
    switch(categoryId){
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
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: "Home"
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.explore),
            icon: Icon(Icons.explore_outlined),
            label: "Discover"
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.search_rounded),
            icon: Icon(Icons.search_outlined),
            label: "Search"
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.notifications),
            icon: Icon(Icons.notifications_outlined),
            label: "Notifications"
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.folder),
            icon: Icon(Icons.folder_outlined),
            label: "Library"
          ),
        ]
      ),
      appBar: AppBar(
        title: const Text('Discover'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : categoriesWithIcons.isEmpty
              ? const Center(child: Text('No categories found'))
              : GridView.count(
                  crossAxisCount: 2,
                  children: List.generate(
                    categoriesWithIcons.length,
                    (index) => _buildCategoryButton(categoriesWithIcons[index]['name'], categoriesWithIcons[index]['icon']),
                  ),
                ),
    );
  }

  Widget _buildCategoryButton(String category, IconData iconData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(15),
        ),
        child: SizedBox(
          height: 36,
          child: FloatingActionButton.extended(
            onPressed: () {},
            label: Text(category),
            icon: Icon(iconData),
            elevation: 5,
            backgroundColor: Color.fromARGB(255, 229, 209, 236),
            foregroundColor: Colors.black,
          ),
        ),
      ),
    );
  }
}
