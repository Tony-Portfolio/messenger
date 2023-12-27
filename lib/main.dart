import 'package:flutter/material.dart';
import 'supabase/supabase.dart';
import 'screens/contact/contact.dart';
import 'screens/chat/chat.dart';

void main() async {
  await initializeSupabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
      ),
      home: const Scaffold(
        body: ChatScreen(),
      ),
    );
  }
}
