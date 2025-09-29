import 'package:flutter/material.dart';

class JumuiyaLandingPage extends StatelessWidget {
  const JumuiyaLandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jumuiya')),
      body: const Center(child: Text('Welcome to the Jumuiya Module')),
    );
  }
}
