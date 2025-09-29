import 'package:flutter/material.dart';
import 'features/auth/presentation/login_page.dart';

void main() {
  runApp(const BahashaApp());
}

class BahashaApp extends StatelessWidget {
  const BahashaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bahasha',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginPage(),
    );
  }
}
