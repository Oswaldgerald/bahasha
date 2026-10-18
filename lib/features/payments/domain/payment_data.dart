import '../../contributions/domain/member_data.dart';

class PaymentMethod {
  const PaymentMethod({
    required this.key,
    required this.name,
    required this.providers,
    required this.currency,
    required this.enabled,
  });

  final String key;
  final String name;
  final List<String> providers;
  final String currency;
  final bool enabled;

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    final rawProviders = json['providers'];
    return PaymentMethod(
      key: json['key']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      providers: rawProviders is List
          ? rawProviders.map((provider) => provider.toString()).toList()
          : const [],
      currency: json['currency']?.toString() ?? 'TZS',
      enabled: json['enabled'] == true,
    );
  }
}

class PaymentNextAction {
  const PaymentNextAction({required this.type, required this.message});

  final String type;
  final String message;

  factory PaymentNextAction.fromJson(Map<String, dynamic> json) {
    return PaymentNextAction(
      type: json['type']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }
}

class PaymentIntent {
  const PaymentIntent({
    required this.id,
    required this.reference,
    required this.status,
    required this.provider,
    required this.amount,
    required this.contributionIds,
    this.nextAction,
  });

  final String id;
  final String reference;
  final String status;
  final String provider;
  final Money amount;
  final List<String> contributionIds;
  final PaymentNextAction? nextAction;

  bool get isSuccessful => status == 'succeeded';
  bool get isTerminal =>
      const {'succeeded', 'failed', 'expired', 'cancelled'}.contains(status);

  factory PaymentIntent.fromJson(Map<String, dynamic> json) {
    final rawContributionIds = json['contribution_ids'];
    final rawNextAction = json['next_action'];
    return PaymentIntent(
      id: json['id']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      provider: json['provider']?.toString() ?? '',
      amount: Money.fromJson(_map(json['amount'])),
      contributionIds: rawContributionIds is List
          ? rawContributionIds.map((id) => id.toString()).toList()
          : const [],
      nextAction: rawNextAction is Map<String, dynamic>
          ? PaymentNextAction.fromJson(rawNextAction)
          : null,
    );
  }
}

Map<String, dynamic> _map(dynamic value) {
  return value is Map<String, dynamic> ? value : <String, dynamic>{};
}
