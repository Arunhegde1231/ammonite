import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;

class Comment {
  final String text;
  final Account account;

  Comment({required this.text, required this.account});
}

class Account {
  final String displayName;
  final Avatar avatar;

  Account({required this.displayName, required this.avatar});
}

class Avatar {
  final String path;

  Avatar({required this.path});
}

class VideoComments extends StatefulWidget {
  final int videoId;

  const VideoComments({
    Key? key,
    required this.videoId,
  }) : super(key: key);

  @override
  _VideoCommentsState createState() => _VideoCommentsState();
}

class _VideoCommentsState extends State<VideoComments> {
  late int totalComments;
  late List<Comment> commentsData;

  @override
  void initState() {
    super.initState();
    commentsData = [];
    totalComments = 0;
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    try {
      final response = await http.get(Uri.parse(
          "https://tilvids.com/api/v1/videos/${widget.videoId}/comment-threads"));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        totalComments = responseData['total'] ?? 0;
        final List<dynamic> commentsList = responseData['data'] ?? [];
        setState(() {
          commentsData = commentsList.map((data) {
            return Comment(
              text: data['text'] ?? '',
              account: Account(
                displayName: data['account']['displayName'] ?? '',
                avatar: Avatar(
                  path: data['account']['avatar']['path'] ?? '', 
                ),
              ),
            );
          }).toList();
        });
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (error) {
      print('Error fetching comments: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness;

    Color backgroundColor =
        isDarkMode == Brightness.dark ? Colors.black : Colors.white;
    Color textColor =
        isDarkMode == Brightness.dark ? Colors.white : Colors.black;

    return Container(
      color: backgroundColor,
      child: DraggableScrollableSheet(
          expand: true,
          initialChildSize: 1.0,
          builder: (_, controller) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(15, 5, 5, 5),
                                child: Text(
                                  "Comments (${totalComments})",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_outlined),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                          controller: controller,
                          itemCount: commentsData.length,
                          itemBuilder: (context, index) {
                            final comment = commentsData[index];
                            return ListTile(
                              title: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundImage: NetworkImage(
                                        comment.account.avatar.path),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    comment.account.displayName,
                                    style: TextStyle(color: textColor),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: HtmlWidget(comment.text),
                              ),
                            );
                          }),
                    ),
                  ),
                ],
              )),
    );
  }
}
