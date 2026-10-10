import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../contributions/data/member_api_service.dart';
import '../../contributions/domain/member_data.dart';
import '../../contributions/presentation/category_detail_page.dart';
import '../../contributions/presentation/contribution_ui.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({
    super.key,
    required this.memberData,
    required this.onLogout,
  });

  final MemberDataGateway memberData;
  final Future<void> Function() onLogout;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  MemberBootstrap? _bootstrap;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final result = await widget.memberData.bootstrap();
      if (!mounted) return;
      setState(() {
        _bootstrap = result;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bahasha'),
        actions: [
          if ((_bootstrap?.unreadNotificationsCount ?? 0) > 0)
            Badge(
              label: Text('${_bootstrap!.unreadNotificationsCount}'),
              child: const Icon(Icons.notifications_none_rounded),
            ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Sign out',
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (_loading && _bootstrap == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _bootstrap == null) {
      return _LoadError(onRetry: _load);
    }
    final data = _bootstrap!;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _MemberHeader(data: data),
          const SizedBox(height: 24),
          Text(
            'Contribution categories',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Aina za sadaka',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          if (data.categories.isEmpty)
            const _EmptyCategories()
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.86,
              ),
              itemBuilder: (context, index) {
                final category = data.categories[index];
                return _CategoryCard(
                  category: category,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CategoryDetailPage(
                        category: category,
                        financialYearId: data.activePeriod.financialYearId,
                        memberData: widget.memberData,
                        paymentsAvailable:
                            data.capabilities.paymentsEnabled &&
                            category.paymentsEnabled,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _MemberHeader extends StatelessWidget {
  const _MemberHeader({required this.data});

  final MemberBootstrap data;

  @override
  Widget build(BuildContext context) {
    final week = data.activePeriod.week;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${data.member.fullName}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${data.member.churchName} · Bahasha ${data.member.bahashaNumber}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  week == null
                      ? 'No active contribution week'
                      : 'Week ${week.number} · ${formatDate(week.sundayDate)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (data.activePeriod.year != null)
                Text(
                  '${data.activePeriod.year}',
                  style: const TextStyle(color: Colors.white70),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final ContributionCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(category.colorHex);
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(categoryIcon(category.iconKey), color: color),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                category.swahiliName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                category.frequency == 'weekly'
                    ? 'Weekly · Kila wiki'
                    : category.frequency,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                formatMoney(category.totalContributed),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                category.missingWeeksCount == 0
                    ? 'Up to date · Imekamilika'
                    : '${category.missingWeeksCount} missing weeks',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: category.missingWeeksCount == 0
                      ? const Color(0xFF217A52)
                      : const Color(0xFFB54708),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 44),
            const SizedBox(height: 12),
            const Text(
              'Could not load your contributions.\nImeshindikana kupakia taarifa.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry · Jaribu tena'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCategories extends StatelessWidget {
  const _EmptyCategories();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No contribution categories are available.\nHakuna aina za sadaka zilizowekwa.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
