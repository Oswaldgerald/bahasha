import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../data/member_api_service.dart';
import '../domain/member_data.dart';
import '../../payments/presentation/payment_page.dart';
import '../../payments/data/payment_api_service.dart';
import 'contribution_ui.dart';

class CategoryDetailPage extends StatefulWidget {
  const CategoryDetailPage({
    super.key,
    required this.category,
    required this.financialYearId,
    required this.memberData,
    required this.paymentGateway,
    required this.paymentsAvailable,
  });

  final ContributionCategory category;
  final String? financialYearId;
  final MemberDataGateway memberData;
  final PaymentGateway paymentGateway;
  final bool paymentsAvailable;

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  final List<ContributionWeek> _weeks = [];
  final List<ContributionRecord> _contributions = [];
  bool _loading = true;
  bool _loadingMoreWeeks = false;
  bool _loadingMoreContributions = false;
  Object? _error;
  String? _weekCursor;
  String? _contributionCursor;
  bool _hasMoreWeeks = false;
  bool _hasMoreContributions = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final results = await Future.wait([
        widget.memberData.categoryWeeks(
          categoryId: widget.category.id,
          financialYearId: widget.financialYearId,
        ),
        widget.memberData.contributions(
          categoryId: widget.category.id,
          financialYearId: widget.financialYearId,
        ),
      ]);
      if (!mounted) return;
      final weeks = results[0] as PagedResult<ContributionWeek>;
      final contributions = results[1] as PagedResult<ContributionRecord>;
      setState(() {
        _weeks
          ..clear()
          ..addAll(weeks.items);
        _contributions
          ..clear()
          ..addAll(contributions.items);
        _weekCursor = weeks.nextCursor;
        _contributionCursor = contributions.nextCursor;
        _hasMoreWeeks = weeks.hasMore;
        _hasMoreContributions = contributions.hasMore;
        _error = null;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMoreWeeks() async {
    if (_loadingMoreWeeks || !_hasMoreWeeks) return;
    setState(() => _loadingMoreWeeks = true);
    try {
      final result = await widget.memberData.categoryWeeks(
        categoryId: widget.category.id,
        financialYearId: widget.financialYearId,
        cursor: _weekCursor,
      );
      if (!mounted) return;
      setState(() {
        _weeks.addAll(result.items);
        _weekCursor = result.nextCursor;
        _hasMoreWeeks = result.hasMore;
      });
    } catch (_) {
      _showLoadMoreError();
    } finally {
      if (mounted) setState(() => _loadingMoreWeeks = false);
    }
  }

  Future<void> _loadMoreContributions() async {
    if (_loadingMoreContributions || !_hasMoreContributions) return;
    setState(() => _loadingMoreContributions = true);
    try {
      final result = await widget.memberData.contributions(
        categoryId: widget.category.id,
        financialYearId: widget.financialYearId,
        cursor: _contributionCursor,
      );
      if (!mounted) return;
      setState(() {
        _contributions.addAll(result.items);
        _contributionCursor = result.nextCursor;
        _hasMoreContributions = result.hasMore;
      });
    } catch (_) {
      _showLoadMoreError();
    } finally {
      if (mounted) setState(() => _loadingMoreContributions = false);
    }
  }

  void _showLoadMoreError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not load more. Please retry · Jaribu tena.'),
      ),
    );
  }

  Future<void> _openPayment(ContributionWeek week) async {
    final paymentCompleted = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => PaymentPage(
          category: widget.category,
          week: week,
          financialYearId: widget.financialYearId,
          paymentGateway: widget.paymentGateway,
          paymentsAvailable: widget.paymentsAvailable,
        ),
      ),
    );
    if (paymentCompleted == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(widget.category.colorHex);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.category.swahiliName),
              if (widget.category.name != widget.category.swahiliName)
                Text(
                  widget.category.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Weeks · Wiki'),
              Tab(text: 'History · Historia'),
            ],
          ),
        ),
        body: Column(
          children: [
            _CategorySummary(
              category: widget.category,
              color: color,
              paymentsAvailable: widget.paymentsAvailable,
            ),
            Expanded(child: _content(color)),
          ],
        ),
      ),
    );
  }

  Widget _content(Color color) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 44),
              const SizedBox(height: 12),
              const Text(
                'Could not load this category.\nImeshindikana kupakia taarifa.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry · Jaribu tena'),
              ),
            ],
          ),
        ),
      );
    }
    return TabBarView(
      children: [
        RefreshIndicator(
          onRefresh: _load,
          child: _WeekList(
            weeks: _weeks,
            color: color,
            hasMore: _hasMoreWeeks,
            loadingMore: _loadingMoreWeeks,
            onLoadMore: _loadMoreWeeks,
            onWeekSelected: _openPayment,
          ),
        ),
        RefreshIndicator(
          onRefresh: _load,
          child: _HistoryList(
            contributions: _contributions,
            hasMore: _hasMoreContributions,
            loadingMore: _loadingMoreContributions,
            onLoadMore: _loadMoreContributions,
          ),
        ),
      ],
    );
  }
}

class _CategorySummary extends StatelessWidget {
  const _CategorySummary({
    required this.category,
    required this.color,
    required this.paymentsAvailable,
  });

  final ContributionCategory category;
  final Color color;
  final bool paymentsAvailable;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(categoryIcon(category.iconKey), color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total contributed · Jumla',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 3),
                Text(
                  formatMoney(category.totalContributed),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  paymentsAvailable
                      ? 'Ready to contribute · Tayari kulipa'
                      : 'Online payment coming soon · Malipo yanakuja',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekList extends StatelessWidget {
  const _WeekList({
    required this.weeks,
    required this.color,
    required this.hasMore,
    required this.loadingMore,
    required this.onLoadMore,
    required this.onWeekSelected,
  });

  final List<ContributionWeek> weeks;
  final Color color;
  final bool hasMore;
  final bool loadingMore;
  final Future<void> Function() onLoadMore;
  final ValueChanged<ContributionWeek> onWeekSelected;

  @override
  Widget build(BuildContext context) {
    if (weeks.isEmpty) {
      return const _EmptyList(
        icon: Icons.calendar_today_rounded,
        message:
            'No weekly schedule for this category.\nHakuna ratiba ya wiki.',
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: weeks.length + (hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == weeks.length) {
          return Center(
            child: TextButton.icon(
              onPressed: loadingMore ? null : onLoadMore,
              icon: loadingMore
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.expand_more_rounded),
              label: const Text('Load more · Zaidi'),
            ),
          );
        }
        final week = weeks[index];
        final stateColor = weekStateColor(week.state);
        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            key: ValueKey('contribution-week-${week.id}'),
            onTap: week.paymentEligible ? () => onWeekSelected(week) : null,
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              foregroundColor: color,
              child: Text('${week.number}'),
            ),
            title: Text(
              'Week ${week.number}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: formatDate(week.sundayDate),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  TextSpan(
                    text: '\n${weekStateLabel(week.state)}',
                    style: TextStyle(
                      color: stateColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  // Explain why a week that still needs paying can't be
                  // opened, instead of a tile that silently ignores taps.
                  if (!week.paymentEligible && week.state != 'paid')
                    const TextSpan(
                      text: '\nNot open for payment · Haijafunguliwa',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (week.contributed.amount > 0)
                      Text(
                        formatMoney(week.contributed),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      )
                    else
                      Icon(
                        week.paymentEligible
                            ? Icons.schedule_rounded
                            : Icons.remove_rounded,
                        color: stateColor,
                      ),
                    if (week.paymentEligible)
                      const Text(
                        'Contribute · Lipa',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
                if (week.paymentEligible) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({
    required this.contributions,
    required this.hasMore,
    required this.loadingMore,
    required this.onLoadMore,
  });

  final List<ContributionRecord> contributions;
  final bool hasMore;
  final bool loadingMore;
  final Future<void> Function() onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (contributions.isEmpty) {
      return const _EmptyList(
        icon: Icons.receipt_long_rounded,
        message: 'No contributions recorded yet.\nHakuna sadaka iliyorekodiwa.',
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: contributions.length + (hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == contributions.length) {
          return Center(
            child: TextButton.icon(
              onPressed: loadingMore ? null : onLoadMore,
              icon: loadingMore
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.expand_more_rounded),
              label: const Text('Load more · Zaidi'),
            ),
          );
        }
        final contribution = contributions[index];
        final statusColor = contributionStatusColor(contribution.status);
        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: Icon(
              contributionStatusIcon(contribution.status),
              color: statusColor,
            ),
            title: Text(
              formatMoney(contribution.amount),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              'Week ${contribution.weekNumber} · ${formatDate(contribution.contributionDate)}\n${contribution.reference}',
            ),
            isThreeLine: true,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                contributionStatusLabel(contribution.status),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyList extends StatelessWidget {
  const _EmptyList({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 72),
        Icon(icon, size: 48, color: AppColors.textSecondary),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
      ],
    );
  }
}
