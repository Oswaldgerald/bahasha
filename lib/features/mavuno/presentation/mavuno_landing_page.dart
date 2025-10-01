import 'package:flutter/material.dart';
import '../../../widgets/module_landing_page.dart';

class MavunoLandingPage extends StatelessWidget {
  const MavunoLandingPage({super.key});

  final List<Map<String, dynamic>> weeklyContributions = const [
    {'week': 'Week 1', 'amount': 5500, 'date': '01/09/2025'},
    {'week': 'Week 2', 'amount': 6000, 'date': '08/09/2025'},
    {'week': 'Week 3', 'amount': 5800, 'date': '15/09/2025'},
    {'week': 'Week 4', 'amount': 6200, 'date': '22/09/2025'},
  ];

  @override
  Widget build(BuildContext context) {
    return ModuleLandingPage(
      title: "Mavuno Contributions",
      description: "Track your weekly harvest offerings",
      icon: Icons.agriculture,
      gradientColors: const [Colors.teal, Colors.cyan],
      contributions: weeklyContributions,
      heroTag: "Mavuno",
    );
  }
}
