import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  List<dynamic> videos = [];
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
      final response = await http.get(Uri.parse('https://tilvids.com/api/v1/search/videos?search=$searchTerm&count=10'));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true, 
            snap: true,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(30),
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
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final video = videos[index];
                final thumbnailURL = video['previewPath'] != null ? 'https://tilvids.com${video['previewPath']}' : '';
                final channelData = video['channel'];
                final channelName = channelData != null ? channelData['displayName'] : '';
                final channelAvatar = channelData != null && channelData['avatar'] != null ? 'https://tilvids.com${channelData['avatar']['path']}' : '';
                final likes = video['likes'] ?? 0;
                final dislikes = video['dislikes'] ?? 0;
                final views = video['views'] ?? 0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          const SizedBox(width: 6),
                          Text('$likes'),
                          const SizedBox(width: 6),
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
                  ],
                );
              },
              childCount: videos.length,
            ),
          ),
        ],
      )
    );
  }
}

