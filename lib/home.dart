// ignore_for_file: use_key_in_widget_constructors

import 'dart:convert';
import 'package:ammonite/settings.dart';
import 'package:ammonite/videoplayer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:system_theme/system_theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

const List<String> list = <String>['Latest', 'Trending', 'Local Videos'];
const int pageSize = 50;

class Homescreen extends StatefulWidget {
  const Homescreen({Key? key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      fetchVideos(pageKey);
    });
  }

  Future<void> fetchVideos(int pageKey) async {
    try {
      final response = await http.get(Uri.parse(
          'https://tilvids.com/api/v1/videos?start=$pageKey&&count=$pageSize'));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> videosList = responseData['data'];
        final isLastPage = videosList.length < pageSize;
        if (isLastPage) {
          _pagingController.appendLastPage(videosList);
        } else {
          final nextPageKey = pageKey + pageSize;
          _pagingController.appendPage(videosList, nextPageKey);
        }
      } else {
        _pagingController.error =
            'Failed to load videos: ${response.statusCode}';
      }
    } catch (error) {
      _pagingController.error = 'Error fetching videos $error';
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentcolor = SystemTheme.accentColor.accent;
    int r = accentcolor.red;
    int g = accentcolor.green;
    int b = accentcolor.blue;
    return MaterialApp(
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
          title: const Text('Home'),
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.settings_outlined),
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'account',
                  child: Text('Account'),
                ),
              ],
              onSelected: (String value) {
                if (value == 'account') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: ((context) => const SettingsScreen()),
                    ),
                  );
                }
              },
            ),
            PopupMenuButton(
              icon: const Icon(Icons.account_circle_outlined),
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'account',
                  child: Text('Account'),
                ),
              ],
              onSelected: (String value) {
                if (value == 'account') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: ((context) => const SettingsScreen()),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => Future.sync(
            () => _pagingController.refresh(),
          ),
          child: PagedListView<int, dynamic>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<dynamic>(
              itemBuilder: (context, video, index) {
                final thumbnailURL = video['previewPath'] != null
                    ? 'https://tilvids.com${video['previewPath']}'
                    : '';

                final channelData = video['channel'];
                final channelName =
                    channelData != null && channelData['displayName'] != null
                        ? channelData['displayName']
                        : '';

                final channelAvatar = channelData != null &&
                        channelData['avatar'] != null &&
                        channelData['avatar']['path'] != null
                    ? 'https://tilvids.com${channelData['avatar']['path']}'
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
                          if (kDebugMode) {
                            print('Invalid video URL');
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
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
