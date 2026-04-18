// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/item_model.dart';
import '../models/pagination_response.dart';
import '../models/search_filters.dart';
import '../models/download_info.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000'; // Change for production
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // Headers for all requests
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
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return PaginationResponse.fromJson(
          jsonData,
          (json) => ItemModel.fromJson(json),
        );
      } else {
        throw ApiException('Failed to load items: ${response.statusCode}');
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      throw ApiException('Error loading items: $e');
    }
  }

  /// Search items with filters
  Future<PaginationResponse<ItemModel>> searchItems(SearchFilters filters) async {
    try {
      final uri = Uri.parse('$baseUrl/api/items/search').replace(
        queryParameters: filters.toQueryParams(),
      );

      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return PaginationResponse.fromJson(
          jsonData,
          (json) => ItemModel.fromJson(json),
        );
      } else {
        throw ApiException('Search failed: ${response.statusCode}');
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      throw ApiException('Search error: $e');
    }
  }

  /// Get item by ID
  Future<ItemModel> getItemById(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/api/items/$id');
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return ItemModel.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw NotFoundException('Item not found');
      } else {
        throw ApiException('Failed to load item: ${response.statusCode}');
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ApiException('Error loading item: $e');
    }
  }

  /// Get download information
  Future<DownloadInfo> getDownloadInfo(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/api/items/$id/download');
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return DownloadInfo.fromJson(jsonData);
      } else {
        throw ApiException('Failed to get download info: ${response.statusCode}');
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      throw ApiException('Download info error: $e');
    }
  }

  /// Get direct download URL
  Future<DirectDownloadResponse> getDirectDownloadUrl(String id, String format) async {
    try {
      final uri = Uri.parse('$baseUrl/api/items/$id/download/$format').replace(
        queryParameters: {'direct': 'true'},
      );

      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return DirectDownloadResponse.fromJson(jsonData);
      } else {
        throw ApiException('Failed to get download URL: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Download URL error: $e');
    }
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