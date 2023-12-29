import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:messenger/screens/contact/contact.dart';
import '../../supabase/supabase.dart';
import 'package:intl/intl.dart';
import '../profile/profile.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import 'chat_thumbnail.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final userId = supabase.auth.currentUser!.id;
  late Stream<List<dynamic>> messages;
  final ScrollController _scrollController = ScrollController();

  Future<void> _getInitialMessageStream() async {
    final conversationId = context.read<ChatProvider>().conversationId;
    final recipientsData = context.read<ChatProvider>().recipientsData;
    print('Chat: initial $conversationId $recipientsData');
    print('Data Initial ${context.read<ChatProvider>().conversationId}');

    final stream = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);

    setState(() {
      messages = stream;
    });
  }

  String formatCreatedAt(String createdAt) {
    DateTime dateTime = DateTime.parse(createdAt);
    String formattedTime = '';
    formattedTime += DateFormat('h').format(dateTime);
    formattedTime += ':';
    formattedTime += DateFormat('mm').format(dateTime);
    formattedTime += (" " + DateFormat('a').format(dateTime));
    return formattedTime;
  }

  @override
  void initState() {
    super.initState();
    messages = const Stream.empty();
    print('Data wk ${context.read<ChatProvider>().conversationId}');
    print('Data wk ${context.read<ChatProvider>().recipientsData}');
    _getInitialMessageStream();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        _getInitialMessageStream(); // Call the function here
        final profile = context.watch<ChatProvider>().recipientsData;
        final chatProvider = context.watch<ChatProvider>().conversationId;
        final conversationId = context.read<ChatProvider>().conversationId;
        final recipientsData = context.read<ChatProvider>().recipientsData;
        print("RUNNING EVERYTIME ? ");
        if (chatProvider != 0) {
          return Scaffold(
            body: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  color: Colors.grey.shade100,
                  child: Container(
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            if (MediaQuery.of(context).size.width < 600) {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      const ContactScreen(),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    const begin = Offset(-1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOutQuart;
                                    var tween = Tween(begin: begin, end: end)
                                        .chain(CurveTween(curve: curve));
                                    var offsetAnimation =
                                        animation.drive(tween);

                                    return SlideTransition(
                                      position: offsetAnimation,
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            } else {
                              context.read<ChatProvider>().changeChat(
                                  newConversationId: 0, newRecipientsData: []);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: SvgPicture.asset(
                                'assets/chevron-left-solid.svg',
                                width: 30,
                                height: 20),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ProfileScreen()));
                            },
                            child: ClipOval(
                              child: Hero(
                                tag: 'img',
                                child: Image.network(
                                  'https://midlsoyjkxifqakotayb.supabase.co/storage/v1/object/public/data/profile/${profile['profile_picture']}',
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(profile['username'] ?? 'Unknown',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text('Online',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12)),
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
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: StreamBuilder(
                      stream: messages,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          print(snapshot.data);
                          // return Text('ho');
                          return ListView.builder(
                            controller: _scrollController,
                            itemCount: snapshot.data?.length ?? 0,
                            itemBuilder: (context, index) {
                              final message = snapshot.data![index];
                              print(message['content']);
                              return Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Column(
                                  crossAxisAlignment:
                                      message['sender_id'] == userId
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                  children: [
                                    BubbleSpecialOne(
                                      text: message['content'],
                                      isSender: message['sender_id'] == userId,
                                      color: Colors.blue,
                                      textStyle: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                    // Container(
                                    //   padding:
                                    //       const EdgeInsets.symmetric(horizontal: 16),
                                    //   child: Text(
                                    //     formatCreatedAt(message['created_at']),
                                    //     style: TextStyle(
                                    //         fontSize: 10,
                                    //         fontWeight: FontWeight.w600),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  color: Colors.grey.shade100,
                  child: Row(
                    children: [
                      Expanded(
                        child: StyledTextField(
                            conversation_id: conversationId.toString(),
                            recipients_data: profile),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return ChatThumbnailScreen();
        }
      },
    );
  }
}

class StyledTextField extends StatelessWidget {
  final _textController = TextEditingController();
  final conversation_id;
  final recipients_data;
  var userId = supabase.auth.currentUser!.id;

  StyledTextField(
      {required this.conversation_id, required this.recipients_data});

  void insertChat() async {
    try {
      final response = await supabase.from('messages').insert({
        'sender_id': userId,
        // 'recipient_id': recipients_data['user_id'],
        'content': _textController.text.trim(),
        'conversation_id': conversation_id,
      });
    } catch (e) {
      print('Error : $e');
    }
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
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                isDense: false,
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
