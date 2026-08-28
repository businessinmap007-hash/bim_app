/// Normalized error shape the whole app codes against, instead of raw Dio
/// exceptions — mirrors the backend's envelope:
/// 422 -> {"message", "errors": {field: [..]}}, 401/403/404/409 -> {"message"}.
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final Map<String, List<String>> fieldErrors;

  const ApiException({
    required this.message,
    this.statusCode,
    this.fieldErrors = const {},
  });

  bool get isValidationError => statusCode == 422;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isNetworkError => statusCode == null;

  /// First message for a given field, if the backend flagged it (422).
  String? firstErrorFor(String field) => fieldErrors[field]?.firstOrNull;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
