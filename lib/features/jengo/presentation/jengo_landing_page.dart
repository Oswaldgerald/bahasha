import 'package:flutter/material.dart';

class JengoLandingPage extends StatelessWidget {
  const JengoLandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jengo')),
      body: const Center(child: Text('Welcome to the Jengo Module')),
    );
  }
}
