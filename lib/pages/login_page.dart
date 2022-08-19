import 'package:flutter/material.dart';
import 'package:supabase_auth/auth/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends AuthState<LoginPage> {
  late final TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _emailController = TextEditingController();
    super.initState();
  }

  _onPressed() {
    if (_formKey.currentState!.validate()) {
      signIn(
        email: _emailController.text,
        onSuccess: () {
          _emailController.clear();
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                error.message,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 100, left: 20, right: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Email is required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _onPressed,
                label: const Text('Login'),
                icon: const Icon(Icons.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
