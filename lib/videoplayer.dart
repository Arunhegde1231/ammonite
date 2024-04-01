import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  final int videoId;

  const VideoPlayerPage({
    super.key,
    required this.videoId,
    required String videoUrl,
  });

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  int likes = 0;
  int dislikes = 0;
  int views = 0;
  String description = '';
  String truncatedDescription = '';
  bool descriptionTileState = true;
  late VideoPlayerController _controller;
  String name = '';
  bool _isInitialized = false;
  String channelName = '';
  String channelAvatar = '';

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
          truncatedDescription = responseData['truncatedDescription'] ?? '';
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
    final accentcolor = SystemTheme.accentColor.accent;
    int r = accentcolor.red;
    int g = accentcolor.green;
    int b = accentcolor.blue;
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: _isInitialized
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _controller.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        )
                      : Container(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: descriptionTileState
                              ? Text(truncatedDescription, overflow: TextOverflow.ellipsis)
                              : null,
                    onExpansionChanged: (state) {
                      setState(() {
                        descriptionTileState = !state;
                      });
                    },
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
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
