import 'dart:async';

import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClient = Supabase.instance.client;
const isNewUserKey = 'isNewUserKey';
const userIdKey = 'userIdKey';

class AuthState<T extends StatefulWidget> extends SupabaseAuthState<T> {
  final EncryptedSharedPreferences sharedPreferences =
      EncryptedSharedPreferences();

  @override
  void onAuthenticated(Session session) {
    if (mounted) {
      sharedPreferences.getString(isNewUserKey).then((isNewUser) {
        if (isNewUser == 'true') {
          Navigator.pushNamed(context, '/completeProfile');
          sharedPreferences.setString(isNewUserKey, 'false');
          sharedPreferences.setString(userIdKey, session.user!.id);
        } else if (isNewUser == 'false') {
          Navigator.pushNamed(context, '/home');
        }
      });
    }
  }

  @override
  void onErrorAuthenticating(String message) {
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }
  }

  @override
  void onPasswordRecovery(Session session) {}

  @override
  void onUnauthenticated() {
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Future<void> signIn({
    required String email,
    Function? onSuccess,
    Function? onError,
  }) async {
    final response = await supabaseClient.auth.signIn(
      email: email,
      options: AuthOptions(
        redirectTo:
            kIsWeb ? null : 'com.example.supabaseAuth://codereview-callback/',
      ),
    );
    final error = response.error;
    if (error != null) {
      onError!(error.message);
    } else {
      debugPrint('signIn: ${response.data}');
      sharedPreferences.setString(isNewUserKey, 'true');
      final isNew = await sharedPreferences.getString(isNewUserKey);
      if (isNew == '') {
        sharedPreferences.setString(isNewUserKey, 'true');
        // ignore: use_build_context_synchronously
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/completeProfile',
          (route) => false,
        );
      } else {
        sharedPreferences.setString(isNewUserKey, 'false');
        // ignore: use_build_context_synchronously
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      }
      onSuccess!();
    }
  }

  Future<void> signOut() async {
    await supabaseClient.auth.signOut(); // shoould supabase take care of this?
  }

  Future<void> updateProfile(Map<String, dynamic> profile) async {
    final profileData = {
      'name': profile['name'],
      'phoneNumber': profile['phoneNumber'],
      'updated_at': DateTime.now().toIso8601String(),
      'email': supabaseClient.auth.currentUser!.email,
      'id': supabaseClient.auth.currentUser!.id,
    };

    final response =
        await supabaseClient.from('profiles').upsert(profileData).execute();
    if (response.error != null) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.error!.message,
            style: const TextStyle(color: Colors.red),
          ),
          duration: const Duration(minutes: 2),
        ),
      );
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  Future<String> getUserIdFromStorage() async {
    return await sharedPreferences.getString(userIdKey);
    // //  userId: 283dfee5-30ce-4f6d-9f68-1abb589e278f
    // final response = await supabaseClient
    //     .from('profiles')
    //     .select()
    //     .eq('id', userId)
    //     .execute();

    // if (response.error != null) {
    //   // ignore: use_build_context_synchronously
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text(
    //         response.error!.message,
    //         style: const TextStyle(color: Colors.red),
    //       ),
    //     ),
    //   );
    // }
    // if (response.data != null) {
    //   final List<dynamic> profiles = response.data as List<dynamic>;
    //   _userProfile.add({
    //     "name": profiles[0]['name'],
    //     "email": profiles[0]['email'],
    //     "phoneNumber": profiles[0]['phoneNumber'],
    //     "updated_at": profiles[0]['updated_at'],
    //   });
    // }
  }

  String? get email => supabaseClient.auth.currentUser != null
      ? supabaseClient.auth.currentUser!.email
      : '';
}
