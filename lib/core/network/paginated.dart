/// Mirrors a Laravel paginator's JSON shape:
/// `{ data: [...], current_page, last_page, per_page, total }`.
class Paginated<T> {
  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int total;

  const Paginated({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  bool get hasMore => currentPage < lastPage;

  factory Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return Paginated(
      items: (json['data'] as List<dynamic>? ?? [])
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  static Paginated<T> empty<T>() =>
      Paginated(items: const [], currentPage: 1, lastPage: 1, total: 0);
}
