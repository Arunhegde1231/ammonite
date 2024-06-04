// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const List<String> selection = <String>['Videos', 'Playlists'];

class ChannelScreen extends StatefulWidget {
  const ChannelScreen({
    super.key,
    required this.channelDisplayName,
    required this.channelName,
  });

  final String channelDisplayName;
  final String channelName;

  @override
  State<ChannelScreen> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen>
    with SingleTickerProviderStateMixin {
  int followerCount = 0;
  int followingCount = 0;
  String description = '';
  String support = '';
  String accountURL = '';
  String channelBanner = '';
  String channelAvatar = '';
  String createdAt = '';
  String CreatedDate = '';
  List<dynamic> videos = [];
  bool loading = true;
  String errorMessage = '';
  String instanceURL = 'https://tilvids.com'; // Default instance URL
  late TabController tabController;

  final TextEditingController _instanceURLController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInstanceURL();
    tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _loadInstanceURL() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      instanceURL = prefs.getString('instanceURL') ?? 'https://tilvids.com';
      _instanceURLController.text =
          instanceURL; // Set the initial value for the TextField
    });
    _loadChannelDetails();
  }

  Future<void> _setInstanceURL(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('instanceURL', url);
    setState(() {
      instanceURL = url;
    });
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
          createdAt = channelData['createdAt'];
          CreatedDate = createdAt.substring(0, 9);
          description = channelData['description'] ?? '';
          support = channelData['support'] ?? '';
          accountURL = channelData['ownerAccount']?['url'] ?? '';

          if (channelData['banner'] != null &&
              channelData['banner']['path'] != null) {
            channelBanner = channelData['banner']['path'];
          } else if (channelData['banners'] != null &&
              channelData['banners'].isNotEmpty) {
            channelBanner = channelData['banners'][0]['path'];
          } else {
            channelBanner = 'assets/defaultavatarbanner/banner.jpg';
          }

          if (channelData['avatars'] != null &&
              channelData['avatars'].isNotEmpty) {
            channelAvatar = channelData['avatars'][1]['path'];
          } else if (channelData['avatar'] != null &&
              channelData['avatar']['path'] != null) {
            channelAvatar = channelData['avatar']['path'];
          } else {
            channelAvatar = 'assets/defaultavatarbanner/avatar.jpg';
          }

          loading = false;

          if (kDebugMode) {
            print('Channel Banner URL: $instanceURL$channelBanner');
            print('Channel Avatar URL: $instanceURL$channelAvatar');
          }
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to load channel details: ${response.statusCode}';
          loading = false;
        });
      }
    } catch (err) {
      if (kDebugMode) {
        print('Error in fetching channel details: $err');
      }
      setState(() {
        errorMessage = 'Failed to load channel details: $err';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = SystemTheme.accentColor.accent;
    int r = accentColor.red;
    int g = accentColor.green;
    int b = accentColor.blue;
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
          title: PopupMenuButton<int>(
              onSelected: (value) {},
              itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      enabled: false,
                      child: TextField(
                        controller: _instanceURLController,
                        decoration: InputDecoration(
                            labelText: 'Instance URL',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.save),
                              onPressed: () async {
                                await _setInstanceURL(
                                    _instanceURLController.text);
                                Navigator.pop(context);
                              },
                            )),
                      ),
                    )
                  ],
              child: Text(widget.channelDisplayName)),
          bottom: TabBar(
            controller: tabController,
            tabs: const [
              Tab(text: 'Videos'),
              Tab(text: 'Playlists'),
            ],
            labelColor: Colors.black,
          ),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
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
                              child: channelBanner.startsWith('assets')
                                  ? Image.asset(
                                      channelBanner,
                                      height: 130,
                                      width: double.infinity,
                                      fit: BoxFit.fill,
                                    )
                                  : Image.network(
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
                                  backgroundImage:
                                      channelAvatar.startsWith('assets')
                                          ? AssetImage(channelAvatar)
                                          : NetworkImage(
                                                  '$instanceURL$channelAvatar')
                                              as ImageProvider,
                                  radius: 30,
                                ),
                              const SizedBox(width: 10),
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
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IntrinsicWidth(
                                child: Card(
                                  surfaceTintColor: Colors.amber,
                                  elevation: 8.0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          child: Column(
                                            children: [
                                              Text(
                                                '$followerCount',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall,
                                              ),
                                              Text(
                                                'Followers',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const VerticalDivider(
                                          width: 15.0,
                                          thickness: 15.0,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          child: Column(
                                            children: [
                                              Text(
                                                '$followingCount',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall,
                                              ),
                                              Text(
                                                'Following',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 300,
                          child: TabBarView(
                            controller: tabController,
                            children: const [
                              Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Column(),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Column(),
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
