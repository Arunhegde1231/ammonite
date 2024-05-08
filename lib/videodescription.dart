import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoDescription extends StatelessWidget {
  final String description;

  const VideoDescription({
    Key? key,
    required this.description,
  }) : super(key: key);

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
                            'Description',
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
              child: SingleChildScrollView(
                controller: controller,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Linkify(
                    onOpen: (link) async {
                      if (!await launchUrl(Uri.parse(link.url))) {
                        throw Exception('cannot open ${link.url}');
                      }
                    },
                    text: description,
                    style: TextStyle(color: textColor),
                    linkStyle: TextStyle(color: const Color.fromARGB(255, 7, 7, 255)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
