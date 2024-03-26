// ignore_for_file: library_private_types_in_public_api

import 'package:ammonite/videoplayer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoryVideosScreen extends StatefulWidget {
  final String category;

  const CategoryVideosScreen({required this.category});

  @override
  _CategoryVideosScreenState createState() => _CategoryVideosScreenState();
}

class _CategoryVideosScreenState extends State<CategoryVideosScreen> {
  List<dynamic> videos = [];
  bool loading = true;
  String errorMessage = '';
  int currentPage = 1;
  final int videosPerPage = 10;
  final ScrollController _scrollController = ScrollController();
  bool isFetchingMore = false; // Flag to track if more data is being fetched

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    setState(() {
      loading = true;
    });
    try {
      final response =
          await http.get(Uri.parse('https://tilvids.com/api/v1/videos?count=100'));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> videosList = responseData['data'];
        setState(() {
          videos = videosList
              .where((video) => video['category']['label'] == widget.category)
              .toList();
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
      appBar: AppBar(
        title: Text('Videos - ${widget.category}'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : videos.isEmpty
                  ? const Center(child: Text('No videos found'))
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: videos.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index < videos.length) {
                          final video = videos[index];
                          final channelName =
                              'https://tilvids.com${video['channel']['displayName']}';
                          final thumbnailURL =
                              'https://tilvids.com${video['previewPath']}';
                          final channelAvatar = video['account']['avatar'] !=
                                  null
                              ? 'https://tilvids.com${video['account']['avatar']['path']}'
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
                                            videoUrl: videoUrl,
                                            videoId: videoId),
                                      ),
                                    );
                                  } else {
                                    if (kDebugMode) {
                                      print(errorMessage);
                                    }
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
                                padding:
                                    const EdgeInsets.only(top: 10, left: 6),
                                child: Row(
                                  children: [
                                    if (channelAvatar.isNotEmpty)
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage:
                                            NetworkImage(channelAvatar),
                                      ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                              channelName,
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
                                padding:
                                    const EdgeInsets.only(left: 53, top: 6),
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
                        }
                        return null; 
                      },
                    ),
    );
  }
}
