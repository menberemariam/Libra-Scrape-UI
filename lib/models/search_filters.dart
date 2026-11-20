// lib/models/search_filters.dart
import 'item_model.dart';

class SearchFilters {
  final String? query;
  final ItemType? type;
  final String? genre;
  final String? author;
  final int limit;
  final int offset;

  SearchFilters({
    this.query,
    this.type,
    this.genre,
    this.author,
    this.limit = 20,
    this.offset = 0,
  });

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    
    if (query != null && query!.isNotEmpty) params['q'] = query!;
    if (type != null) params['type'] = type!.name;
    if (genre != null && genre!.isNotEmpty) params['genre'] = genre!;
    if (author != null && author!.isNotEmpty) params['author'] = author!;
    
    params['limit'] = limit.toString();
    params['offset'] = offset.toString();
    
    return params;
  }

  SearchFilters copyWith({
    String? query,
    ItemType? type,
    String? genre,
    String? author,
    int? limit,
    int? offset,
    bool clearType = false,
    bool clearGenre = false,
    bool clearAuthor = false,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      type: clearType ? null : (type ?? this.type),
      genre: clearGenre ? null : (genre ?? this.genre),
      author: clearAuthor ? null : (author ?? this.author),
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  bool get hasActiveFilters => 
      (query?.isNotEmpty ?? false) ||
      type != null ||
      (genre?.isNotEmpty ?? false) ||
      (author?.isNotEmpty ?? false);
}