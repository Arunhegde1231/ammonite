import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final int videoId;

  const VideoPlayerPage({
    Key? key,
    required this.videoUrl,
    required this.videoId,
  }) : super(key: key);

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  int likes = 0;
  int dislikes = 0;
  int views = 0;
  String description = '';

  @override
  void initState() {
    super.initState();
    fetchVideoData();
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
            Container(
              height: 250,
              color: Colors.grey[300], // Placeholder color
              child: const Center(
                child: Icon(
                  Icons.play_circle_filled,
                  size: 72,
                  color: Colors.grey,
                ),
              ),
            ),
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
