/*import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:system_theme/system_theme.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

const List<String> selection = <String>['Videos', 'Playlists'];
const int pageSize = 10;

class ChannelVideos extends StatefulWidget {
  final String channelName;
  final String channelDisplayName;

  const ChannelVideos({
    Key? key,
    required this.channelName,
    required this.channelDisplayName,
  });
  @override
  State<ChannelVideos> createState() => _ChannelVideosState();
}

class _ChannelVideosState extends State<ChannelVideos> {
  List<dynamic> videos = [];
  bool loading = true;
  String errorMessage = '';
  final ScrollController _scrollController = ScrollController();
  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 0);
  bool _isVisible = true;

  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      fetchChannelVideos(pageKey);
    });
  }

  Future<void> fetchChannelVideos(int pageKey) async {
    try {
      final response = await http.get(Uri.parse(
          'https://tilvids.com/api/v1/video-channels/${widget.channelName}/videos?start=$pageKey&&count=$pageSize}'));
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
        _pagingController.error = 'Failed to load ${response.statusCode}';
      }
    } catch (err) {
      _pagingController.error = 'error fetching videos $err';
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
          title: Text(''),
        ),
        body: RefreshIndicator(
          onRefresh: () => Future.sync(
            () => _pagingController.refresh(),
          ),
          child: PagedListView<int, dynamic>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<dynamic>(
                  itemBuilder: (context, video, index) {
                final thumbnailURL = video[''];
              })),
        ),
      ),
    );
  }
}
*/