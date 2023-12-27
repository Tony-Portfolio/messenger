import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../supabase/supabase.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final userId = supabase.auth.currentUser!.id;
  late Future messages;
  Future _getInitialMessage() async {
    print('Chat : awal');
    late final conversation_id;
    try {
      final response = await supabase
          .from('conversation')
          .select("*, messages(*)")
          .eq('user_id', userId);
      return response;
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    messages = _getInitialMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.transparent,
                    backgroundImage: Image.asset(
                      'assets/User-profile.jpg',
                      width: 22,
                      height: 22,
                      fit: BoxFit.cover,
                    ).image,
                  ),
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Marry Liesha',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('Online',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SvgPicture.asset(
                          'assets/phone-solid.svg',
                          width: 20,
                          height: 20,
                        ),
                        SizedBox(width: 12),
                        SvgPicture.asset(
                          'assets/option-dots-solid.svg',
                          width: 20,
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: messages,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  // print(snapshot.data[0]);
                  // return Text('ho');
                  return ListView.builder(
                    itemCount: snapshot.data[0]['messages']!.length,
                    itemBuilder: (context, index) {
                      final message = snapshot.data[0]['messages'][index];
                      print(message['content']);
                      return BubbleSpecialOne(
                        text: message['content'],
                        isSender: message['sender_id'] == userId,
                        color: Colors.blue,
                        textStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Container(
            child: Row(
              children: [
                Expanded(
                  child: StyledTextField(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StyledTextField extends StatelessWidget {
  final _textController = TextEditingController();
  var userId = supabase.auth.currentUser!.id;

  void insertChat() async {
    await supabase.from('messages').insert({
      'sender_id': userId,
      'recipient_id': userId,
      'content': _textController.text.trim(),
      'conversation_id': 1,
    });
    _textController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextFormField(
              controller: _textController,
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              maxLines: 4,
              minLines: 1,
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              insertChat();
            },
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SvgPicture.asset(
                'assets/paper-plane-solid.svg',
                width: 20,
                height: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
