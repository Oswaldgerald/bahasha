import 'package:flutter/material.dart';
import '../../../widgets/module_landing_page.dart';

class UwakiliLandingPage extends StatelessWidget {
  const UwakiliLandingPage({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> weeklyContributions = const [
    {'week': 'Week 1', 'amount': 7000, 'date': '01/09/2025'},
    {'week': 'Week 2', 'amount': 6000, 'date': '08/09/2025'},
    {'week': 'Week 3', 'amount': 7500, 'date': '15/09/2025'},
    {'week': 'Week 4', 'amount': 8000, 'date': '22/09/2025'},
  ];

  @override
  Widget build(BuildContext context) {
    return ModuleLandingPage(
      title: "Uwakili Contributions",
      description: "Track your weekly stewardship offerings",
      icon: Icons.balance,
      gradientColors: const [Colors.green, Colors.teal],
      contributions: weeklyContributions,
      heroTag: "Uwakili",
    );
  }
}
