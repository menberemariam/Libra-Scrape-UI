// lib/models/pagination_response.dart
class PaginationResponse<T> {
  final List<T> items;
  final int total;
  final int limit;
  final int offset;
  final int totalPages;

  PaginationResponse({
    required this.items,
    required this.total,
    required this.limit,
    required this.offset,
    required this.totalPages,
  });

  factory PaginationResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginationResponse<T>(
      items: (json['items'] as List)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      limit: json['limit'] as int,
      offset: json['offset'] as int,
      totalPages: json['totalPages'] as int,
    );
  }

  // Helper getters
  bool get hasNextPage => offset + limit < total;
  bool get hasPreviousPage => offset > 0;
  int get currentPage => (offset / limit).floor() + 1;
}