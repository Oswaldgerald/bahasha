import 'package:flutter/material.dart';

class UwakiliLandingPage extends StatelessWidget {
  const UwakiliLandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Uwakili')),
      body: const Center(child: Text('Welcome to the Uwakili Module')),
    );
  }
}
