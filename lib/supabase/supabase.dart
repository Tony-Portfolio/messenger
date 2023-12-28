import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import 'dart:convert';

String generateUserId(String email) {
  String username = email.split('@')[0];

  String randomString =
      Random.secure().nextInt(999999).toString().padLeft(6, '0');

  int numCount = min(max(2, Random.secure().nextInt(3) + 2), 4);
  String numbers =
      Random.secure().nextInt(9999).toString().padLeft(numCount, '0');

  String userId = username.substring(0, min(2, username.length)) +
      randomString.substring(0, 6 - numCount) +
      numbers;

  return userId;
}

String extractUsername(String email) {
  List<String> parts = email.split('@');
  if (parts.length > 0) {
    return parts[0];
  } else {
    return email;
  }
}

Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: 'https://midlsoyjkxifqakotayb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1pZGxzb3lqa3hpZnFha290YXliIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTY5MTY0NDksImV4cCI6MjAxMjQ5MjQ0OX0.Pi6E8xXOmDWEZv7MpYbPiT5Vgfw6HEq4w5GzlMZkdR0',
  );

  await Supabase.instance.client.auth.signInWithPassword(
    email: 'xxdjtonygo@gmail.com',
    password: '123321',
  );

  final userId = Supabase.instance.client.auth.currentUser!.id;
  final userEmail = Supabase.instance.client.auth.currentUser!.email;

  final userExist = await Supabase.instance.client
      .from('users')
      .select('*')
      .eq('email', userEmail);

  print('DATA NYA : $userId');

  if (userExist.length == 0) {
    print('JALAN ?');
    await Supabase.instance.client.from('users').upsert({
      'username': extractUsername(userEmail!),
      'email': userEmail,
      'bio': 'Just chillin',
      'profile_picture': 'profile.jpg',
      'user_id': userId,
    });
  }
}

final supabase = Supabase.instance.client;
