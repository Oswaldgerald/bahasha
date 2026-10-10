class Money {
  const Money({required this.amount, required this.currency});

  final double amount;
  final String currency;

  factory Money.fromJson(Map<String, dynamic> json) {
    return Money(
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0,
      currency: json['currency']?.toString() ?? 'TZS',
    );
  }
}

class MemberProfile {
  const MemberProfile({
    required this.id,
    required this.fullName,
    required this.bahashaNumber,
    required this.churchName,
    required this.photoUrl,
  });

  final String id;
  final String fullName;
  final String bahashaNumber;
  final String churchName;
  final String? photoUrl;

  factory MemberProfile.fromJson(Map<String, dynamic> json) {
    final church = _map(json['church']);
    return MemberProfile(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      bahashaNumber: json['bahasha_number']?.toString() ?? '',
      churchName: church['name']?.toString() ?? '',
      photoUrl: json['photo_url']?.toString(),
    );
  }
}

class ActivePeriod {
  const ActivePeriod({this.financialYearId, this.year, this.week});

  final String? financialYearId;
  final int? year;
  final ActiveWeek? week;

  factory ActivePeriod.fromJson(Map<String, dynamic> json) {
    final year = _map(json['financial_year']);
    final week = _nullableMap(json['week']);
    return ActivePeriod(
      financialYearId: year['id']?.toString(),
      year: _int(year['year']),
      week: week == null ? null : ActiveWeek.fromJson(week),
    );
  }
}

class ActiveWeek {
  const ActiveWeek({
    required this.id,
    required this.number,
    required this.sundayDate,
    required this.isClosed,
  });

  final String id;
  final int number;
  final DateTime sundayDate;
  final bool isClosed;

  factory ActiveWeek.fromJson(Map<String, dynamic> json) {
    return ActiveWeek(
      id: json['id']?.toString() ?? '',
      number: _int(json['number']) ?? 0,
      sundayDate: _date(json['sunday_date']),
      isClosed: json['is_closed'] == true,
    );
  }
}

class ContributionCategory {
  const ContributionCategory({
    required this.id,
    required this.key,
    required this.name,
    required this.swahiliName,
    required this.description,
    required this.iconKey,
    required this.colorHex,
    required this.frequency,
    required this.paymentsEnabled,
    required this.allowsCatchUp,
    required this.missingWeeksCount,
    required this.totalContributed,
    this.suggestedAmount,
  });

  final String id;
  final String key;
  final String name;
  final String swahiliName;
  final String description;
  final String iconKey;
  final String colorHex;
  final String frequency;
  final bool paymentsEnabled;
  final bool allowsCatchUp;
  final int missingWeeksCount;
  final Money totalContributed;
  final Money? suggestedAmount;

  factory ContributionCategory.fromJson(Map<String, dynamic> json) {
    final labels = _map(json['labels']);
    final guidance = _map(json['amount_guidance']);
    final suggested = _nullableMap(guidance['suggested']);
    return ContributionCategory(
      id: json['id']?.toString() ?? '',
      key: json['key']?.toString() ?? '',
      name: labels['default']?.toString() ?? '',
      swahiliName: labels['sw']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      iconKey: json['icon']?.toString() ?? 'gift',
      colorHex: json['color']?.toString() ?? '#0A4A4C',
      frequency: json['frequency']?.toString() ?? '',
      paymentsEnabled: json['payments_enabled'] == true,
      allowsCatchUp: json['allows_catch_up'] == true,
      missingWeeksCount: _int(json['missing_weeks_count']) ?? 0,
      totalContributed: Money.fromJson(_map(json['total_contributed'])),
      suggestedAmount: suggested == null ? null : Money.fromJson(suggested),
    );
  }
}

class MobileCapabilities {
  const MobileCapabilities({required this.paymentsEnabled});

  final bool paymentsEnabled;

  factory MobileCapabilities.fromJson(Map<String, dynamic> json) {
    return MobileCapabilities(
      paymentsEnabled: json['payments_enabled'] == true,
    );
  }
}

class MemberBootstrap {
  const MemberBootstrap({
    required this.member,
    required this.activePeriod,
    required this.categories,
    required this.unreadNotificationsCount,
    required this.capabilities,
  });

  final MemberProfile member;
  final ActivePeriod activePeriod;
  final List<ContributionCategory> categories;
  final int unreadNotificationsCount;
  final MobileCapabilities capabilities;

  factory MemberBootstrap.fromJson(Map<String, dynamic> json) {
    return MemberBootstrap(
      member: MemberProfile.fromJson(_map(json['member'])),
      activePeriod: ActivePeriod.fromJson(_map(json['active_period'])),
      categories: _maps(
        json['categories'],
      ).map(ContributionCategory.fromJson).toList(),
      unreadNotificationsCount: _int(json['unread_notifications_count']) ?? 0,
      capabilities: MobileCapabilities.fromJson(_map(json['capabilities'])),
    );
  }
}

class ContributionWeek {
  const ContributionWeek({
    required this.id,
    required this.number,
    required this.sundayDate,
    required this.state,
    required this.paymentEligible,
    required this.contributed,
  });

  final String id;
  final int number;
  final DateTime sundayDate;
  final String state;
  final bool paymentEligible;
  final Money contributed;

  factory ContributionWeek.fromJson(Map<String, dynamic> json) {
    return ContributionWeek(
      id: json['id']?.toString() ?? '',
      number: _int(json['week_number']) ?? 0,
      sundayDate: _date(json['sunday_date']),
      state: json['state']?.toString() ?? 'unavailable',
      paymentEligible: json['payment_eligible'] == true,
      contributed: Money.fromJson(_map(json['contributed'])),
    );
  }
}

class ContributionRecord {
  const ContributionRecord({
    required this.id,
    required this.reference,
    required this.weekNumber,
    required this.sundayDate,
    required this.amount,
    required this.source,
    required this.status,
    required this.contributionDate,
  });

  final String id;
  final String reference;
  final int weekNumber;
  final DateTime sundayDate;
  final Money amount;
  final String source;
  final String status;
  final DateTime contributionDate;

  factory ContributionRecord.fromJson(Map<String, dynamic> json) {
    final week = _map(json['week']);
    return ContributionRecord(
      id: json['id']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      weekNumber: _int(week['number']) ?? 0,
      sundayDate: _date(week['sunday_date']),
      amount: Money.fromJson(_map(json['amount'])),
      source: json['source']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      contributionDate: _date(json['contribution_date']),
    );
  }
}

class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  });

  final List<T> items;
  final bool hasMore;
  final String? nextCursor;
}

Map<String, dynamic> _map(dynamic value) {
  return value is Map<String, dynamic> ? value : <String, dynamic>{};
}

Map<String, dynamic>? _nullableMap(dynamic value) {
  return value is Map<String, dynamic> ? value : null;
}

List<Map<String, dynamic>> _maps(dynamic value) {
  if (value is! List) return const [];
  return value.whereType<Map<String, dynamic>>().toList();
}

int? _int(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

DateTime _date(dynamic value) {
  return DateTime.tryParse(value?.toString() ?? '') ?? DateTime(1970);
}
