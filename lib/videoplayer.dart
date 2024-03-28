import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final int videoId;

  const VideoPlayerPage({
    Key? key,
    required this.videoUrl,
    required this.videoId,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  int likes = 0;
  int dislikes = 0;
  int views = 0;
  String description = '';
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'))
      ..initialize().then((_) {
        setState(() {});
      });
    fetchVideoData();
  }

  Future<void> initializeVideo() async {
    await _controller.initialize();
    setState(() {});
  }

  Future<void> fetchVideoData() async {
    try {
      final response = await http.get(
          Uri.parse('https://tilvids.com/api/v1/videos/${widget.videoId}'));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          likes = responseData['likes'] ?? 0;
          dislikes = responseData['dislikes'] ?? 0;
          views = responseData['views'] ?? 0;
          description = responseData['description'] ?? '';
        });
      } else {
        if (kDebugMode) {
          print('Failed to fetch video data: ${response.statusCode}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching video data: $error');
      }
    }
  }

  /*Future<void> fetchVideoComments() async {
    try {
      final response = await http.get(Uri.parse('https://tilvids.com/api/v1/videos/${widget.videoId}/comment-threads'));
      if (response.statusCode == 200) {
        final responseData1 = json.decode(response.body);
        setState(() {

        });
      } else {
        if (kDebugMode) {
          print('Failed to fetch video data: ${response.statusCode}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching video data: $error');
      }
    }
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : Container(),
            FloatingActionButton(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Icon(Icons.thumb_up_outlined),
                  Text('Likes: $likes'),
                  const Icon(Icons.thumb_down_outlined),
                  Text('Dislikes: $dislikes'),
                  Text('Views: $views'),
                ],
              ),
            ),
            ExpansionTile(
              title: const Text('Description'),
              collapsedShape: const BeveledRectangleBorder(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    description,
                  ),
                ),
              ],
            ),
            const ExpansionTile(
              title: Text('Comments'),
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text('A'),
                  ),
                  title: Text('User A'),
                  subtitle: Text('Comment 1'),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Text('B'),
                  ),
                  title: Text('User B'),
                  subtitle: Text('Comment 2'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
