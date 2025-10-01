import 'package:flutter/material.dart';
import '../../../widgets/module_landing_page.dart';

class JengoLandingPage extends StatelessWidget {
  const JengoLandingPage({super.key});

  final List<Map<String, dynamic>> weeklyContributions = const [
    {'week': 'Week 1', 'amount': 5000, 'date': '01/09/2025'},
    {'week': 'Week 2', 'amount': 7000, 'date': '08/09/2025'},
    {'week': 'Week 3', 'amount': 6000, 'date': '15/09/2025'},
    {'week': 'Week 4', 'amount': 8000, 'date': '22/09/2025'},
  ];

  @override
  Widget build(BuildContext context) {
    return ModuleLandingPage(
      title: "Jengo Contributions",
      description: "Track your weekly church building offerings",
      icon: Icons.home_work,
      gradientColors: const [Colors.orange, Colors.deepOrange],
      contributions: weeklyContributions,
      heroTag: "Jengo",
    );
  }
}
