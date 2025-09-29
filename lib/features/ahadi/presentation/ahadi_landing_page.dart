import 'package:flutter/material.dart';

class AhadiLandingPage extends StatelessWidget {
  const AhadiLandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ahadi')),
      body: const Center(child: Text('Welcome to the Ahadi Module')),
    );
  }
}
