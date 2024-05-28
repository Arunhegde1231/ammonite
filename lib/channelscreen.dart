import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const List<String> selection = <String>['Videos', 'Playlists'];

class ChannelScreen extends StatefulWidget {
  const ChannelScreen({
    Key? key,
    required this.channelDisplayName,
    required this.channelName,
  }) : super(key: key);

  final String channelDisplayName;
  final String channelName;

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
  List<dynamic> videos = [];
  bool loading = true;
  String errorMessage = '';
  String instanceURL = 'https://tilvids.com'; // Default instance URL

  @override
  void initState() {
    super.initState();
    _loadInstanceURL();
  }

  Future<void> _loadInstanceURL() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      instanceURL = prefs.getString('instanceURL') ?? 'https://tilvids.com';
    });
    _loadChannelDetails();
  }

  Future<void> _loadChannelDetails() async {
    try {
      final response = await http.get(Uri.parse(
          '$instanceURL/api/v1/video-channels/${widget.channelName}'));
      if (response.statusCode == 200) {
        final channelData = json.decode(response.body);
        setState(() {
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
          if (channelData['avatars'].isNotEmpty) {
            channelAvatar = channelData['avatars'][1]['path'];
          } else {
            channelAvatar = channelData['avatar']['path'];
          }
          loading = false;

          print('Channel Banner URL: $instanceURL$channelBanner');
          print('Channel Avatar URL: $instanceURL$channelAvatar');
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
          title: Text(widget.channelDisplayName),
        ),
        body: loading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : RefreshIndicator(
                    onRefresh: _loadChannelDetails,
                    child: ListView(
                      children: [
                        if (channelBanner.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: Image.network(
                                '$instanceURL$channelBanner',
                                height: 130,
                                width: double.infinity,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              if (channelAvatar.isNotEmpty)
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    '$instanceURL$channelAvatar',
                                  ),
                                  radius: 30,
                                ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.channelDisplayName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      widget.channelName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
