import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'videoplayer.dart';

const int pageSize = 50;

class ChannelVideoScreen extends StatefulWidget {
  final String channelName;
  final String instanceURL;
  final PagingController<int, dynamic> pagingController;

  const ChannelVideoScreen({
    Key? key,
    required this.channelName,
    required this.instanceURL,
    required this.pagingController,
  }) : super(key: key);

  @override
  _ChannelVideoScreenState createState() => _ChannelVideoScreenState();
}

class _ChannelVideoScreenState extends State<ChannelVideoScreen> {
  @override
  void initState() {
    super.initState();
    widget.pagingController.addPageRequestListener((pageKey) {
      _fetchChannelVideos(pageKey);
    });
  }

  Future<void> _fetchChannelVideos(int pageKey) async {
    try {
      final response = await http.get(Uri.parse(
          '${widget.instanceURL}/api/v1/video-channels/${widget.channelName}/videos?start=$pageKey&count=$pageSize'));
      if (response.statusCode == 200) {
        final videoData = json.decode(response.body);
        final List<dynamic> newVideos = videoData['data'];
        final isLastPage = newVideos.length < pageSize;
        if (isLastPage) {
          widget.pagingController.appendLastPage(newVideos);
        } else {
          final nextPageKey = pageKey + pageSize;
          widget.pagingController.appendPage(newVideos, nextPageKey);
        }
      } else {
        widget.pagingController.error =
            'Failed to load videos: ${response.statusCode}';
      }
    } catch (error) {
      widget.pagingController.error = 'Failed to load videos: $error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() => widget.pagingController.refresh()),
        child: PagedListView<int, dynamic>(
          pagingController: widget.pagingController,
          builderDelegate: PagedChildBuilderDelegate<dynamic>(
            itemBuilder: (context, video, index) {
              final thumbnailURL = video['previewPath'] != null
                  ? '${widget.instanceURL}${video['previewPath']}'
                  : '';

              final channelData = video['channel'];
              final channelName =
                  channelData != null && channelData['displayName'] != null
                      ? channelData['displayName']
                      : '';

              final avatarData = channelData['avatar'];
              final avatarData2 = channelData['avatars'];
              final channelAvatar = avatarData != null && avatarData.isNotEmpty
                  ? '${widget.instanceURL}${avatarData['path']}'
                  : '';
              final channelAvatar2 =
                  avatarData2 != null && avatarData2.isNotEmpty
                      ? '${widget.instanceURL}${avatarData2[1]['path']}'
                      : '';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      final videoUrl = video['url'];
                      final videoId = video['id'];
                      if (videoUrl is String) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerPage(
                              videoId: videoId,
                              videoUrl: videoUrl,
                            ),
                          ),
                        );
                      } else {
                        if (kDebugMode) {
                          print('Invalid video URL');
                        }
                      }
                    },
                    child: Image.network(
                      thumbnailURL,
                      width: double.maxFinite,
                      height: 240,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 6),
                    child: Row(
                      children: [
                        if (channelAvatar.isNotEmpty)
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(
                              channelAvatar.isNotEmpty
                                  ? channelAvatar
                                  : channelAvatar2,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'RobotoMono',
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                              const SizedBox(height: 2),
                              if (channelName.isNotEmpty)
                                Text(
                                  '$channelName',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 53, top: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.thumb_up_outlined),
                        const SizedBox(width: 6),
                        Text('${video['likes'] ?? 0}'),
                        const SizedBox(width: 6),
                        const Icon(Icons.thumb_down_outlined),
                        const SizedBox(width: 6),
                        Text('${video['dislikes'] ?? 0}'),
                        const SizedBox(width: 8),
                        const Text('•'),
                        const SizedBox(width: 8),
                        Text('${video['views'] ?? 0} Views'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
