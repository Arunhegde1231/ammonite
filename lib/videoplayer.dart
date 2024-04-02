import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

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
  late ChewieController _chewieController;
  String truncatedDescription = '';
  bool descriptionTileState = true;
  String name = '';
  bool _isInitialized = false;
  String channelName = '';
  String channelAvatar = '';
  bool _isPlayPauseVisible = false;
  Timer? _playPauseTimer;
  int duration = 0;

  @override
  void initState() {
    super.initState();
    _fetchVideoData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _playPauseTimer?.cancel();
    _chewieController.dispose();
    super.dispose();
  }

  void _togglePlayPauseVisibility() {
    setState(() {
      _isPlayPauseVisible = !_isPlayPauseVisible;
    });
  }

  void _startPlayPauseTimer() {
    _playPauseTimer = Timer(const Duration(seconds: 3), () {
      if (_isPlayPauseVisible) {
        _togglePlayPauseVisibility();
      }
    });
  }

  void _resetPlayPauseTimer() {
    _playPauseTimer?.cancel();
    _startPlayPauseTimer();
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
          truncatedDescription = responseData['truncatedDescription'] ?? '';
          duration = responseData['duration'];
          name = responseData['name'];
          channelName = responseData['channel']['name'];
          if (responseData['channel']['avatars'].isNotEmpty) {
            channelAvatar = responseData['channel']['avatars'][1]['path'];
          }
        });

        final playlistUrl =
            responseData['streamingPlaylists'][0]['playlistUrl'];
        _controller = VideoPlayerController.networkUrl(Uri.parse(playlistUrl))
          ..initialize().then((_) {
            setState(() {
              _isInitialized = true;
              _startPlayPauseTimer();
            });
          });
        _chewieController = ChewieController(
          allowFullScreen: true,
          allowedScreenSleep: true,
          allowMuting: true,
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
            DeviceOrientation.portraitDown,
            DeviceOrientation.portraitUp
          ],
          videoPlayerController: _controller,
          autoInitialize: true,
          autoPlay: true,
          showControls: true,
        );
        _chewieController.addListener(() {
          if (_chewieController.isFullScreen) {
            SystemChrome.setPreferredOrientations(
              [
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight
              ],
            );
          } else {
            SystemChrome.setPreferredOrientations(
              [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
            );
          }
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
      body: SafeArea(
        child: GestureDetector(
          onTap: _resetPlayPauseTimer,
          child: _isInitialized
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _controller.value.isInitialized
                          ? AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: Stack(
                                alignment: FractionalOffset.bottomCenter +
                                    const FractionalOffset(-0.1, -0.1),
                                children: [
                                  Chewie(controller: _chewieController)
                                ],
                              ))
                          : Container(),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Padding(padding: EdgeInsets.all(7.0)),
                          Flexible(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 7.0)),
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
                        ],
                      ),
                      const SizedBox(height: 10),
                      ExpansionTile(
                        title: const Text(
                          'Description',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              description,
                              style: const TextStyle(fontSize: 13),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
