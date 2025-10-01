import 'package:flutter/material.dart';
import '../../../widgets/module_landing_page.dart';

class AhadiLandingPage extends StatelessWidget {
  const AhadiLandingPage({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> weeklyContributions = const [
    {'week': 'Week 1', 'amount': 3000, 'date': '01/09/2025'},
    {'week': 'Week 2', 'amount': 4500, 'date': '08/09/2025'},
    {'week': 'Week 3', 'amount': 5000, 'date': '15/09/2025'},
    {'week': 'Week 4', 'amount': 4000, 'date': '22/09/2025'},
  ];

  @override
  Widget build(BuildContext context) {
    return ModuleLandingPage(
      title: "Ahadi Contributions",
      description: "Track your weekly promise offerings",
      icon: Icons.volunteer_activism,
      gradientColors: const [Colors.purple, Colors.deepPurple],
      contributions: weeklyContributions,
      heroTag: "Ahadi",
    );
  }
}
