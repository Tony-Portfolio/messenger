import 'package:supabase_flutter/supabase_flutter.dart';

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
      'username': 'Raka',
      'email': userEmail,
      'bio': 'Just chillin',
      'profile_picture': 'profile.jpg'
    });
  }
}

final supabase = Supabase.instance.client;
