// ignore_for_file: use_key_in_widget_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TrendingScreenState createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  List<dynamic> trendingVideos = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchTrendingVideos();
  }

  Future<void> fetchTrendingVideos() async {
    setState(() {
      loading = true;
    });

    try {
      final response = await http.get(Uri.parse('https://tilvids.com/api/v1/videos/trending'));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> trendingVideosList = responseData['data'];
        setState(() {
          trendingVideos = trendingVideosList;
          loading = false;
        });
      } else {
        print('Failed to load trending videos: ${response.statusCode}');
        setState(() {
          loading = false;
        });
      }
    } catch (error) {
      print('Error fetching trending videos: $error');
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Trending'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : trendingVideos.isEmpty
              ? const Center(child: Text('No trending videos found'))
              : ListView.builder(
                  itemCount: trendingVideos.length,
                  itemBuilder: (context, index) {
                    final video = trendingVideos[index];
                    final thumbnailURL = 'https://tilvids.com${video['previewPath']}';
                    return ListTile(
                      leading: Image.network(
                        thumbnailURL,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      title: Text(video['name'] ?? ''),
                      subtitle: Text(video['description'] ?? ''),
                      // Add more details as needed
                    );
                  },
                ),
    );
  }
}
