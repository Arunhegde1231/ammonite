import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//import 'package:system_theme/system_theme.dart';

class searchScreen extends StatefulWidget {
  const searchScreen({Key? key});

  @override
  State<searchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<searchScreen> {
  late TextEditingController _searchController;
  List<dynamic> videos = [];
  List<dynamic> channels = [];
  bool loading = false;
  String errorMessage = '';
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  Future<void> fetchVideos(String searchTerm) async {
    setState(() {
      loading = true;
    });
    try {
      final response = await http.get(Uri.parse(
          'https://tilvids.com/api/v1/search/videos?search=$searchTerm&count=15'));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> videosList = responseData['data'];
        setState(() {
          videos = videosList;
          loading = false;
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
          'https://tilvids.com/api/v1/search/video-channels?search=$searchTerm'));
      if (response2.statusCode == 200) {
        final responseData2 = json.decode(response2.body);
        final List<dynamic> channelList = responseData2['data'];
        setState(() {
          channels = channelList;
          loading = false;
        });
        setState(() {
          channels = channelList;
          loading = false;
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
                      overflow: TextOverflow.ellipsis),
                ),
              ),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: channels.length,
                  itemBuilder: (BuildContext context, int index) {
                    final channel = channels[index];
                    final avatar = 'https://tilvids.com${channel['avatar']}';
                    final channelname = channel['displayName'];
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
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final video = videos[index];
              final thumbnailURL = video['previewPath'] != null
                  ? 'https://tilvids.com${video['previewPath']}'
                  : '';
              final channelData = video['channel'];
              final channelName =
                  channelData != null ? channelData['displayName'] : '';
              final channelAvatar =
                  channelData != null && channelData['avatar'] != null
                      ? 'https://tilvids.com${channelData['avatar']['path']}'
                      : '';
              final likes = video['likes'] ?? 0;
              final dislikes = video['dislikes'] ?? 0;
              final views = video['views'] ?? 0;

              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (index == 0)
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        child: Text(
                          'Videos',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (thumbnailURL.isNotEmpty)
                      Image.network(
                        thumbnailURL,
                        width: double.maxFinite,
                        height: 240,
                        fit: BoxFit.fill,
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
                          const SizedBox(width: 8),
                          Text('$likes'),
                          const SizedBox(width: 8),
                          const Icon(Icons.thumb_down_outlined),
                          const SizedBox(width: 6),
                          Text('$dislikes'),
                          const SizedBox(width: 8),
                          const Text('•'),
                          const SizedBox(width: 8),
                          Text('$views Views'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ]);
            },
            childCount: videos.length,
          ),
        ),
      ]),
    );
  }
}
