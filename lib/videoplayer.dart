import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

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
  List<CommentItem> comments = [];

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
      final videoResponse = await http.get(
          Uri.parse('https://www.tilvids.com/api/v1/videos/${widget.videoId}'));
      final commentsResponse = await http.get(Uri.parse(
          'https://www.tilvids.com/api/v1/videos/${widget.videoId}/comment-threads'));
      if (videoResponse.statusCode == 200 &&
          commentsResponse.statusCode == 200) {
        final videoData = json.decode(videoResponse.body);
        final commentsData = json.decode(commentsResponse.body);
        setState(() {
          likes = videoData['likes'] ?? 0;
          dislikes = videoData['dislikes'] ?? 0;
          views = videoData['views'] ?? 0;
          description = videoData['description'] ?? '';
          truncatedDescription = videoData['truncatedDescription'] ?? '';
          duration = videoData['duration'];
          name = videoData['name'];
          channelName = videoData['channel']['displayName'];
          if (videoData['channel']['avatar'].isNotEmpty) {
            channelAvatar = videoData['channel']['avatar']['path'];
          }
          comments = _parseComments(commentsData);
        });

        final playlistUrl = videoData['streamingPlaylists'][0]['playlistUrl'];
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
        throw Exception('Failed to fetch video data');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching video data: $error');
      }
    }
  }

  List<CommentItem> _parseComments(dynamic commentsData) {
    List<CommentItem> parsedComments = [];
    for (var item in commentsData['data']) {
      var comment = CommentItem();
      comment.id = item['id'];
      comment.threadId = item['threadId'];
      comment.url = Uri.parse(item['url']);
      comment.inReplyToCommentId = item['inReplyToCommentId'];
      comment.videoId = item['videoId'];
      comment.createdAt = DateTime.parse(item['createdAt']);
      comment.updatedAt = DateTime.parse(item['updatedAt']);
      comment.deletedAt =
          item['deletedAt'] != null ? DateTime.parse(item['deletedAt']) : null;
      comment.isDeleted = item['isDeleted'];
      comment.totalRepliesFromVideoAuthor = item['totalRepliesFromVideoAuthor'];
      comment.totalReplies = item['totalReplies'];
      comment.text = item['text'];
      comment.account.url = Uri.parse(item['account']['url']);
      comment.account.name = item['account']['name'];
      comment.account.host = item['account']['host'];
      comment.account.avatars = item['account']['avatars'];
      comment.account.avatar = item['account']['avatar'];
      parsedComments.add(comment);
    }
    return parsedComments;
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
                              ),
                            )
                          : Container(),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Padding(padding: EdgeInsets.all(7.0)),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.6),
                                  child: TextButton(
                                    style: ButtonStyle(
                                      enableFeedback: true,
                                      padding:
                                          MaterialStateProperty.all<EdgeInsets>(
                                              EdgeInsets.zero),
                                    ),
                                    onPressed: () {}, // add action later
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              'https://tilvids.com$channelAvatar'),
                                          radius: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
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
                                  ),
                                ),
                              ],
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
                      const SizedBox(height: 10),
                      ExpansionTile(
                        title: const Text(
                          'Comments',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildComments(),
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

  Widget _buildComments() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        String plainTextComment = removeHtmlTags(comment.text);
        return ListTile(
          subtitle: Text(plainTextComment),
          title: Text(
            comment.account.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}

String removeHtmlTags(String htmlText) {
  RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
  return htmlText.replaceAll(exp, '');
}

class CommentItem {
  int? id;
  int? threadId;
  Uri? url;
  int? inReplyToCommentId;
  int? videoId;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;
  bool isDeleted = false;
  int totalRepliesFromVideoAuthor = 0;
  int totalReplies = 0;
  Commenter account = Commenter();
  String text = '';
}

class Commenter {
  Uri? url;
  String name = '';
  String host = '';
  dynamic avatars;
  dynamic avatar;
}
