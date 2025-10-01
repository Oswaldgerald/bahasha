import 'package:flutter/material.dart';
import '../../../widgets/module_landing_page.dart';

class JumuiyaLandingPage extends StatelessWidget {
  const JumuiyaLandingPage({super.key});

  final List<Map<String, dynamic>> weeklyContributions = const [
    {'week': 'Week 1', 'amount': 4000, 'date': '01/09/2025'},
    {'week': 'Week 2', 'amount': 3500, 'date': '08/09/2025'},
    {'week': 'Week 3', 'amount': 5000, 'date': '15/09/2025'},
    {'week': 'Week 4', 'amount': 6000, 'date': '22/09/2025'},
  ];

  @override
  Widget build(BuildContext context) {
    return ModuleLandingPage(
      title: "Jumuiya Contributions",
      description: "Track your weekly community offerings",
      icon: Icons.groups,
      gradientColors: const [Colors.blue, Colors.indigo],
      contributions: weeklyContributions,
      heroTag: "Jumuiya",
    );
  }
}
