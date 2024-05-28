import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ammonite/channelscreen.dart';
import 'package:ammonite/videocomments.dart';
import 'package:ammonite/videodescription.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_theme/system_theme.dart';
import 'package:video_player/video_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';

class VideoPlayerPage extends StatefulWidget {
  final int videoId;
  final String videoUrl;

  const VideoPlayerPage({
    Key? key,
    required this.videoId,
    required this.videoUrl,
  }) : super(key: key);

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  int likes = 0;
  int dislikes = 0;
  int views = 0;
  int followerCount = 0;
  String truncatedDescription = '';
  String description = '';
  String name = '';
  String channelRealName = '';
  String channelName = '';
  String channelAvatar = '';
  late VideoPlayerController _controller;
  late ChewieController _chewieController;
  bool _isInitialized = false;
  String instanceURL = 'https://tilvids.com';

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
    _fetchVideoData(); 
  }
  @override
  void dispose() {
    _controller.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  Future<void> _fetchVideoData() async {
    try {
      final videoResponse = await http
          .get(Uri.parse('$instanceURL/api/v1/videos/${widget.videoId}'));
      if (videoResponse.statusCode == 200) {
        final videoData = json.decode(videoResponse.body);
        setState(() {
          channelRealName = videoData['channel']['name'];
          likes = videoData['likes'] ?? 0;
          dislikes = videoData['dislikes'] ?? 0;
          views = videoData['views'] ?? 0;
          truncatedDescription = videoData['truncatedDescription'] ?? '';
          description = videoData['description'] ?? '';
          name = videoData['name'];
          channelName = videoData['channel']['displayName'];
          followerCount = videoData['account']['followersCount'];
          if (videoData['channel']['avatar'] != null &&
              videoData['channel']['avatar'].isNotEmpty) {
            channelAvatar = videoData['channel']['avatar']['path'];
          }

        });

        final playlistUrl = videoData['streamingPlaylists'][0]['playlistUrl'];
        _controller = VideoPlayerController.networkUrl(Uri.parse(playlistUrl))
          ..initialize().then((_) {
            setState(() {
              _isInitialized = true;
            });
          });
        _chewieController = ChewieController(
          allowFullScreen: true,
          allowedScreenSleep: true,
          allowMuting: true,
          videoPlayerController: _controller,
          autoInitialize: true,
          autoPlay: true,
          showControls: true,
        );
      } else {
        throw Exception('Failed to fetch video data');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching video data: $error');
      }
    }
  }

  void _showDownloadOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Download Options'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Quality:'),
                  ListTile(
                    title: Text('High Quality'),
                    onTap: () {
                      Navigator.of(context).pop();
                      // TODO: Add functionality to download high-quality video
                    },
                  ),
                  ListTile(
                    title: Text('Medium Quality'),
                    onTap: () {
                      Navigator.of(context).pop();
                      // TODO: Add functionality to download medium-quality video
                    },
                  ),
                  ListTile(
                    title: Text('Low Quality'),
                    onTap: () {
                      Navigator.of(context).pop();
                      // TODO: Add functionality to download low-quality video
                    },
                  ),
                  SizedBox(height: 20),
                  Text('Select Download Location:'),
                  ElevatedButton(
                    onPressed: () async {
                      List<Directory>? externalStorageDirectories =
                          await getExternalStorageDirectories();
                      if (externalStorageDirectories != null &&
                          externalStorageDirectories.isNotEmpty) {
                        String selectedFolder =
                            externalStorageDirectories.first.path;
                        setState(() {
                          // Handle selected folder path
                          print('Selected folder path: $selectedFolder');
                        });
                      }
                    },
                    child: Text('Select Folder'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
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
        canvasColor: Colors.transparent,
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
        body: SafeArea(
          child: GestureDetector(
            onTap: () {},
            child: _isInitialized
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _controller.value.isInitialized
                          ? AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: Stack(
                                alignment: FractionalOffset.bottomCenter +
                                    const FractionalOffset(-0.1, -0.1),
                                children: [
                                  Chewie(controller: _chewieController),
                                ],
                              ),
                            )
                          : Container(),
                      const SizedBox(
                        height: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(7.0),
                            child: GestureDetector(
                              onTap: () {
                                showModalBottomSheet<void>(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20.0))),
                                  backgroundColor: Colors.transparent,
                                  elevation: 5.0,
                                  enableDrag: true,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return VideoDescription(
                                        description: description);
                                  },
                                );
                              },
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(Icons.expand_more_rounded),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    truncatedDescription,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 7.0)),
                              const Icon(Icons.thumb_up_outlined),
                              const SizedBox(width: 6),
                              Text('$likes'),
                              const SizedBox(width: 20),
                              const Icon(Icons.thumb_down_outlined),
                              const SizedBox(width: 6),
                              Text('$dislikes'),
                              const SizedBox(width: 20),
                              const Text('•'),
                              const SizedBox(width: 8),
                              Text('$views Views'),
                              const SizedBox(width: 8),
                              const Text('•'),
                              const SizedBox(width: 8),
                              IconButton(
                                  padding: EdgeInsets.all(3),
                                  onPressed: () {
                                    Share.share(widget.videoUrl);
                                  },
                                  icon: FaIcon(FontAwesomeIcons.share)),
                              IconButton(
                                  padding: EdgeInsets.all(3),
                                  onPressed: _showDownloadOptions,
                                  icon: FaIcon(FontAwesomeIcons.download)),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 5, 8, 8),
                            child: TextButton(
                              style: ButtonStyle(
                                enableFeedback: true,
                                padding: WidgetStateProperty.all<EdgeInsets>(
                                  EdgeInsets.zero,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChannelScreen(
                                      channelDisplayName: channelName,
                                      channelName: channelRealName,
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          '$instanceURL/$channelAvatar',
                                        ),
                                        radius: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          channelName,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 5, 8, 8),
                            child: GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    elevation: 5.0,
                                    enableDrag: true,
                                    builder: (BuildContext context) {
                                      return VideoComments(
                                          videoId: widget.videoId);
                                    });
                              },
                              child: const Row(
                                children: [
                                  Text(
                                    'Comments',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Icon(Icons.expand_more_rounded),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}
