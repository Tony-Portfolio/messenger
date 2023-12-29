import 'package:flutter/material.dart';

class ChatThumbnailScreen extends StatefulWidget {
  const ChatThumbnailScreen({Key? key}) : super(key: key);

  @override
  State<ChatThumbnailScreen> createState() => _ChatThumbnailScreenState();
}

class _ChatThumbnailScreenState extends State<ChatThumbnailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              "Start a conversation or continue chatting",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
