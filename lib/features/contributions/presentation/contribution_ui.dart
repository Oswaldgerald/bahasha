import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../domain/member_data.dart';

final _amountFormat = NumberFormat.decimalPattern('en');
final _dateFormat = DateFormat('dd MMM yyyy');

String formatMoney(Money money) {
  final amount = money.amount == money.amount.roundToDouble()
      ? money.amount.toInt()
      : money.amount;
  return '${_amountFormat.format(amount)} ${money.currency}';
}

String formatDate(DateTime date) => _dateFormat.format(date);

String frequencyLabel(String frequency) {
  return switch (frequency) {
    'weekly' => 'Weekly · Kila wiki',
    'monthly' => 'Monthly · Kila mwezi',
    'annual' => 'Annual · Kila mwaka',
    'seasonal' => 'Seasonal · Kwa msimu',
    _ => frequency.isEmpty ? 'Flexible · Wakati wowote' : frequency,
  };
}

Color categoryColor(String hex) {
  final value = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
  return value == null ? AppColors.primary : Color(0xFF000000 | value);
}

IconData categoryIcon(String key) {
  return switch (key) {
    'hand-heart' => Icons.volunteer_activism_rounded,
    'landmark' => Icons.account_balance_rounded,
    'scale' => Icons.balance_rounded,
    'users-round' => Icons.groups_rounded,
    'tractor' => Icons.agriculture_rounded,
    'heart-handshake' => Icons.handshake_rounded,
    'badge-dollar-sign' => Icons.savings_rounded,
    'building-2' => Icons.home_work_rounded,
    _ => Icons.card_giftcard_rounded,
  };
}

String weekStateLabel(String state) {
  return switch (state) {
    'paid' => 'Paid · Imelipwa',
    'missing' => 'Missing · Haijalipwa',
    'upcoming' => 'Upcoming · Inakuja',
    _ => 'Unavailable · Haipatikani',
  };
}

String contributionStatusLabel(String status) {
  return switch (status.toUpperCase()) {
    'POSTED' => 'Posted · Imepokelewa',
    'PENDING' => 'Pending · Inasubiri',
    'REVERSED' => 'Reversed · Imerudishwa',
    _ => status,
  };
}

Color contributionStatusColor(String status) {
  return switch (status.toUpperCase()) {
    'POSTED' => AppColors.success,
    'PENDING' => AppColors.warning,
    'REVERSED' => AppColors.error,
    _ => AppColors.textSecondary,
  };
}

IconData contributionStatusIcon(String status) {
  return switch (status.toUpperCase()) {
    'POSTED' => Icons.check_circle_rounded,
    'PENDING' => Icons.schedule_rounded,
    'REVERSED' => Icons.undo_rounded,
    _ => Icons.help_outline_rounded,
  };
}

Color weekStateColor(String state) {
  return switch (state) {
    'paid' => AppColors.success,
    'missing' => AppColors.warning,
    'upcoming' => AppColors.info,
    _ => AppColors.textSecondary,
  };
}
