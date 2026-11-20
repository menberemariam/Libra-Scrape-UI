// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item_model.dart';
import '../models/pagination_response.dart';
import '../models/search_filters.dart';
import '../models/download_info.dart';
import 'demo_data.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000'; // Change for production

  /// True when the app is showing the bundled demo catalogue because the
  /// backend could not be reached. The UI surfaces this as a small hint.
  static bool demoMode = false;

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Get paginated items
  Future<PaginationResponse<ItemModel>> getItems({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final offset = (page - 1) * limit;
      final uri = Uri.parse('$baseUrl/api/items').replace(
        queryParameters: {
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );

      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        demoMode = false;
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return PaginationResponse.fromJson(
          jsonData,
          (json) => ItemModel.fromJson(json),
        );
      } else {
        throw ApiException('Failed to load items: ${response.statusCode}');
      }
    } catch (e) {
      if (_isOffline(e)) {
        return _useDemo(() => DemoCatalog.page(page: page, limit: limit));
      }
      if (e is ApiException) rethrow;
      throw ApiException('Error loading items: $e');
    }
  }

  /// Search items with filters
  Future<PaginationResponse<ItemModel>> searchItems(
      SearchFilters filters) async {
    try {
      final uri = Uri.parse('$baseUrl/api/items/search').replace(
        queryParameters: filters.toQueryParams(),
      );

      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        demoMode = false;
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return PaginationResponse.fromJson(
          jsonData,
          (json) => ItemModel.fromJson(json),
        );
      } else {
        throw ApiException('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      if (_isOffline(e)) {
        return _useDemo(() => DemoCatalog.search(filters));
      }
      if (e is ApiException) rethrow;
      throw ApiException('Search error: $e');
    }
  }

  /// Get item by ID
  Future<ItemModel> getItemById(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/api/items/$id');
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        demoMode = false;
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return ItemModel.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw NotFoundException('Item not found');
      } else {
        throw ApiException('Failed to load item: ${response.statusCode}');
      }
    } catch (e) {
      if (_isOffline(e)) {
        final item = DemoCatalog.findById(id);
        if (item == null) throw NotFoundException('Item not found');
        demoMode = true;
        return item;
      }
      if (e is NotFoundException) rethrow;
      if (e is ApiException) rethrow;
      throw ApiException('Error loading item: $e');
    }
  }

  /// Get download information
  Future<DownloadInfo> getDownloadInfo(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/api/items/$id/download');
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        demoMode = false;
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return DownloadInfo.fromJson(jsonData);
      } else {
        throw ApiException('Failed to get download info: ${response.statusCode}');
      }
    } catch (e) {
      if (_isOffline(e)) {
        final item = DemoCatalog.findById(id);
        if (item == null) throw NotFoundException('Item not found');
        demoMode = true;
        final formats = DemoCatalog.formatFor(item);
        return DownloadInfo(
          id: item.id,
          title: item.title,
          downloadUrls: item.downloadUrls,
          type: item.type,
          formats: formats,
        );
      }
      if (e is NotFoundException) rethrow;
      if (e is ApiException) rethrow;
      throw ApiException('Download info error: $e');
    }
  }

  /// Get direct download URL
  Future<DirectDownloadResponse> getDirectDownloadUrl(
      String id, String format) async {
    try {
      final uri = Uri.parse('$baseUrl/api/items/$id/download/$format').replace(
        queryParameters: {'direct': 'true'},
      );

      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        demoMode = false;
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return DirectDownloadResponse.fromJson(jsonData);
      } else {
        throw ApiException('Failed to get download URL: ${response.statusCode}');
      }
    } catch (e) {
      if (_isOffline(e)) {
        final item = DemoCatalog.findById(id);
        if (item == null) throw NotFoundException('Item not found');
        demoMode = true;
        return DirectDownloadResponse(
          downloadUrl: item.sourceUrl,
          filename:
              '${item.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}.${format.toLowerCase()}',
          contentType: 'application/octet-stream',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );
      }
      if (e is NotFoundException) rethrow;
      throw ApiException('Download URL error: $e');
    }
  }

  T _useDemo<T>(T Function() fallback) {
    demoMode = true;
    return fallback();
  }

  /// Connection-level failures mean there is no backend to talk to, so the
  /// bundled catalogue is used instead of showing an error screen.
  bool _isOffline(Object error) {
    if (error is http.ClientException) return true;
    final message = error.toString().toLowerCase();
    return message.contains('failed to fetch') ||
        message.contains('connection refused') ||
        message.contains('connection closed') ||
        message.contains('socketexception') ||
        message.contains('xmlhttprequest') ||
        message.contains('network is unreachable') ||
        message.contains('connection timed out');
  }

  void dispose() {
    _client.close();
  }
}

// Custom Exceptions
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);

  @override
  String toString() => 'NotFoundException: $message';
}
