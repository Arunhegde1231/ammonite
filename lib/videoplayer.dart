import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:path_provider/path_provider.dart';

class VideoPlayerPage extends StatefulWidget {
  final int videoId;

  const VideoPlayerPage({
    Key? key,
    required this.videoId,
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
  String name = '';
  String channelName = '';
  String channelAvatar = '';
  late VideoPlayerController _controller;
  late ChewieController _chewieController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
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
      final videoResponse = await http.get(
          Uri.parse('https://www.tilvids.com/api/v1/videos/${widget.videoId}'));
      if (videoResponse.statusCode == 200) {
        final videoData = json.decode(videoResponse.body);
        setState(() {
          likes = videoData['likes'] ?? 0;
          dislikes = videoData['dislikes'] ?? 0;
          views = videoData['views'] ?? 0;
          truncatedDescription = videoData['truncatedDescription'] ?? '';
          name = videoData['name'];
          channelName = videoData['channel']['displayName'];
          followerCount = videoData['account']['followersCount'];
          if (videoData['channel']['avatar'].isNotEmpty) {
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
    return Scaffold(
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
                            child: Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.fromLTRB(0, 5, 7, 7),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 7.0)),
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
                                      onPressed: () {},
                                      icon: Icon(Icons.share_outlined)),
                                  IconButton(
                                      padding: EdgeInsets.all(3),
                                      onPressed: _showDownloadOptions,
                                      icon: Icon(Icons.download_outlined)),
                                ],
                              )),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 5, 8, 8),
                            child: TextButton(
                              style: ButtonStyle(
                                enableFeedback: true,
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                  EdgeInsets.zero,
                                ),
                              ),
                              onPressed: () {}, //TODO: add actions later
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          'https://tilvids.com$channelAvatar',
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
                          )
                        ],
                      ),
                    ])
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
/*

 */
