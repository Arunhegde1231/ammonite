import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';
import 'package:http/http.dart' as http;

const List<String> selection = <String>['Videos', 'Playlists'];

class ChannelScreen extends StatefulWidget {
  final String channelName;
  final String channelDisplayName;

  const ChannelScreen({
    Key? key,
    required this.channelName,
    required this.channelDisplayName,
  });
  @override
  State<ChannelScreen> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  int followerCount = 0;
  int followingCount = 0;
  String description = '';
  String support = '';
  String accountURL = '';
  String channelBanner = '';
  String channelAvatar = '';
  String channelName = '';
  String channelDisplayName = '';
  List<dynamic> videos = [];
  bool loading = true;
  String errorMessage = '';

  void initState() {
    super.initState();
    fetchChannelVideos();
  }

  Future<void> _refreshVideos() async {
    await fetchChannelVideos();
  }

  Future<void> fetchChannelVideos() async {
    setState(() {
      loading = true;
    });
    try {
      final response = await http.get(Uri.parse(
          'https://tilvids.com/api/v1/video-channels/${widget.channelName}'));
      if (response.statusCode == 200) {
        final channelData = json.decode(response.body);
        setState(() {
          channelName = channelData['name'];
          channelDisplayName = channelData['displayName'];
          followerCount = channelData['followersCount'];
          followingCount = channelData['followingCount'];
          description = channelData['description'];
          support = channelData['support'];
          accountURL = channelData['ownerAccount']['url'];
          if (channelData['banner'].isNotEmpty) {
            channelBanner = channelData['banner']['path'];
          } else {
            channelBanner = channelData['banners'][0]['path'];
          }
          if (channelData['avatars'][1].isNotEmpty) {
            channelAvatar = channelData['avatars']['1']['path'];
          } else {
            channelAvatar = channelData['avatar']['path'];
          }
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load videos : ${response.statusCode}';
          loading = false;
        });
      }
    } catch (err) {
      if (kDebugMode) {
        print('Error in fetching videos: $err');
      }
      setState(() {
        errorMessage = 'Failed to load videos : $err';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentcolor = SystemTheme.accentColor.accent;
    int r = accentcolor.red;
    int g = accentcolor.green;
    int b = accentcolor.blue;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
            title: Text('$channelDisplayName'),
          ),
          body: const Center(
            child: Column(),
          )),
    );
  }
}
