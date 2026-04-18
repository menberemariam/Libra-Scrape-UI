// lib/models/download_info.dart
import 'item_model.dart';

class DownloadInfo {
  final String id;
  final String title;
  final List<String> downloadUrls;
  final ItemType type;
  final List<String> formats;

  DownloadInfo({
    required this.id,
    required this.title,
    required this.downloadUrls,
    required this.type,
    required this.formats,
  });

  factory DownloadInfo.fromJson(Map<String, dynamic> json) {
    return DownloadInfo(
      id: json['id'] as String,
      title: json['title'] as String,
      downloadUrls: List<String>.from(json['downloadUrls'] ?? []),
      type: ItemType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ItemType.book,
      ),
      formats: List<String>.from(json['formats'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'downloadUrls': downloadUrls,
      'type': type.name,
      'formats': formats,
    };
  }
}

class DirectDownloadResponse {
  final String downloadUrl;
  final String filename;
  final String contentType;
  final DateTime expiresAt;

  DirectDownloadResponse({
    required this.downloadUrl,
    required this.filename,
    required this.contentType,
    required this.expiresAt,
  });

  factory DirectDownloadResponse.fromJson(Map<String, dynamic> json) {
    return DirectDownloadResponse(
      downloadUrl: json['downloadUrl'] as String,
      filename: json['filename'] as String,
      contentType: json['contentType'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}