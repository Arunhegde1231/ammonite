import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Homescreen extends StatefulWidget {
  const Homescreen({Key? key}) : super(key: key);

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  List<dynamic> videos = [];
  bool loading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }
  Future<void> _refreshVideos() async {
    setState(() {
      loading = true;
    });
    await fetchVideos();
  }
  Future<void> fetchVideos() async {
    try {
      final response = await http.get(Uri.parse('https://tilvids.com/api/v1/videos'));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> videosList = responseData['data'];
        setState(() {
          videos = videosList;
          loading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load videos: ${response.statusCode}';
          loading = false;
        });
      }
    } catch (error) {
      print('Error fetching videos: $error');
      setState(() {
        errorMessage = 'Error fetching videos $error';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ammonite'),
        backgroundColor: Color.fromARGB(255, 34, 187, 136),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshVideos,
        child: loading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : videos.isEmpty
                    ? Center(child: Text('No videos found'))
                    : ListView.builder(
                        itemCount: videos.length,
                        itemBuilder: (context, index) {
                          final video = videos[index];
                          final thumbnailURL = 'https://tilvids.com${video['thumbnailPath']}';
                          final channelData = video['channel'];
                          final channelName = channelData != null ? channelData['displayName'] : '';
                          final channelAvatar = channelData != null ? 'https://tilvids.com${channelData['avatar']['path']}' : '';
                          return ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(
                                  thumbnailURL,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Row(
                                    children: [
                                      if (channelAvatar.isNotEmpty)
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundImage: NetworkImage(channelAvatar),
                                        ),
                                      SizedBox(width: 8),
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
                                            SizedBox(height: 2),
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
                                  padding: const EdgeInsets.only(left: 48),
                                  child: Row(
                                    children: [
                                      Text('👁️: ${video['views'] ?? 0}'),
                                      SizedBox(width: 16),
                                      Text('👍: ${video['likes'] ?? 0}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
      ),
    );
  }

}
