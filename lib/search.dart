// ignore_for_file: use_key_in_widget_constructors

import 'dart:convert';
import 'package:ammonite/videoplayer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:system_theme/system_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  List<dynamic> videos = [];
  List<dynamic> channels = [];
  bool loading = false;
  String errorMessage = '';
  bool showChannels = false;
  bool searchdone = false;
  String instanceURL = 'https://tilvids.com';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadInstanceURL();
  }

  Future<void> _loadInstanceURL() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      instanceURL = prefs.getString('instanceURL') ?? 'https://tilvids.com';
    });
  }

  Future<void> fetchVideos(String searchTerm) async {
    setState(() {
      loading = true;
    });
    try {
      final response = await http.get(Uri.parse(
          '$instanceURL/api/v1/search/videos?search=$searchTerm&count=15'));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> videosList = responseData['data'];
        setState(() {
          videos = videosList;
          loading = false;
          searchdone = true;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load videos: ${response.statusCode}';
          loading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching videos: $error';
        loading = false;
      });
    }
  }

  Future<void> fetchChannels(String searchTerm) async {
    setState(() {
      loading = true;
    });
    try {
      final response2 = await http.get(Uri.parse(
          '$instanceURL/api/v1/search/video-channels?search=$searchTerm'));
      if (response2.statusCode == 200) {
        final responseData2 = json.decode(response2.body);
        final List<dynamic> channelList = responseData2['data'];
        setState(() {
          channels = channelList;
          loading = false;
          showChannels = true;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching channels : $error';
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
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(30),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100.0),
                  color: const Color.fromARGB(255, 255, 255, 255),
                  border: Border.all(color: Colors.black),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.black),
                      onPressed: () {
                        final searchTerm = _searchController.text;
                        if (searchTerm.isNotEmpty) {
                          fetchVideos(searchTerm);
                          fetchChannels(searchTerm);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showChannels)
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Text(
                    'Channels',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(
                  height: 170,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: channels.length,
                    itemBuilder: (BuildContext context, int index) {
                      final channel = channels[index];
                      final ownerAccount = channel['ownerAccount'];
                      final List<dynamic> avatars = ownerAccount['avatars'];
                      final avatarPath =
                          avatars.isNotEmpty ? avatars[1]['path'] : '';
                      final avatar = '$instanceURL$avatarPath';
                      final channelname = ownerAccount['displayName'];

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(avatar),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              channelname,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        if (searchdone)
          const SliverToBoxAdapter(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text('Videos',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ))),
          ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              Divider(color: Color.fromARGB(255, r, g, b));
              if (index == 0) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  child: Text(
                    '',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              final video = videos[index];
              final thumbnailURL = video['previewPath'] != null
                  ? '$instanceURL${video['previewPath']}'
                  : '';
              final channelData = video['channel'];
              final channelName =
                  channelData != null ? channelData['displayName'] : '';
              final channelAvatar =
                  channelData != null && channelData['avatar'] != null
                      ? '$instanceURL${channelData['avatar']['path']}'
                      : '';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      final videoUrl = video['url'];
                      final videoId = video['id'];
                      if (videoUrl is String) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerPage(
                              videoId: videoId,
                              videoUrl: videoUrl,
                            ),
                          ),
                        );
                      } else {
                        print(errorMessage);
                      }
                    },
                    child: Image.network(
                      thumbnailURL,
                      width: double.maxFinite,
                      height: 240,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 6),
                    child: Row(
                      children: [
                        if (channelAvatar.isNotEmpty)
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(channelAvatar),
                          ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'RobotoMono',
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                              const SizedBox(height: 2),
                              if (channelName.isNotEmpty)
                                Text(
                                  '$channelName',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 53, top: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.thumb_up_outlined),
                        const SizedBox(width: 6),
                        Text('${video['likes'] ?? 0}'),
                        const SizedBox(width: 6),
                        const Icon(Icons.thumb_down_outlined),
                        const SizedBox(width: 6),
                        Text('${video['dislikes'] ?? 0}'),
                        const SizedBox(width: 8),
                        const Text('•'),
                        const SizedBox(width: 8),
                        Text('${video['views'] ?? 0} Views'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
            childCount: videos.length + 1,
          ),
        ),
      ]),
    );
  }
}
