import 'package:flutter/material.dart';
import 'package:supabase_auth/pages/complete_profile.dart';
import 'package:supabase_auth/pages/home_page.dart';
import 'package:supabase_auth/pages/login_page.dart';
import 'package:supabase_auth/pages/splash_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'Your Supabase URL',
    anonKey:
        'Your Supabase anonymous key (can be found in the Supabase admin panel)',
    debug: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/completeProfile': (context) => const CompleteProfilePage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
