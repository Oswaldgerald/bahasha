import 'package:flutter/material.dart';

class MavunoLandingPage extends StatelessWidget {
  const MavunoLandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mavuno')),
      body: const Center(child: Text('Welcome to the Mavuno Module')),
    );
  }
}
