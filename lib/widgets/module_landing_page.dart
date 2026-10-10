import 'package:flutter/material.dart';

class ModuleLandingPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final List<Map<String, dynamic>> contributions;
  final String heroTag;

  const ModuleLandingPage({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.contributions,
    required this.heroTag,
  });

  List<Map<String, dynamic>> get sortedContributions {
    final items = List<Map<String, dynamic>>.from(contributions);
    items.sort(
      (a, b) => _parseDate(
        _readText(b['date']),
      ).compareTo(_parseDate(_readText(a['date']))),
    );
    return items;
  }

  int get totalContributions => contributions.fold<int>(
    0,
    (sum, item) => sum + _readAmount(item['amount']),
  );

  Map<String, dynamic>? get latestContribution =>
      sortedContributions.isEmpty ? null : sortedContributions.first;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = sortedContributions;
    final latest = latestContribution;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FB),
      body: ListView(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.last.withValues(alpha: 0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const AppBackButton(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Hero(
                    tag: heroTag,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        height: 74,
                        width: 74,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(icon, size: 38, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      InfoChip(
                        icon: Icons.calendar_month_rounded,
                        label: '${items.length} weeks',
                      ),
                      InfoChip(
                        icon: Icons.history_rounded,
                        label: latest == null
                            ? 'No records yet'
                            : 'Latest: ${_readText(latest['week'])}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF8EE),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.savings_rounded,
                      color: Color(0xFF2E9F55),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Contributions',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF231F2B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          latest == null
                              ? 'No weekly contribution added yet'
                              : 'Updated on ${_readText(latest['date'])}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF746C84),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${_formatAmount(totalContributions)} TZS',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2E9F55),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Text(
              'Weekly Contributions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF231F2B),
              ),
            ),
          ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Text(
                  'No contributions available yet.',
                  style: TextStyle(fontSize: 15, color: Color(0xFF746C84)),
                ),
              ),
            ),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final week = entry.value;
            final isLatest = index == 0;

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  leading: Container(
                    height: 58,
                    width: 58,
                    decoration: BoxDecoration(
                      color: gradientColors.first.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(icon, color: gradientColors.first, size: 28),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _readText(week['week']),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF231F2B),
                          ),
                        ),
                      ),
                      if (isLatest)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: gradientColors.last.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            'Latest',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: gradientColors.last,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Date: ${_readText(week['date'])}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF746C84),
                      ),
                    ),
                  ),
                  trailing: Text(
                    '${_formatAmount(_readAmount(week['amount']))} TZS',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2E9F55),
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  static String _readText(dynamic value) => value?.toString() ?? '';

  static int _readAmount(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static DateTime _parseDate(String raw) {
    final parts = raw.split('/');
    if (parts.length != 3) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    final day = int.tryParse(parts[0]) ?? 1;
    final month = int.tryParse(parts[1]) ?? 1;
    final year = int.tryParse(parts[2]) ?? 1970;

    return DateTime(year, month, day);
  }

  static String _formatAmount(int amount) {
    final text = amount.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < text.length; i++) {
      final indexFromEnd = text.length - i;
      buffer.write(text[i]);

      if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }
}

class AppBackButton extends StatelessWidget {
  final Color iconColor;

  const AppBackButton({super.key, this.iconColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).maybePop(),
        child: SizedBox(
          height: 44,
          width: 44,
          child: Icon(Icons.arrow_back_rounded, color: iconColor),
        ),
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const InfoChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
