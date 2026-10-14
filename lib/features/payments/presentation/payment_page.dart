import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../contributions/domain/member_data.dart';
import '../../contributions/presentation/contribution_ui.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({
    super.key,
    required this.category,
    required this.week,
    required this.financialYearId,
    required this.paymentsAvailable,
  });

  final ContributionCategory category;
  final ContributionWeek week;
  final String? financialYearId;
  final bool paymentsAvailable;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final suggested = widget.category.suggestedAmount?.amount;
    _amountController = TextEditingController(
      text: suggested == null || suggested <= 0
          ? ''
          : suggested.toStringAsFixed(
              suggested == suggested.roundToDouble() ? 0 : 2,
            ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(widget.category.colorHex);
    return Scaffold(
      key: const ValueKey('payment-page'),
      appBar: AppBar(title: const Text('Payment · Malipo')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _PaymentHeader(category: widget.category, color: color),
              const SizedBox(height: 16),
              if (!widget.paymentsAvailable) ...[
                const _UnavailableNotice(),
                const SizedBox(height: 16),
              ],
              _Section(
                title: 'Contribution details',
                swahiliTitle: 'Maelezo ya sadaka',
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.category_outlined,
                      label: 'Category · Aina',
                      value: widget.category.swahiliName,
                    ),
                    const Divider(height: 24),
                    _DetailRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Contribution week · Wiki',
                      value:
                          'Week ${widget.week.number} · ${formatDate(widget.week.sundayDate)}',
                    ),
                    const Divider(height: 24),
                    _DetailRow(
                      icon: Icons.info_outline_rounded,
                      label: 'Status · Hali',
                      value: weekStateLabel(widget.week.state),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _Section(
                title: 'Payment information',
                swahiliTitle: 'Taarifa za malipo',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Amount · Kiasi',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      key: const ValueKey('payment-amount'),
                      controller: _amountController,
                      enabled: widget.paymentsAvailable,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      decoration: const InputDecoration(
                        hintText: 'Enter contribution amount',
                        suffixText: 'TZS',
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                      validator: (value) {
                        final amount = double.tryParse(value ?? '');
                        if (amount == null || amount <= 0) {
                          return 'Enter a valid amount · Weka kiasi sahihi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Mobile number · Namba ya simu',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      key: const ValueKey('payment-phone'),
                      controller: _phoneController,
                      enabled: widget.paymentsAvailable,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: '700 000 000',
                        prefixText: '+255  ',
                        prefixIcon: Icon(Icons.phone_android_rounded),
                        helperText:
                            'Enter the number without the leading zero.',
                      ),
                      validator: (value) {
                        final digits = value?.trim() ?? '';
                        if (!RegExp(r'^[67]\d{8}$').hasMatch(digits)) {
                          return 'Enter a valid Tanzania number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Payment method · Njia ya malipo',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    const _PaymentMethodTile(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                key: const ValueKey('continue-payment'),
                onPressed: widget.paymentsAvailable ? _continue : null,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(
                  widget.paymentsAvailable
                      ? 'Continue · Endelea'
                      : 'Payments unavailable · Malipo hayajafunguliwa',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'No contribution is recorded until the payment provider confirms the transaction.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Payment provider connection is being completed. · Muunganisho wa malipo unaandaliwa.',
        ),
      ),
    );
  }
}

class _PaymentHeader extends StatelessWidget {
  const _PaymentHeader({required this.category, required this.color});

  final ContributionCategory category;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(categoryIcon(category.iconKey), color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Make a contribution',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Lipa ${category.swahiliName}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.82)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnavailableNotice extends StatelessWidget {
  const _UnavailableNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF4C99F)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF9A4D0B)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Online payments are not enabled yet. You can review the selected week while provider setup is completed.\nMalipo ya mtandao bado hayajafunguliwa.',
              style: TextStyle(color: Color(0xFF713B0D), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.swahiliTitle,
    required this.child,
  });

  final String title;
  final String swahiliTitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            Text(
              swahiliTitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.phone_iphone_rounded, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mobile money',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  'Malipo kwa simu',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle_rounded, color: AppColors.primary),
        ],
      ),
    );
  }
}
