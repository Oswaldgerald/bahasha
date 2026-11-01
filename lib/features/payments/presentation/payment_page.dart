import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_exception.dart';
import '../../contributions/domain/member_data.dart';
import '../../contributions/presentation/contribution_ui.dart';
import '../data/payment_api_service.dart';
import '../domain/payment_data.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({
    super.key,
    required this.category,
    required this.week,
    required this.financialYearId,
    required this.paymentGateway,
    required this.paymentsAvailable,
  });

  final ContributionCategory category;
  final ContributionWeek week;
  final String? financialYearId;
  final PaymentGateway paymentGateway;
  final bool paymentsAvailable;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  static const _pollInterval = Duration(seconds: 3);
  static const _maxPollAttempts = 40;

  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  late final TextEditingController _amountController;
  final _phoneController = TextEditingController();
  String _idempotencyKey = const Uuid().v4();
  List<String> _providers = const [];
  String? _selectedProvider;
  PaymentIntent? _intent;
  String? _paymentError;
  bool _loadingMethods = false;
  bool _submitting = false;
  bool _checkingStatus = false;
  Timer? _pollTimer;
  int _pollAttempts = 0;

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
    if (widget.paymentsAvailable) _loadPaymentMethods();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _scrollController.dispose();
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() {
      _loadingMethods = true;
      _paymentError = null;
    });
    try {
      final methods = await widget.paymentGateway.paymentMethods();
      final providers = methods
          .where((method) => method.key == 'mobile_money')
          .expand((method) => method.providers)
          .toSet()
          .toList();
      if (!mounted) return;
      setState(() {
        _providers = providers;
        _selectedProvider = providers.isEmpty ? null : providers.first;
        if (providers.isEmpty) {
          _paymentError = 'No mobile-money provider is currently available.';
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _paymentError = _message(error));
    } finally {
      if (mounted) setState(() => _loadingMethods = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(widget.category.colorHex);
    // Freeze the form once a request is in flight so it always matches the
    // payment shown in the status card.
    final formLocked =
        !widget.paymentsAvailable || _submitting || _intent != null;
    return Scaffold(
      key: const ValueKey('payment-page'),
      appBar: AppBar(title: const Text('Payment · Malipo')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _PaymentHeader(category: widget.category, color: color),
              const SizedBox(height: 16),
              if (_intent case final intent?) ...[
                _PaymentStatusCard(
                  intent: intent,
                  checking: _checkingStatus,
                  onCheckStatus: intent.isTerminal ? null : _refreshStatus,
                  onDone: intent.isSuccessful
                      ? () => Navigator.of(context).pop(true)
                      : null,
                  onRetry: intent.isTerminal && !intent.isSuccessful
                      ? _startNewPayment
                      : null,
                ),
                const SizedBox(height: 16),
              ],
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
                      enabled: !formLocked,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Enter amount · Weka kiasi',
                        suffixText:
                            widget.category.suggestedAmount?.currency ??
                            widget.category.totalContributed.currency,
                        prefixIcon: const Icon(Icons.payments_outlined),
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
                      enabled: !formLocked,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: '700 000 000',
                        prefixText: '+255 ',
                        prefixIcon: Icon(Icons.phone_android_rounded),
                        helperText:
                            'Without the leading zero · Bila sifuri ya mwanzo',
                      ),
                      validator: (value) {
                        final digits = value?.trim() ?? '';
                        if (!RegExp(r'^[67]\d{8}$').hasMatch(digits)) {
                          return 'Enter a valid Tanzania number · Weka namba sahihi';
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
                    if (_loadingMethods)
                      const LinearProgressIndicator()
                    else
                      DropdownButtonFormField<String>(
                        key: const ValueKey('payment-provider'),
                        initialValue: _selectedProvider,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.phone_iphone_rounded),
                          hintText: 'Select mobile-money provider',
                        ),
                        items: _providers
                            .map(
                              (provider) => DropdownMenuItem(
                                value: provider,
                                child: Text(_providerName(provider)),
                              ),
                            )
                            .toList(),
                        onChanged: formLocked
                            ? null
                            : (provider) =>
                                  setState(() => _selectedProvider = provider),
                        validator: (provider) => provider == null
                            ? 'Select a payment provider · Chagua mtandao'
                            : null,
                      ),
                    if (_paymentError case final error?) ...[
                      const SizedBox(height: 10),
                      Text(
                        error,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                key: const ValueKey('continue-payment'),
                onPressed:
                    widget.paymentsAvailable &&
                        !_loadingMethods &&
                        !_submitting &&
                        _providers.isNotEmpty &&
                        _intent == null
                    ? _continue
                    : null,
                icon: _submitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.arrow_forward_rounded),
                label: Text(
                  _submitting
                      ? 'Sending payment request...'
                      : widget.paymentsAvailable
                      ? 'Continue · Endelea'
                      : 'Not available yet · Bado',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'No contribution is recorded until the payment provider confirms the transaction.\n'
                'Sadaka hairekodiwi hadi mtoa huduma athibitishe malipo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    final financialYearId = widget.financialYearId;
    final provider = _selectedProvider;
    if (financialYearId == null || provider == null) {
      setState(() {
        _paymentError =
            'The financial year or payment provider is unavailable.';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _paymentError = null;
    });
    try {
      final amount = double.parse(_amountController.text.trim());
      final intent = await widget.paymentGateway.createIntent(
        categoryId: widget.category.id,
        financialYearId: financialYearId,
        contributionWeekId: widget.week.id,
        provider: provider,
        payerPhoneNumber: '0${_phoneController.text.trim()}',
        amount: amount.toStringAsFixed(2),
        idempotencyKey: _idempotencyKey,
      );
      if (!mounted) return;
      setState(() => _intent = intent);
      _revealPaymentStatus();
      _pollAttempts = 0;
      _schedulePoll();
    } catch (error) {
      if (!mounted) return;
      setState(() => _paymentError = _message(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _refreshStatus() async {
    final intent = _intent;
    if (intent == null || _checkingStatus) return;
    setState(() {
      _checkingStatus = true;
      _paymentError = null;
    });
    try {
      final refreshed = await widget.paymentGateway.paymentIntent(intent.id);
      if (!mounted) return;
      setState(() => _intent = refreshed);
      _revealPaymentStatus();
    } catch (error) {
      if (!mounted) return;
      setState(() => _paymentError = _message(error));
    } finally {
      if (mounted) {
        setState(() => _checkingStatus = false);
        _schedulePoll();
      }
    }
  }

  /// Checks the payment status periodically while the member approves the
  /// mobile-money prompt, so they don't have to keep tapping "Check status".
  void _schedulePoll() {
    _pollTimer?.cancel();
    final intent = _intent;
    if (intent == null ||
        intent.isTerminal ||
        _pollAttempts >= _maxPollAttempts) {
      return;
    }
    _pollTimer = Timer(_pollInterval, () {
      _pollAttempts++;
      _refreshStatus();
    });
  }

  String _message(Object error) {
    return error is ApiException
        ? error.message
        : 'Unable to complete the payment. Please try again.';
  }

  void _revealPaymentStatus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _startNewPayment() {
    _pollTimer?.cancel();
    setState(() {
      _intent = null;
      _paymentError = null;
      _idempotencyKey = const Uuid().v4();
    });
  }
}

String _providerName(String provider) {
  return switch (provider) {
    'vodacom_m_pesa' => 'M-Pesa',
    'airtel_money' => 'Airtel Money',
    'mixx_by_yas' => 'Mixx by Yas',
    _ => provider.replaceAll('_', ' '),
  };
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
                    fontWeight: FontWeight.w800,
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
        color: AppColors.warningSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warningBorder),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.warningIcon),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Online payments are not enabled yet. You can review the selected week while provider setup is completed.\nMalipo ya mtandao bado hayajafunguliwa.',
              style: TextStyle(color: AppColors.warningText, height: 1.35),
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
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
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

class _PaymentStatusCard extends StatelessWidget {
  const _PaymentStatusCard({
    required this.intent,
    required this.checking,
    required this.onCheckStatus,
    required this.onDone,
    required this.onRetry,
  });

  final PaymentIntent intent;
  final bool checking;
  final VoidCallback? onCheckStatus;
  final VoidCallback? onDone;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final succeeded = intent.isSuccessful;
    final failed = const {
      'failed',
      'expired',
      'cancelled',
    }.contains(intent.status);
    final color = succeeded
        ? AppColors.success
        : failed
        ? AppColors.error
        : AppColors.primary;
    final icon = succeeded
        ? Icons.check_circle_rounded
        : failed
        ? Icons.error_outline_rounded
        : Icons.phone_android_rounded;
    final title = succeeded
        ? 'Payment successful · Malipo yamekamilika'
        : failed
        ? 'Payment not completed · Malipo hayajakamilika'
        : 'Confirming payment · Inathibitisha malipo';
    final message = succeeded
        ? 'Your contribution has been recorded.'
        : intent.nextAction?.message ?? 'Please check the payment status.';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(message),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${intent.reference} · ${formatMoney(intent.amount)}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          if (onCheckStatus != null || onDone != null || onRetry != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: succeeded
                  ? FilledButton.icon(
                      onPressed: onDone,
                      icon: const Icon(Icons.done_rounded),
                      label: const Text('Done · Maliza'),
                    )
                  : onRetry != null
                  ? OutlinedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Try again · Jaribu tena'),
                    )
                  : OutlinedButton.icon(
                      onPressed: checking ? null : onCheckStatus,
                      icon: checking
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh_rounded),
                      label: const Text('Check status · Angalia hali'),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
