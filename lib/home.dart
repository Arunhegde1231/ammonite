import 'dart:convert';
import 'package:ammonite/videoplayer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;

class Homescreen extends StatefulWidget {
  const Homescreen({Key? key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  List<dynamic> videos = [];
  bool loading = true;
  String errorMessage = '';

  final ScrollController _scrollController = ScrollController();
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    fetchVideos();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final isScrolledToTop = _scrollController.position.pixels <= 0;

    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      // Scrolling up
      setState(() {
        _isVisible = !isScrolledToTop;
      });
    } else {
      // Scrolling down
      setState(() {
        _isVisible = false;
      });
    }
  }
  Future<void> _refreshVideos() async {
    await fetchVideos();
  }

  Future<void> fetchVideos() async {
    setState(() {
      loading = true;
    });
    try {
      final response = await http.get(Uri.parse('https://tilvids.com/api/v1/videos?count=50'));
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
      if (kDebugMode) {
        print('Error fetching videos: $error');
      }
      setState(() {
        errorMessage = 'Error fetching videos $error';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshVideos,
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: <Widget>[
                const SliverAppBar(
                  title: Text('Home'),
                  floating: true,
                  snap: true,
                ),
                loading
                    ? const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : errorMessage.isNotEmpty
                        ? SliverFillRemaining(
                            child: Center(child: Text(errorMessage)),
                          )
                        : videos.isEmpty
                            ? const SliverFillRemaining(
                                child: Center(child: Text('No videos found')),
                              )
                            : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    final video = videos[index];
                                    final thumbnailURL = 'https://tilvids.com${video['previewPath']}';
                                    final channelData = video['channel'];
                                    final channelName = channelData != null ? channelData['displayName'] : '';
                                    final channelAvatar = channelData != null ? 'https://tilvids.com${channelData['avatar']['path']}' : '';
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                        onTap: () {
                                          final videoUrl = video['url'];
                                          final videoId= video['id'];
                                          if (videoUrl is String) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => VideoPlayerPage(videoUrl: videoUrl, videoId: videoId),
                                              ),
                                            );
                                          } else {
                                            // Handle case where video URL is not a string
                                            // This could be showing an error message or performing a fallback action
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
                                  childCount: videos.length,
                                ),
                              ),
              ],
            ),
            Positioned(
              bottom: 16.0,
              right: 16.0,
              child: Visibility(
                visible: !_isVisible,
                child: FloatingActionButton(
                  backgroundColor: const Color.fromARGB(255, 229, 209, 236),
                  onPressed: () {
                    _scrollController.animateTo(
                      0.0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                    );
                  },
                  child: const Icon(Icons.keyboard_arrow_up, color: Color.fromARGB(255, 91, 28, 114),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
