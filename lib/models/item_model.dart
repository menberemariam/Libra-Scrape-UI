// lib/models/item_model.dart
class ItemModel {
  final String id;
  final String title;
  final String author;
  final String? description;
  final List<String> genres;
  final String? coverUrl;
  final List<String> downloadUrls;
  final ItemType type;
  final ItemSource source;
  final String sourceUrl;
  final DateTime createdAt;

  ItemModel({
    required this.id,
    required this.title,
    required this.author,
    this.description,
    required this.genres,
    this.coverUrl,
    required this.downloadUrls,
    required this.type,
    required this.source,
    required this.sourceUrl,
    required this.createdAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      description: json['description'] as String?,
      genres: List<String>.from(json['genres'] ?? []),
      coverUrl: json['coverUrl'] as String?,
      downloadUrls: List<String>.from(json['downloadUrls'] ?? []),
      type: ItemType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ItemType.book,
      ),
      source: ItemSource.fromApi(json['source'] as String?),
      sourceUrl: json['sourceUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'genres': genres,
      'coverUrl': coverUrl,
      'downloadUrls': downloadUrls,
      'type': type.name,
      'source': source.apiValue,
      'sourceUrl': sourceUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Helper getters
  bool get isAudiobook => type == ItemType.audiobook;
  String get primaryGenre => genres.isNotEmpty ? genres.first : 'Unknown';
  String get typeDisplayName => isAudiobook ? 'Audiobook' : 'Book';
  String get displayCoverUrl => coverUrl ?? 'https://via.placeholder.com/300x400?text=${Uri.encodeComponent(title)}';
}

enum ItemType { book, audiobook }

enum ItemSource {
  librivox('librivox'),
  standardEbooks('standard_ebooks');

  const ItemSource(this.apiValue);

  /// Value used by the backend (e.g. `standard_ebooks`).
  final String apiValue;

  static ItemSource fromApi(String? value) {
    return ItemSource.values.firstWhere(
      (e) => e.apiValue == value || e.name == value,
      orElse: () => ItemSource.standardEbooks,
    );
  }
}