import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;


class VideoPlayerPage extends StatefulWidget {
  final int videoId;

  const VideoPlayerPage({
    Key? key,
    required this.videoId,
    required String videoUrl,
  }) : super(key: key);

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  int likes = 0;
  int dislikes = 0;
  int views = 0;
  String description = '';
  late VideoPlayerController _controller;
  String name = '';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _fetchVideoData();
  }

  Future<void> _fetchVideoData() async {
    try {
      final response = await http.get(
          Uri.parse('https://www.tilvids.com/api/v1/videos/${widget.videoId}'));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          likes = responseData['likes'] ?? 0;
          dislikes = responseData['dislikes'] ?? 0;
          views = responseData['views'] ?? 0;
          description = responseData['description'] ?? '';
          name = responseData['name'];
        });

        final playlistUrl =
            responseData['streamingPlaylists'][0]['playlistUrl'];
        _controller = VideoPlayerController.networkUrl(Uri.parse(playlistUrl))
          ..initialize().then((_) {
            setState(() {
              _isInitialized = true;
            });
          });
      } else {
        throw Exception('Failed to fetch video data: ${response.statusCode}');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching video data: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          name,
          style: const TextStyle(
              fontSize: 15.0,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: _isInitialized
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(_controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow),
                        onPressed: () {
                          setState(() {
                            _controller.value.isPlaying
                                ? _controller.pause()
                                : _controller.play();
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.stop),
                        onPressed: () {
                          setState(() {
                            _controller.pause();
                            _controller.seekTo(Duration.zero);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
