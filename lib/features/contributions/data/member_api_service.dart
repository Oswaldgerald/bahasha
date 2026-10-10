import '../../../core/network/authenticated_api_client.dart';
import '../domain/member_data.dart';

abstract class MemberDataGateway {
  Future<MemberBootstrap> bootstrap();

  Future<PagedResult<ContributionWeek>> categoryWeeks({
    required String categoryId,
    String? financialYearId,
    String? cursor,
  });

  Future<PagedResult<ContributionRecord>> contributions({
    required String categoryId,
    String? financialYearId,
    String? cursor,
  });
}

class MemberApiService implements MemberDataGateway {
  MemberApiService(this._client);

  final AuthenticatedApiClient _client;

  @override
  Future<MemberBootstrap> bootstrap() async {
    return MemberBootstrap.fromJson(await _client.getJson('/bootstrap'));
  }

  @override
  Future<PagedResult<ContributionWeek>> categoryWeeks({
    required String categoryId,
    String? financialYearId,
    String? cursor,
  }) async {
    final payload = await _client.getJson(
      _path('/contribution-categories/$categoryId/weeks', {
        'financial_year_id': financialYearId,
        'cursor': cursor,
        'page_size': '50',
      }),
    );
    return _paged(payload, ContributionWeek.fromJson);
  }

  @override
  Future<PagedResult<ContributionRecord>> contributions({
    required String categoryId,
    String? financialYearId,
    String? cursor,
  }) async {
    final payload = await _client.getJson(
      _path('/contributions', {
        'category_id': categoryId,
        'financial_year_id': financialYearId,
        'cursor': cursor,
        'page_size': '20',
        'status': 'posted',
      }),
    );
    return _paged(payload, ContributionRecord.fromJson);
  }

  PagedResult<T> _paged<T>(
    Map<String, dynamic> payload,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final rawItems = payload['items'];
    final page = payload['page'];
    final items = rawItems is List
        ? rawItems.whereType<Map<String, dynamic>>().map(fromJson).toList()
        : <T>[];
    final pageData = page is Map<String, dynamic> ? page : <String, dynamic>{};
    return PagedResult(
      items: items,
      hasMore: pageData['has_more'] == true,
      nextCursor: pageData['next_cursor']?.toString(),
    );
  }

  String _path(String path, Map<String, String?> query) {
    final values = Map<String, String>.fromEntries(
      query.entries
          .where((entry) => entry.value?.isNotEmpty == true)
          .map((entry) => MapEntry(entry.key, entry.value!)),
    );
    return Uri(path: path, queryParameters: values).toString();
  }
}
