import 'package:flutter/material.dart';

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
                  child: Text(
                    description,
                    style: TextStyle(fontSize: 16, color: textColor),
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
