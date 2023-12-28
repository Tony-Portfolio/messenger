import 'package:flutter/material.dart';
import '../../supabase/supabase.dart';
import '../chat/chat.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final userId = supabase.auth.currentUser!.id;
  Future initialConversation() async {
    try {
      // getting conversation list
      final getConversation = await supabase
          .from('conversation')
          .select('*')
          .filter('user_id', 'cs', '{"a73169de-a0b3-4722-a8bc-0cdef3c85f7c"}');
      final data = getConversation;
      // filter own conversation
      final filteredUserIds = data
          .map((item) =>
              (item['user_id'] as List).where((id) => id != userId).first)
          .toList();
      print('id : $filteredUserIds');

      // get conversation sender / recipients
      final getUserData = await supabase
          .from('users')
          .select('*')
          .in_('user_id', filteredUserIds);

      // append conversation id
      Map<String, dynamic> additionalData = {
        'conversation_id': data[0]['conversation_id'],
      };
      getUserData[0].addAll(additionalData);
      return getUserData;
    } catch (e) {
      print('Error : $e');
    }
  }

  @override
  void initState() {
    super.initState();
    initialConversation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(
                    'assets/chat.png',
                    width: 30,
                    height: 30,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chats',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('start a new conversation or continue',
                          style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: FutureBuilder(
              future: initialConversation(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final conversationData = snapshot.data;
                  return Expanded(
                    child: ListView.builder(
                      itemCount: conversationData.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = conversationData[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                        conversation_id:
                                            item['conversation_id'],
                                        recipients_id: item['user_id'])));
                          },
                          child: Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  child: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: Image.network(
                                      'https://midlsoyjkxifqakotayb.supabase.co/storage/v1/object/public/data/profile/${item['profile_picture']}',
                                      width: 25,
                                      height: 25,
                                      fit: BoxFit.cover,
                                    ).image,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(item['username'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            )),
                                        Text(
                                          'Well hello there!, how was your first day at work?',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            color: Color(0xFF808080),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Container(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
