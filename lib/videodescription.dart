import 'package:flutter/material.dart';

class VideoDescription extends StatelessWidget {
  final String description;

  const VideoDescription(
      {Key? key, required this.description,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context);
    var mode = isDarkMode.brightness;

    Color backgroundColor;
    Color textColor;

    if (mode == Brightness.dark) {
      backgroundColor = Colors.black;
      textColor = Colors.white;
    } else {
      backgroundColor = Colors.white;
      textColor = Colors.black;
    }

    return Container(
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_upward_rounded),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: SingleChildScrollView(
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
    );
  }
}
