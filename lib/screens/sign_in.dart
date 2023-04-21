import 'package:flutter/material.dart';

import '../../services/auth.dart';
import '../shared/constants.dart';
import '../shared/widgets/loading.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;

  const SignIn({super.key, required this.toggleView});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  String email = '';
  String password = '';
  String error = '';

  void signInAnonymously() async {
    setState(() => isLoading = true);
    await _auth.signInAnon();
  }

  void signInWithEmailAndPassword(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      dynamic result = await _auth.signInWithEmailAndPassword(email, password);

      if (result == null) {
        setState(() => isLoading = false);
        setState(() => error = 'Could not sign in with those credentials');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        elevation: 0,
        title: const Text('Sign in to Brew Crew'),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () {
              widget.toggleView();
            },
            icon: const Icon(Icons.person, color: Colors.white),
            label: const Text(
              'Register',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              TextFormField(
                decoration: textInputDecoration.copyWith(hintText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Cannot be empty' : null,
                onChanged: (value) => setState(() => email = value),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: textInputDecoration.copyWith(hintText: 'Password'),
                obscureText: true,
                validator: (value) =>
                    value!.length < 6 ? 'Must be at least 6 characters long' : null,
                onChanged: (value) => setState(() => password = value),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const Loading()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () => signInWithEmailAndPassword(email, password),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink[400],
                            elevation: 1,
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => signInAnonymously(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink[400],
                            elevation: 1,
                          ),
                          child: const Text(
                            'Sign In Anonymously',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 12),
              Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
