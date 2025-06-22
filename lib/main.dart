import 'package:flutter/material.dart';

void main() {
  runApp(const LLMJam());
}

class LLMJam extends StatelessWidget {
  const LLMJam({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
          title: 'LLM Jam',
          theme: ThemeData.dark(),
          debugShowCheckedModeBanner: false,
          );
  }
}