import 'package:flutter/material.dart';
import '../../ahadi/presentation/ahadi_landing_page.dart';
import '../../jengo/presentation/jengo_landing_page.dart';
import '../../uwakili/presentation/uwakili_landing_page.dart';
import '../../jumuiya/presentation/jumuiya_landing_page.dart';
import '../../mavuno/presentation/mavuno_landing_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({
    super.key,
    required this.memberName,
    required this.onLogout,
  });

  final String memberName;
  final Future<void> Function() onLogout;

  final List<Map<String, dynamic>> modules = const [
    {
      'name': 'Ahadi',
      'icon': Icons.volunteer_activism,
      'color': Colors.purple,
      'page': AhadiLandingPage(),
    },
    {
      'name': 'Jengo',
      'icon': Icons.home_work,
      'color': Colors.orange,
      'page': JengoLandingPage(),
    },
    {
      'name': 'Uwakili',
      'icon': Icons.balance,
      'color': Colors.green,
      'page': UwakiliLandingPage(),
    },
    {
      'name': 'Jumuiya',
      'icon': Icons.groups,
      'color': Colors.blue,
      'page': JumuiyaLandingPage(),
    },
    {
      'name': 'Mavuno',
      'icon': Icons.agriculture,
      'color': Colors.teal,
      'page': MavunoLandingPage(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(memberName.isEmpty ? 'Bahasha' : 'Welcome, $memberName'),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: modules.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final module = modules[index];
            return _ModuleCard(
              name: module['name'],
              icon: module['icon'],
              color: module['color'],
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 600),
                    pageBuilder: (_, animation, __) {
                      return FadeTransition(
                        opacity: animation,
                        child: module['page'],
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: name, // unique tag for animation
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              // ignore: deprecated_member_use
              colors: [
                color.withValues(alpha: 0.85),
                color.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 200),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 50, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
