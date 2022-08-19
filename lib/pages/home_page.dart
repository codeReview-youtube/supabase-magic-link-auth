import 'package:flutter/material.dart';
import 'package:supabase_auth/auth/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends AuthState<HomePage> {
  dynamic user;
  bool loading = false;

  @override
  void initState() {
    syncProfileData();
    super.initState();
  }

  Future<void> syncProfileData() async {
    setState(() {
      loading = true;
    });
    final userId = await getUserIdFromStorage();
    final response = await supabaseClient
        .from('profiles')
        .select()
        .eq('id', userId)
        .single()
        .execute();
    if (response.data != null) {
      setState(() {
        user = response.data;
      });
    } else {
      showSnackBar(response.error);
    }
    setState(() {
      loading = false;
    });
  }

  void showSnackBar(PostgrestError? error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error!.message,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            loading
                ? const CircularProgressIndicator()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'You are logged in as',
                      ),
                      Text(
                        user != null ? user['name'] : '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),
            Text(
              '${user != null ? user['phoneNumber'] : ''}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${user != null ? user['email'] : ''}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${user != null ? user['updated_at'] : ''}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // should do logout
                signOut();
              },
              label: const Text('Logout'),
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
      ),
    );
  }
}
