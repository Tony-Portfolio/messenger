import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../supabase/supabase.dart';

class ChatScreen extends StatefulWidget {
  final conversation_id;
  final recipients_id;
  const ChatScreen(
      {Key? key, required this.conversation_id, required this.recipients_id})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final userId = supabase.auth.currentUser!.id;
  late Stream<List<dynamic>> messages;
  late final conversationId;

  Future<void> _getRecipientsData(userId) async {
    try {
      final recipientsData =
          await supabase.from('users').select('*').eq('user_id', userId);
      print(recipientsData);
    } catch (e) {
      print('Error : $e');
    }
  }

  // Future<void> _getInitialMessageStream() async {
  //   print('Chat: initial');
  //   final response = await supabase
  //       .from('conversation')
  //       .select("*, messages(*)")
  //       .eq('user_id', userId)
  //       .order('created_at', ascending: true)
  //       .limit(1);

  //   conversationId = response?[0]['conversation_id'];
  //   print('Conversation Id : $conversationId and Response : $response');

  //   final stream = supabase
  //       .from('messages')
  //       .stream(primaryKey: ['id'])
  //       .eq('conversation_id', conversationId)
  //       .order('created_at', ascending: true);

  //   setState(() {
  //     messages = stream;
  //   });
  // }

  @override
  void initState() {
    super.initState();
    messages = const Stream.empty();

    _getRecipientsData(widget.recipients_id);
    // _getInitialMessageStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.grey.shade100,
            child: FutureBuilder(
              future: _getRecipientsData(widget.recipients_id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final recipientsProfile =
                      snapshot.data as List<Map<String, dynamic>>;
                  return Expanded(
                    child: ListView.builder(
                      itemCount: recipientsProfile.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = recipientsProfile[index];
                        return Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              child: CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.transparent,
                                // Assuming 'profile_picture' is a key in your item map
                                backgroundImage: Image.asset(
                                  'https://midlsoyjkxifqakotayb.supabase.co/storage/v1/object/public/data/profile/${item['profile_picture']}',
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
                                  Text(item['username'] ?? 'Unknown',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  Text('Online',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
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
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: messages,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  print(snapshot.data);
                  // return Text('ho');
                  return ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      final message = snapshot.data![index];
                      print(message['content']);
                      return Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: BubbleSpecialOne(
                            text: message['content'],
                            isSender: message['sender_id'] == userId,
                            color: Colors.blue,
                            textStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ));
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
