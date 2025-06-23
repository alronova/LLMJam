import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user['firstName']}'),
      ),
      body: Center(
        child: Text(
          'Welcome to LLM JAM, ${user['firstName']}!',
        ),
      ),
    );
  }
}
