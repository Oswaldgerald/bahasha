import 'package:flutter/material.dart';
import '../ahadi/presentation/ahadi_landing_page.dart';
import '../jengo/presentation/jengo_landing_page.dart';
import '../uwakili/presentation/uwakili_landing_page.dart';
import '../jumuiya/presentation/jumuiya_landing_page.dart';
import '../mavuno/presentation/mavuno_landing_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> modules = const [
    {
      'name': 'Ahadi',
      'icon': Icons.volunteer_activism,
      'page': AhadiLandingPage(),
    },
    {'name': 'Jengo', 'icon': Icons.home_work, 'page': JengoLandingPage()},
    {'name': 'Uwakili', 'icon': Icons.balance, 'page': UwakiliLandingPage()},
    {'name': 'Jumuiya', 'icon': Icons.groups, 'page': JumuiyaLandingPage()},
    {'name': 'Mavuno', 'icon': Icons.agriculture, 'page': MavunoLandingPage()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bahasha Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: modules.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final module = modules[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => module['page']),
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(module['icon'], size: 48, color: Colors.blue),
                    const SizedBox(height: 10),
                    Text(
                      module['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
