import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {},
          child: _isInitialized
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
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
