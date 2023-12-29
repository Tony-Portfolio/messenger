import 'package:flutter/material.dart';
import 'supabase/supabase.dart';
import 'screens/contact/contact.dart';
import 'screens/chat/chat.dart';
import 'screens/profile/profile.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'screens/chat/chat_thumbnail.dart';
import 'responsive.dart';

void main() async {
  await initializeSupabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ChatProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Inter',
        ),
        home: const Scaffold(
          body: Responsive(
            mobile: ContactScreen(),
            tablet: Row(children: [
              Expanded(
                flex: 3,
                child: ContactScreen(),
              ),
              Expanded(
                flex: 5,
                child: ChatScreen(),
              ),
            ]),
            desktop: Row(children: [
              Expanded(
                flex: 3,
                child: ContactScreen(),
              ),
              Expanded(
                flex: 6,
                child: ChatScreen(),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
