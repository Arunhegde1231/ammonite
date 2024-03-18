import 'dart:convert';
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

  @override
  void initState() {
    super.initState();
    fetchVideos();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      // Scrolling up
      setState(() {
        _isVisible = true;
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
      final response = await http.get(Uri.parse('https://tilvids.com/api/v1/videos'));
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

  bool _isVisible = true;

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
        ],
        onDestinationSelected: (int index){
          switch(index){
            case 0:
            Navigator.pushNamed(context, '/home');
            case 1:
            Navigator.pushNamed(context, '/discover');
          }
        },
      ),
      body: RefreshIndicator(
        onRefresh: _refreshVideos,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            const SliverAppBar(
              title: Text('Home'),
              floating: true,
              snap: true,
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Visibility(
                  visible: _isVisible,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    child: Row(
                      children: [
                        _buildFloatingButton('Home', Icons.home_rounded, '/home'),
                        _buildFloatingButton('Trending', Icons.trending_up_rounded,'/trending'),
                        _buildFloatingButton('Recent', Icons.add_circle_rounded,''),
                        _buildFloatingButton('Local', Icons.location_pin,''),
                      ],
                    ),
                  ),
                ),
              ),
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
      ),
    );
  }

  Widget _buildFloatingButton(String label, IconData iconData, String routeName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        child: SizedBox(
          height: 36,
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(context, routeName);
            },
            label: Text(label),
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
