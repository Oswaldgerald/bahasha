class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.statusCode,
    this.fields = const {},
  });

  final String code;
  final String message;
  final int? statusCode;
  final Map<String, List<String>> fields;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}
